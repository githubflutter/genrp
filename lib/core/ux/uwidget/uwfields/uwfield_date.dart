import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';
import 'package:genrp/core/ux/uwidget/uwfields/uwfield_datetime.dart';

/// Single date picker widget.
/// Value: `int` (epoch milliseconds)
class UwFieldDate extends StatefulWidget with Uwidget {
  const UwFieldDate({required this.i, required this.autopilot, required this.spec, this.callbacks = const UwFieldCallbacks(), this.s = 0, super.key});

  @override
  final int vid = 14;
  @override
  final int s;
  @override
  final int i;
  @override
  final String n = 'field_date';

  final Autopilot autopilot;
  final UwFieldDateSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldDate> createState() => _UwFieldDateState();
}

class _UwFieldDateState extends State<UwFieldDate> {
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
      pickerType: PickerType.date,
    );
  }
}

/// Spec for [UwFieldDate].
class UwFieldDateSpec {
  const UwFieldDateSpec({this.label, this.hint, this.width, this.value, this.readOnly = false, this.firstDate, this.lastDate, this.leftIcon, this.leftTooltip, this.rightIcon, this.rightTooltip});

  final String? label;
  final String? hint;
  final double? width;
  final int? value;
  final bool readOnly;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;
}
