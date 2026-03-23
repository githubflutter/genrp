import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

/// Checklist item for [UwFieldChecklist].
class UwFieldChecklistItem {
  UwFieldChecklistItem({required this.value, required this.label, this.checked = false, this.icon});

  final dynamic value;
  final String label;
  bool checked;
  final IconData? icon;
}

/// Dedicated checklist picker field widget.
///
/// Supports single or multiple selection from a checklist.
/// Value is stored as dynamic (single) or `List<dynamic>` (multiple).
///
/// Use this directly for better performance, or use [UwField] with
/// [UwFieldMode.checklist] for mode-dispatched convenience.
class UwFieldChecklist extends StatefulWidget with Ux {
  const UwFieldChecklist({required this.i, required this.autopilot, required this.spec, this.callbacks = const UwFieldCallbacks(), this.s = 0, super.key});

  final int uwid = 14;
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_checklist';

  final Autopilot autopilot;
  final UwFieldChecklistSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldChecklist> createState() => _UwFieldChecklistState();
}

class _UwFieldChecklistState extends State<UwFieldChecklist> {
  List<UwFieldChecklistItem> _items = [];

  @override
  void initState() {
    super.initState();
    _buildItems();
  }

  @override
  void didUpdateWidget(covariant UwFieldChecklist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec.items != oldWidget.spec.items || widget.spec.value != oldWidget.spec.value) {
      _buildItems();
    }
  }

  void _buildItems() {
    final items = widget.spec.items ?? [];
    final value = widget.spec.value;

    _items = items.map((item) {
      dynamic itemValue;
      String itemLabel;

      if (item is Map) {
        itemValue = item['value'] ?? item['key'];
        itemLabel = item['label'] ?? item['name'] ?? itemValue.toString();
      } else if (item is UwFieldChecklistItem) {
        itemValue = item.value;
        itemLabel = item.label;
      } else {
        itemValue = item;
        itemLabel = item.toString();
      }

      bool isChecked = false;
      if (value is List) {
        isChecked = value.contains(itemValue);
      } else if (widget.spec.allowMultiple) {
        isChecked = false;
      } else {
        isChecked = value == itemValue;
      }

      return UwFieldChecklistItem(value: itemValue, label: itemLabel, checked: isChecked, icon: item is UwFieldChecklistItem ? item.icon : null);
    }).toList();
  }

  void _toggleItem(int index) {
    final item = _items[index];

    if (widget.spec.allowMultiple) {
      item.checked = !item.checked;
      final checkedValues = _items.where((i) => i.checked).map((i) => i.value).toList();
      widget.callbacks.onChanged?.call(checkedValues);
    } else {
      // Single selection - uncheck all others
      for (int i = 0; i < _items.length; i++) {
        _items[i].checked = (i == index);
      }
      widget.callbacks.onChanged?.call(item.value);
    }

    setState(() {});
  }

  void _selectAll() {
    if (!widget.spec.allowMultiple) return;

    for (final item in _items) {
      item.checked = true;
    }
    widget.callbacks.onChanged?.call(_items.map((i) => i.value).toList());
    setState(() {});
  }

  void _selectNone() {
    for (final item in _items) {
      item.checked = false;
    }
    widget.callbacks.onChanged?.call(widget.spec.allowMultiple ? [] : null);
    setState(() {});
  }

  void _invertSelection() {
    if (!widget.spec.allowMultiple) return;

    for (final item in _items) {
      item.checked = !item.checked;
    }
    final checkedValues = _items.where((i) => i.checked).map((i) => i.value).toList();
    widget.callbacks.onChanged?.call(checkedValues);
    setState(() {});
  }

  void _showChecklistDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.spec.label ?? 'Select Items'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.spec.allowMultiple) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(onPressed: _selectAll, icon: const Icon(Icons.check), label: const Text('All')),
                      TextButton.icon(onPressed: _selectNone, icon: const Icon(Icons.close), label: const Text('None')),
                      TextButton.icon(onPressed: _invertSelection, icon: const Icon(Icons.swap_horiz), label: const Text('Invert')),
                    ],
                  ),
                  const Divider(),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return CheckboxListTile(
                        value: item.checked,
                        title: Row(
                          children: [
                            if (item.icon != null) ...[Icon(item.icon, size: 20), const SizedBox(width: 8)],
                            Expanded(child: Text(item.label)),
                          ],
                        ),
                        secondary: widget.spec.showValue ? Text(item.value.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 12)) : null,
                        onChanged: widget.spec.readOnly
                            ? null
                            : (checked) {
                                _toggleItem(index);
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
        );
      },
    );
  }

  String _getSummary() {
    final checkedItems = _items.where((i) => i.checked).toList();

    if (checkedItems.isEmpty) {
      return widget.spec.hint ?? 'Select items';
    }

    if (checkedItems.length <= 3) {
      return checkedItems.map((i) => i.label).join(', ');
    }

    return '${checkedItems.length} selected';
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = Row(
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
            onPressed: widget.callbacks.onLeftPressed,
          ),
        Expanded(
          child: GestureDetector(
            onTap: widget.spec.readOnly ? null : _showChecklistDialog,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.spec.label,
                hintText: widget.spec.hint ?? 'Select items',
                suffixIcon: widget.spec.allowMultiple
                    ? IconButton(
                        icon: Icon(widget.spec.rightIcon ?? Icons.list),
                        tooltip: widget.spec.rightTooltip ?? 'Show checklist',
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: widget.spec.readOnly ? null : _showChecklistDialog,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _getSummary(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: checkedCount > 0 ? null : Colors.grey[600]),
                    ),
                  ),
                  if (widget.spec.allowMultiple)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: checkedCount > 0 ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                      child: Text('$checkedCount/${_items.length}', style: TextStyle(fontSize: 12, color: checkedCount > 0 ? Theme.of(context).primaryColor : Colors.grey[600])),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.spec.width != null) {
      fieldBody = SizedBox(width: widget.spec.width, child: fieldBody);
    }
    return fieldBody;
  }

  int get checkedCount => _items.where((i) => i.checked).length;
}

/// Spec for [UwFieldChecklist].
class UwFieldChecklistSpec {
  const UwFieldChecklistSpec({
    this.label,
    this.hint,
    this.width,
    this.value,
    this.readOnly = false,
    this.allowMultiple = false,
    this.items,
    this.itemLabelBuilder,
    this.showValue = false,
    this.leftIcon,
    this.leftTooltip,
    this.rightIcon,
    this.rightTooltip,
  });

  final String? label;
  final String? hint;
  final double? width;
  final dynamic value; // dynamic (single) or List<dynamic> (multiple)
  final bool readOnly;
  final bool allowMultiple;
  final List<dynamic>? items;
  final String Function(dynamic)? itemLabelBuilder;
  final bool showValue;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
}
