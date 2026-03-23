import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';
import 'package:genrp/core/ux/uwidget/uwfields/uwfield_datetime.dart';

/// Date range picker widget.
/// Value: `List<int>` with 2 values [start, end] (epoch milliseconds)
class UwFieldDateRange extends StatefulWidget with Ux {
  const UwFieldDateRange({required this.i, required this.autopilot, required this.spec, this.callbacks = const UwFieldCallbacks(), this.s = 0, super.key});

  final int uwid = 14;
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_daterange';

  final Autopilot autopilot;
  final UwFieldDateRangeSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldDateRange> createState() => _UwFieldDateRangeState();
}

class _UwFieldDateRangeState extends State<UwFieldDateRange> {
  @override
  Widget build(BuildContext context) {
    return UwFieldDateTimeBase(
      i: widget.i,
      autopilot: widget.autopilot,
      label: widget.spec.label,
      hint: widget.spec.hint,
      width: widget.spec.width,
      value: widget.spec.value,
      readOnly: widget.spec.readOnly,
      firstDate: widget.spec.firstDate,
      lastDate: widget.spec.lastDate,
      leftIcon: widget.spec.leftIcon,
      leftTooltip: widget.spec.leftTooltip,
      rightIcon: widget.spec.rightIcon,
      rightTooltip: widget.spec.rightTooltip,
      pickerType: PickerType.daterange,
    );
  }
}

/// Spec for [UwFieldDateRange].
class UwFieldDateRangeSpec {
  const UwFieldDateRangeSpec({this.label, this.hint, this.width, this.value, this.readOnly = false, this.firstDate, this.lastDate, this.leftIcon, this.leftTooltip, this.rightIcon, this.rightTooltip});

  final String? label;
  final String? hint;
  final double? width;
  final List<int>? value; // [startMs, endMs]
  final bool readOnly;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
}
