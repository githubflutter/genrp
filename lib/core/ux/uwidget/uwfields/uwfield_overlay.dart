import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

/// Dedicated combo/select field widget with suggestion overlay.
///
/// Use this directly for better performance when you know you need combo/select mode,
/// or use [UwField] with [UwFieldMode.combo] or [UwFieldMode.select] for mode-dispatched convenience.
class UwFieldOverlay extends StatefulWidget with Uwidget {
  const UwFieldOverlay({required this.i, required this.autopilot, required this.spec, this.callbacks = const UwFieldCallbacks(), this.s = 0, super.key});

  @override
  final int vid = 14;
  @override
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_overlay';

  final Autopilot autopilot;
  final UwFieldOverlaySpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldOverlay> createState() => _UwFieldOverlayState();
}

class _UwFieldOverlayState extends State<UwFieldOverlay> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<dynamic> _filteredItems = <dynamic>[];
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.spec.value));
    _filteredItems = _getAvailableItems();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
    if (!widget.spec.isSelectMode) {
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _hideOverlay();
    super.dispose();
  }

  String _formatValue(dynamic value) {
    if (value == null) return '';
    if (widget.spec.itemLabelBuilder != null) {
      return widget.spec.itemLabelBuilder!(value);
    }
    return value.toString();
  }

  List<dynamic> _getAvailableItems() {
    return widget.spec.items ?? <dynamic>[];
  }

  void _onTextChanged() {
    final text = _controller.text.toLowerCase();
    setState(() {
      if (text.isEmpty) {
        _filteredItems = _getAvailableItems();
      } else {
        _filteredItems = _getAvailableItems().where((dynamic item) {
          final label = widget.spec.itemLabelBuilder?.call(item) ?? item.toString();
          return label.toLowerCase().contains(text);
        }).toList();
      }
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _filteredItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _filteredItems[index];
                    final label = widget.spec.itemLabelBuilder?.call(item) ?? item.toString();
                    return ListTile(
                      title: Text(label),
                      onTap: () {
                        _controller.text = label;
                        widget.callbacks.onChanged?.call(item);
                        _hideOverlay();
                        _focusNode.unfocus();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = CompositedTransformTarget(
      link: _layerLink,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.spec.leftIcon != null)
            IconButton(
              icon: Icon(widget.spec.leftIcon),
              tooltip: widget.spec.leftTooltip,
              iconSize: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: widget.callbacks.onRefresh ?? widget.callbacks.onLeftPressed,
            ),
          Expanded(
            child: GestureDetector(
              onTap: widget.spec.isSelectMode
                  ? () {
                      _focusNode.requestFocus();
                      _showOverlay();
                    }
                  : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: widget.spec.label,
                  hintText: widget.spec.hint,
                  suffixIcon: IconButton(
                    icon: Icon(widget.spec.rightIcon ?? Icons.arrow_drop_down),
                    tooltip: widget.spec.rightTooltip ?? 'Show suggestions',
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: widget.spec.readOnly
                        ? null
                        : () {
                            if (_focusNode.hasFocus && _overlayEntry != null) {
                              _hideOverlay();
                              _focusNode.unfocus();
                            } else {
                              _focusNode.requestFocus();
                              _showOverlay();
                            }
                          },
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: widget.spec.isSelectMode,
                  enabled: !widget.spec.readOnly,
                  decoration: const InputDecoration.collapsed(hintText: ''),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.spec.width != null) {
      fieldBody = SizedBox(width: widget.spec.width, child: fieldBody);
    }
    return fieldBody;
  }
}

/// Spec for [UwFieldOverlay] - combo/select with suggestion overlay.
class UwFieldOverlaySpec {
  const UwFieldOverlaySpec({
    this.label,
    this.hint,
    this.width,
    this.value,
    this.readOnly = false,
    this.isSelectMode = false,
    this.items,
    this.itemLabelBuilder,
    this.leftIcon,
    this.leftTooltip,
    this.rightIcon,
    this.rightTooltip,
  });

  final String? label;
  final String? hint;
  final double? width;
  final dynamic value;
  final bool readOnly;
  final bool isSelectMode; // true = select (read-only), false = combo (editable)
  final List<dynamic>? items;
  final String Function(dynamic)? itemLabelBuilder;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
}
