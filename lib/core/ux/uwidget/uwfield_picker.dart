import 'package:flutter/material.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

class UwFieldPicker extends StatefulWidget {
  const UwFieldPicker({
    required this.spec,
    required this.callbacks,
    required this.controller,
    required this.isDatetime,
    super.key,
  });

  final UwFieldSpec spec;
  final UwFieldCallbacks callbacks;
  final TextEditingController controller;
  final bool isDatetime;

  @override
  State<UwFieldPicker> createState() => _UwFieldPickerState();
}

class _UwFieldPickerState extends State<UwFieldPicker> {
  Future<void> _pickDate() async {
    final DateTime initialDate;
    if (widget.spec.value != null && widget.spec.value is int) {
      initialDate = DateTime.fromMillisecondsSinceEpoch(widget.spec.value as int);
    } else {
      initialDate = DateTime.now();
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    if (widget.isDatetime) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (time == null) return;

      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _updateValue(combined);
    } else {
      _updateValue(date);
    }
  }

  void _updateValue(DateTime dt) {
    final ms = dt.millisecondsSinceEpoch;
    widget.callbacks.onChanged?.call(ms);
  }

  @override
  void didUpdateWidget(covariant UwFieldPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec.value != oldWidget.spec.value) {
      _syncText();
    }
  }

  @override
  void initState() {
    super.initState();
    _syncText();
  }

  void _syncText() {
    if (widget.spec.value != null && widget.spec.value is int) {
      final dt = DateTime.fromMillisecondsSinceEpoch(widget.spec.value as int);
      // Fallback simple format, usually a real DateFormat is better if we imported intl
      final year = dt.year.toString().padLeft(4, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      if (widget.isDatetime) {
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        widget.controller.text = '$year-$month-$day $hour:$minute';
      } else {
        widget.controller.text = '$year-$month-$day';
      }
    } else {
      widget.controller.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onTap: widget.spec.readOnly ? null : _pickDate,
            child: TextField(
              controller: widget.controller,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: widget.spec.label,
                hintText: widget.spec.hint,
                suffixIcon: IconButton(
                  icon: Icon(widget.spec.rightIcon ?? Icons.calendar_today),
                  tooltip: widget.spec.rightTooltip ?? 'Pick',
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.spec.readOnly ? null : _pickDate,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
