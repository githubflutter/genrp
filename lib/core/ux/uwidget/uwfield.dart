import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield_chips.dart';
import 'package:genrp/core/ux/uwidget/uwfield_filter.dart';
import 'package:genrp/core/ux/uwidget/uwfield_overlay.dart';
import 'package:genrp/core/ux/uwidget/uwfield_picker.dart';
import 'package:genrp/core/ux/uwidget/uwfield_toggle.dart';

enum UwFieldMode { text, number, combo, select, date, datetime, bool_, json, link, tag, filter }

enum FilterOp { contains, startsWith, endsWith, except }

class UwFieldSpec {
  const UwFieldSpec({
    this.mode,
    this.dataTypeId,
    this.label,
    this.hint,
    this.width,
    this.value,
    this.readOnly = false,
    this.items,
    this.itemLabelBuilder,
    this.tags,
    this.tagDelimiter = ', ',
    this.showChips = true,
    this.allowDuplicates = false,
    this.stateKey,
    this.stateSrc = 0,
    this.stateScope,
    this.filterOp = FilterOp.contains,
    this.leftIcon,
    this.leftTooltip,
    this.rightIcon,
    this.rightTooltip,
    this.dateFormat,
  });

  final UwFieldMode? mode;
  final int? dataTypeId;

  // Labels
  final String? label;
  final String? hint;
  final double? width;

  // Value
  final dynamic value;
  final bool readOnly;

  // Suggestion items (combo / select / tag)
  final List<dynamic>? items;
  final String Function(dynamic)? itemLabelBuilder;

  // Tag specifics
  final List<dynamic>? tags;
  final String tagDelimiter;
  final bool showChips;
  final bool allowDuplicates;

  // Link specifics
  final String? stateKey;
  final int stateSrc; // 0 = chrome, 1 = dataSet, 2 = scoped
  final String? stateScope;

  // Filter specifics
  final FilterOp filterOp;

  // Picker specifics
  final String? dateFormat;

  // Left / Right icon overrides
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;

  UwFieldMode get effectiveMode {
    if (mode != null) return mode!;
    if (dataTypeId != null) {
      return UwField.modeForDataType(dataTypeId!);
    }
    return UwFieldMode.text;
  }
}

class UwFieldCallbacks {
  const UwFieldCallbacks({
    this.onChanged,
    this.onRefresh,
    this.onTagAdded,
    this.onTagRemoved,
    this.onLink,
    this.onPush,
    this.onFilterApplied,
    this.onFilterCleared,
    this.onLeftPressed,
    this.onRightPressed,
  });

  final void Function(dynamic)? onChanged;
  final void Function()? onRefresh;
  final void Function(dynamic)? onTagAdded;
  final void Function(int)? onTagRemoved;
  final void Function(bool)? onLink;
  final void Function(dynamic)? onPush;
  final void Function(Map<String, dynamic>)? onFilterApplied;
  final void Function()? onFilterCleared;
  final void Function()? onLeftPressed;
  final void Function()? onRightPressed;
}

class UwField extends StatefulWidget with Uwidget {
  const UwField({
    required this.i,
    required this.autopilot,
    required this.spec,
    this.callbacks = const UwFieldCallbacks(),
    this.s = 0,
    super.key,
  });

  @override
  final int vid = 14;
  @override
  final int s;
  @override
  final int i;
  @override
  final String n = 'field';

  final Autopilot autopilot;
  final UwFieldSpec spec;
  final UwFieldCallbacks callbacks;

  static UwFieldMode modeForDataType(int dataTypeId) {
    if (dataTypeId == 0) return UwFieldMode.bool_;
    if (dataTypeId >= 1 && dataTypeId <= 4) return UwFieldMode.number; // Int32, Int53, Int64, Double
    if (dataTypeId == 6 || dataTypeId == 7) return UwFieldMode.json; // Json, Jsonb
    if (dataTypeId > 99) return UwFieldMode.number; // Numeric
    return UwFieldMode.text; // Binary, Guid, String, Base64 fallback to text
  }

  @override
  State<UwField> createState() => _UwFieldState();
}

class _UwFieldState extends State<UwField> {
  late final TextEditingController _controller;
  bool _isTagAddMode = false;
  bool _isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _syncValue();
  }

  @override
  void didUpdateWidget(covariant UwField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec.value != oldWidget.spec.value) {
      _syncValue();
    }
  }

  void _syncValue() {
    final value = widget.spec.value;
    if (value != null) {
      _controller.text = value.toString();
    } else {
      _controller.text = '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = _buildBody();
    if (widget.spec.width != null) {
      fieldBody = SizedBox(width: widget.spec.width, child: fieldBody);
    }
    return fieldBody;
  }

  Widget _buildBody() {
    final mode = widget.spec.effectiveMode;
    switch (mode) {
      case UwFieldMode.number:
        return _buildNumberMode();
      case UwFieldMode.bool_:
        return _buildBoolMode();
      case UwFieldMode.json:
        return _buildJsonMode();
      case UwFieldMode.date:
      case UwFieldMode.datetime:
        return UwFieldPicker(
          spec: widget.spec,
          callbacks: widget.callbacks,
          controller: _controller,
          isDatetime: mode == UwFieldMode.datetime,
        );
      case UwFieldMode.combo:
      case UwFieldMode.select:
        return UwFieldOverlay(
          spec: widget.spec,
          callbacks: widget.callbacks,
          controller: _controller,
          isSelectMode: mode == UwFieldMode.select,
          isTagAddMode: false,
        );
      case UwFieldMode.link:
        return UwFieldToggle(
          spec: widget.spec,
          callbacks: widget.callbacks,
          autopilot: widget.autopilot,
          controller: _controller,
        );
      case UwFieldMode.tag:
        return _buildTagMode();
      case UwFieldMode.filter:
        return UwFieldFilter(
          spec: widget.spec,
          callbacks: widget.callbacks,
          controller: _controller,
        );
      case UwFieldMode.text:
        return _buildTextMode();
    }
  }

  Widget _buildNumberMode() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.spec.leftIcon != null) _buildLeftButton(widget.spec.leftIcon!, widget.spec.leftTooltip),
        Expanded(
          child: TextField(
            controller: _controller,
            readOnly: widget.spec.readOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(
              labelText: widget.spec.label,
              hintText: widget.spec.hint,
              suffixIcon: (widget.spec.rightIcon != null || _controller.text.isNotEmpty)
                  ? _buildRightButton(widget.spec.rightIcon ?? Icons.clear, widget.spec.rightTooltip)
                  : null,
            ),
            onChanged: (String val) {
              setState(() {});
              if (val.isEmpty) {
                widget.callbacks.onChanged?.call(null);
              } else {
                final numValue = num.tryParse(val);
                widget.callbacks.onChanged?.call(numValue);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBoolMode() {
    final boolValue = widget.spec.value == true;
    final textValue = boolValue ? 'Yes' : 'No';
    if (_controller.text != textValue) {
      _controller.text = textValue;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.spec.leftIcon != null) _buildLeftButton(widget.spec.leftIcon!, widget.spec.leftTooltip),
        Expanded(
          child: GestureDetector(
            onTap: widget.spec.readOnly ? null : () => _toggleBool(boolValue),
            child: TextField(
              controller: _controller,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: widget.spec.label,
                hintText: widget.spec.hint,
                suffixIcon: IconButton(
                  icon: Icon(boolValue ? Icons.check_box : Icons.check_box_outline_blank),
                  tooltip: widget.spec.rightTooltip ?? 'Toggle',
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.spec.readOnly ? null : () => _toggleBool(boolValue),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleBool(bool currentValue) {
    widget.callbacks.onChanged?.call(!currentValue);
  }

  Widget _buildJsonMode() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.spec.leftIcon != null) _buildLeftButton(widget.spec.leftIcon!, widget.spec.leftTooltip),
        Expanded(
          child: TextField(
            controller: _controller,
            readOnly: widget.spec.readOnly,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: InputDecoration(
              labelText: widget.spec.label,
              hintText: widget.spec.hint ?? '{\n  "key": "value"\n}',
              suffixIcon: widget.spec.rightIcon != null
                  ? _buildRightButton(widget.spec.rightIcon!, widget.spec.rightTooltip)
                  : null,
            ),
            onChanged: (String val) {
              setState(() {});
              widget.callbacks.onChanged?.call(val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagMode() {
    if (_isTagAddMode) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildLeftButton(Icons.add, 'View tags', onPressed: () {
            setState(() {
              _isTagAddMode = false;
              _controller.clear();
            });
          }),
          Expanded(
            child: UwFieldOverlay(
              spec: widget.spec,
              callbacks: UwFieldCallbacks(
                onTagAdded: (dynamic val) {
                  final tags = List<dynamic>.from(widget.spec.tags ?? <dynamic>[]);
                  if (!widget.spec.allowDuplicates && tags.contains(val)) {
                    return;
                  }
                  tags.add(val);
                  widget.callbacks.onTagAdded?.call(val);
                  widget.callbacks.onChanged?.call(tags);
                  _controller.clear();
                  setState(() {});
                },
              ),
              controller: _controller,
              isSelectMode: false,
              isTagAddMode: true,
            ),
          ),
          _buildRightButton(Icons.add, 'Add tag', onPressed: () {
            final val = _controller.text.trim();
            if (val.isNotEmpty) {
              final tags = List<dynamic>.from(widget.spec.tags ?? <dynamic>[]);
              if (!widget.spec.allowDuplicates && tags.contains(val)) {
                return;
              }
              tags.add(val);
              widget.callbacks.onTagAdded?.call(val);
              widget.callbacks.onChanged?.call(tags);
              _controller.clear();
              setState(() {});
            }
          }),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildLeftButton(Icons.visibility, 'Add tags', onPressed: () {
          setState(() {
            _isTagAddMode = true;
            _isDeleteMode = false;
          });
        }),
        Expanded(
          child: UwFieldChips(
            spec: widget.spec,
            callbacks: UwFieldCallbacks(
              onTagRemoved: (int index) {
                final tags = List<dynamic>.from(widget.spec.tags ?? <dynamic>[]);
                tags.removeAt(index);
                widget.callbacks.onTagRemoved?.call(index);
                widget.callbacks.onChanged?.call(tags);
              },
            ),
            isDeleteMode: _isDeleteMode,
          ),
        ),
        _buildRightButton(_isDeleteMode ? Icons.check : Icons.delete, _isDeleteMode ? 'Done' : 'Delete tags', onPressed: () {
          setState(() {
            _isDeleteMode = !_isDeleteMode;
          });
        }),
      ],
    );
  }

  Widget _buildTextMode() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.spec.leftIcon != null) _buildLeftButton(widget.spec.leftIcon!, widget.spec.leftTooltip),
        Expanded(
          child: TextField(
            controller: _controller,
            readOnly: widget.spec.readOnly,
            decoration: InputDecoration(
              labelText: widget.spec.label,
              hintText: widget.spec.hint,
              suffixIcon: (widget.spec.rightIcon != null || _controller.text.isNotEmpty)
                  ? _buildRightButton(widget.spec.rightIcon ?? Icons.clear, widget.spec.rightTooltip)
                  : null,
            ),
            onChanged: (String val) {
              setState(() {}); // to toggle suffix icon
              widget.callbacks.onChanged?.call(val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeftButton(IconData icon, String? tooltip, {VoidCallback? onPressed}) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 16,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onPressed ?? widget.callbacks.onLeftPressed,
    );
  }

  Widget _buildRightButton(IconData icon, String? tooltip, {VoidCallback? onPressed}) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 16,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onPressed ?? () {
        if (widget.callbacks.onRightPressed != null) {
          widget.callbacks.onRightPressed!();
        } else if (icon == Icons.clear) {
          _controller.clear();
          widget.callbacks.onChanged?.call('');
          setState(() {});
        }
      },
    );
  }
}
