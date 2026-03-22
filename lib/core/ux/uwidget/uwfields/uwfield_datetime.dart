import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';

/// Base class for date/time picker widgets.
/// Handles all picking logic for single, multiple, and range dates.
class UwFieldDateTimeBase extends StatefulWidget {
  const UwFieldDateTimeBase({
    required this.i,
    required this.autopilot,
    required this.label,
    required this.hint,
    required this.width,
    required this.value,
    required this.readOnly,
    required this.firstDate,
    required this.lastDate,
    required this.leftIcon,
    required this.leftTooltip,
    required this.rightIcon,
    required this.rightTooltip,
    required this.pickerType,
    super.key,
  });

  final int i;
  final Autopilot autopilot;
  final String? label;
  final String? hint;
  final double? width;
  final dynamic value;
  final bool readOnly;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
  final PickerType pickerType;

  @override
  State<UwFieldDateTimeBase> createState() => _UwFieldDateTimeBaseState();
}

/// Picker type for date/time widgets.
enum PickerType { date, datetime, dates, datetimes, daterange, datetimerange }

class _UwFieldDateTimeBaseState extends State<UwFieldDateTimeBase> {
  Future<void> _pick() async {
    switch (widget.pickerType) {
      case PickerType.date:
        await _pickSingle(includeTime: false);
        break;
      case PickerType.datetime:
        await _pickSingle(includeTime: true);
        break;
      case PickerType.dates:
      case PickerType.datetimes:
        await _pickMultiple(includeTime: widget.pickerType == PickerType.datetimes);
        break;
      case PickerType.daterange:
        await _pickRange(includeTime: false);
        break;
      case PickerType.datetimerange:
        await _pickRange(includeTime: true);
        break;
    }
  }

  Future<void> _pickSingle({required bool includeTime}) async {
    final DateTime initialDate;
    if (widget.value != null && widget.value is int) {
      initialDate = DateTime.fromMillisecondsSinceEpoch(widget.value as int);
    } else {
      initialDate = DateTime.now();
    }

    final date = await showDatePicker(context: context, initialDate: initialDate, firstDate: widget.firstDate ?? DateTime(1900), lastDate: widget.lastDate ?? DateTime(2100));

    if (date == null || !mounted) return;

    if (includeTime) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initialDate));
      if (time == null || !mounted) return;
      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _updateValue(combined.millisecondsSinceEpoch);
    } else {
      _updateValue(DateTime(date.year, date.month, date.day).millisecondsSinceEpoch);
    }
  }

  Future<void> _pickMultiple({required bool includeTime}) async {
    final existingDates = _getExistingDates();
    final result = await showDialog<List<DateTime>>(
      context: context,
      builder: (BuildContext context) {
        return _MultipleDateDialog(existingDates: existingDates, includeTime: includeTime);
      },
    );

    if (result == null || !mounted) return;
    _updateValue(result.map((d) => d.millisecondsSinceEpoch).toList());
  }

  Future<void> _pickRange({required bool includeTime}) async {
    final DateTimeRange? initialRange;
    if (widget.value is List && (widget.value as List).length >= 2) {
      final start = DateTime.fromMillisecondsSinceEpoch((widget.value as List)[0] as int);
      final end = DateTime.fromMillisecondsSinceEpoch((widget.value as List)[1] as int);
      initialRange = DateTimeRange(start: start, end: end);
    } else {
      initialRange = null;
    }

    if (includeTime) {
      final startDate = await showDatePicker(
        context: context,
        initialDate: initialRange?.start ?? DateTime.now(),
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: widget.lastDate ?? DateTime(2100),
      );
      if (startDate == null || !mounted) return;

      final startTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initialRange?.start ?? DateTime.now()));
      if (startTime == null || !mounted) return;

      final endDate = await showDatePicker(context: context, initialDate: initialRange?.end ?? startDate, firstDate: widget.firstDate ?? DateTime(1900), lastDate: widget.lastDate ?? DateTime(2100));
      if (endDate == null || !mounted) return;

      final endTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initialRange?.end ?? endDate));
      if (endTime == null || !mounted) return;

      final startCombined = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
      final endCombined = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);

      if (endCombined.isBefore(startCombined)) {
        _updateValue([endCombined.millisecondsSinceEpoch, startCombined.millisecondsSinceEpoch]);
      } else {
        _updateValue([startCombined.millisecondsSinceEpoch, endCombined.millisecondsSinceEpoch]);
      }
    } else {
      if (!mounted) return;
      final range = await showDateRangePicker(context: context, firstDate: widget.firstDate ?? DateTime(1900), lastDate: widget.lastDate ?? DateTime(2100), initialDateRange: initialRange);
      if (range == null || !mounted) return;

      final start = DateTime(range.start.year, range.start.month, range.start.day);
      final end = DateTime(range.end.year, range.end.month, range.end.day);
      _updateValue([start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    }
  }

  List<DateTime> _getExistingDates() {
    if (widget.value is List) {
      return (widget.value as List).map((e) => DateTime.fromMillisecondsSinceEpoch(e as int)).toList();
    }
    return [];
  }

  void _updateValue(dynamic epochValue) {
    // Callback will be provided by parent widget
  }

  String _formatValue() {
    final value = widget.value;
    if (value == null) return '';

    if (value is List) {
      if (value.isEmpty) return '';
      if (widget.pickerType == PickerType.daterange || widget.pickerType == PickerType.datetimerange) {
        if (value.length >= 2) {
          final start = DateTime.fromMillisecondsSinceEpoch(value[0] as int);
          final end = DateTime.fromMillisecondsSinceEpoch(value[1] as int);
          return '${_formatSingle(start)} → ${_formatSingle(end)}';
        }
        return _formatSingle(DateTime.fromMillisecondsSinceEpoch(value[0] as int));
      } else {
        if (value.length > 3) return '${value.length} dates selected';
        return value.map((e) => _formatSingle(DateTime.fromMillisecondsSinceEpoch(e as int))).join(', ');
      }
    }

    return _formatSingle(DateTime.fromMillisecondsSinceEpoch(value as int));
  }

  String _formatSingle(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    if (widget.pickerType == PickerType.datetime || widget.pickerType == PickerType.datetimes || widget.pickerType == PickerType.datetimerange) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute';
    }
    return '$year-$month-$day';
  }

  String _getHint() {
    switch (widget.pickerType) {
      case PickerType.date:
        return 'Select date';
      case PickerType.datetime:
        return 'Select date and time';
      case PickerType.dates:
        return 'Select multiple dates';
      case PickerType.datetimes:
        return 'Select multiple dates and times';
      case PickerType.daterange:
        return 'Select date range';
      case PickerType.datetimerange:
        return 'Select date and time range';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.leftIcon != null)
          IconButton(
            icon: Icon(widget.leftIcon),
            tooltip: widget.leftTooltip,
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {},
          ),
        Expanded(
          child: GestureDetector(
            onTap: widget.readOnly ? null : _pick,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint ?? _getHint(),
                suffixIcon: IconButton(
                  icon: Icon(widget.rightIcon ?? Icons.calendar_today),
                  tooltip: widget.rightTooltip ?? 'Pick',
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.readOnly ? null : _pick,
                ),
              ),
              child: Text(_formatValue()),
            ),
          ),
        ),
      ],
    );

    if (widget.width != null) {
      fieldBody = SizedBox(width: widget.width, child: fieldBody);
    }
    return fieldBody;
  }
}

/// Dialog for picking multiple dates
class _MultipleDateDialog extends StatefulWidget {
  const _MultipleDateDialog({required this.existingDates, required this.includeTime});

  final List<DateTime> existingDates;
  final bool includeTime;

  @override
  State<_MultipleDateDialog> createState() => _MultipleDateDialogState();
}

class _MultipleDateDialogState extends State<_MultipleDateDialog> {
  late List<DateTime> _selectedDates;

  @override
  void initState() {
    super.initState();
    _selectedDates = List.from(widget.existingDates);
  }

  Future<void> _addDate() async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (date == null || !mounted) return;

    if (widget.includeTime) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) {
        setState(() => _selectedDates.add(DateTime(date.year, date.month, date.day, time.hour, time.minute)));
      }
    } else {
      setState(() => _selectedDates.add(DateTime(date.year, date.month, date.day)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.includeTime ? 'Select Dates & Times' : 'Select Dates'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedDates.isEmpty)
              const Text('No dates selected')
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _selectedDates.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_selectedDates[index].toString()),
                      trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedDates.removeAt(index))),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _addDate, icon: const Icon(Icons.add), label: const Text('Add Date')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(_selectedDates), child: const Text('Done')),
      ],
    );
  }
}
