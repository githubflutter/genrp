import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';
import 'package:genrp/core/ux/uwidget/uwfields/uwfield_overlay.dart';

/// Dedicated tag field widget for managing lists of tags.
///
/// Use this directly for better performance when you know you need tag mode,
/// or use [UwField] with [UwFieldMode.tag] for mode-dispatched convenience.
class UwFieldTag extends StatefulWidget with Uwidget {
  const UwFieldTag({required this.i, required this.autopilot, required this.spec, this.callbacks = const UwFieldCallbacks(), this.s = 0, super.key});

  @override
  final int vid = 14;
  @override
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_tag';

  final Autopilot autopilot;
  final UwFieldTagSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldTag> createState() => _UwFieldTagState();
}

class _UwFieldTagState extends State<UwFieldTag> {
  late TextEditingController _controller;
  bool _isAddMode = false;
  bool _isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag(dynamic tag) {
    final tags = List<dynamic>.from(widget.spec.tags ?? <dynamic>[]);
    if (!widget.spec.allowDuplicates && tags.contains(tag)) {
      return;
    }
    tags.add(tag);
    widget.callbacks.onTagAdded?.call(tag);
    widget.callbacks.onChanged?.call(tags);
    setState(() {});
  }

  void _removeTag(int index) {
    final tags = List<dynamic>.from(widget.spec.tags ?? <dynamic>[]);
    tags.removeAt(index);
    widget.callbacks.onTagRemoved?.call(index);
    widget.callbacks.onChanged?.call(tags);
    setState(() {});
  }

  void _addTagFromText() {
    final val = _controller.text.trim();
    if (val.isNotEmpty) {
      _addTag(val);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody;

    if (_isAddMode) {
      fieldBody = _buildAddMode();
    } else {
      fieldBody = _buildViewMode();
    }

    if (widget.spec.width != null) {
      fieldBody = SizedBox(width: widget.spec.width, child: fieldBody);
    }
    return fieldBody;
  }

  Widget _buildAddMode() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'View tags',
          iconSize: 16,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () {
            setState(() {
              _isAddMode = false;
              _controller.clear();
            });
          },
        ),
        Expanded(
          child: UwFieldOverlay(
            i: widget.i,
            autopilot: widget.autopilot,
            spec: UwFieldOverlaySpec(items: widget.spec.items, itemLabelBuilder: widget.spec.itemLabelBuilder, isSelectMode: false),
            callbacks: UwFieldCallbacks(
              onTagAdded: (dynamic val) {
                _addTag(val);
                _controller.clear();
              },
            ),
          ),
        ),
        IconButton(icon: const Icon(Icons.add), tooltip: 'Add tag', iconSize: 16, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32), onPressed: _addTagFromText),
      ],
    );
  }

  Widget _buildViewMode() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.visibility),
          tooltip: 'Add tags',
          iconSize: 16,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () {
            setState(() {
              _isAddMode = true;
              _isDeleteMode = false;
            });
          },
        ),
        Expanded(child: _buildChips()),
        IconButton(
          icon: Icon(_isDeleteMode ? Icons.check : Icons.delete),
          tooltip: _isDeleteMode ? 'Done' : 'Delete tags',
          iconSize: 16,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () {
            setState(() {
              _isDeleteMode = !_isDeleteMode;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChips() {
    final tags = widget.spec.tags ?? <dynamic>[];

    return InputDecorator(
      decoration: InputDecoration(labelText: widget.spec.label, contentPadding: const EdgeInsets.all(8)),
      child: widget.spec.showChips
          ? Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(tags.length, (int index) {
                final tag = tags[index];
                final label = widget.spec.itemLabelBuilder?.call(tag) ?? tag.toString();
                return InputChip(
                  label: Text(label),
                  onDeleted: _isDeleteMode ? () => _removeTag(index) : null,
                  deleteIcon: _isDeleteMode ? const Icon(Icons.close, size: 16) : null,
                  onPressed: _isDeleteMode ? null : () {},
                );
              }),
            )
          : Text(tags.map((dynamic t) => widget.spec.itemLabelBuilder?.call(t) ?? t.toString()).join(widget.spec.tagDelimiter)),
    );
  }
}

/// Spec for [UwFieldTag] - tag/chip list editor.
class UwFieldTagSpec {
  const UwFieldTagSpec({
    this.label,
    this.hint,
    this.width,
    this.tags,
    this.items,
    this.itemLabelBuilder,
    this.tagDelimiter = ', ',
    this.showChips = true,
    this.allowDuplicates = false,
    this.leftIcon,
    this.leftTooltip,
    this.rightIcon,
    this.rightTooltip,
  });

  final String? label;
  final String? hint;
  final double? width;
  final List<dynamic>? tags;
  final List<dynamic>? items;
  final String Function(dynamic)? itemLabelBuilder;
  final String tagDelimiter;
  final bool showChips;
  final bool allowDuplicates;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
}
