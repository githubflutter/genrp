import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

/// Dedicated boolean toggle field widget.
///
/// Use this directly for better performance when you know you need bool mode,
/// or use [UwField] with [UwFieldMode.bool_] for mode-dispatched convenience.
class UwFieldBool extends StatefulWidget with Uwidget {
  const UwFieldBool({
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
  final String n = 'field_bool';

  final Autopilot autopilot;
  final UwFieldBoolSpec spec;
  final UwFieldCallbacks callbacks;

  @override
  State<UwFieldBool> createState() => _UwFieldBoolState();
}

class _UwFieldBoolState extends State<UwFieldBool> {
  bool get _boolValue => widget.spec.value == true;

  void _toggleBool() {
    widget.callbacks.onChanged?.call(!_boolValue);
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldBody = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.spec.leftIcon != null) _buildLeftButton(widget.spec.leftIcon!, widget.spec.leftTooltip),
        Expanded(
          child: GestureDetector(
            onTap: widget.spec.readOnly ? null : _toggleBool,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.spec.label,
                hintText: widget.spec.hint,
                suffixIcon: IconButton(
                  icon: Icon(_boolValue ? Icons.check_box : Icons.check_box_outline_blank),
                  tooltip: widget.spec.rightTooltip ?? 'Toggle',
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.spec.readOnly ? null : _toggleBool,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    _boolValue ? 'Yes' : 'No',
                    style: const TextStyle(fontSize: 14),
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

  Widget _buildLeftButton(IconData icon, String? tooltip) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 16,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: widget.callbacks.onLeftPressed,
    );
  }
}

/// Spec for [UwFieldBool] - lighter weight than full [UwFieldSpec].
class UwFieldBoolSpec {
  const UwFieldBoolSpec({
    this.label,
    this.hint,
    this.width,
    this.value,
    this.readOnly = false,
    this.leftIcon,
    this.leftTooltip,
    this.rightTooltip,
  });

  final String? label;
  final String? hint;
  final double? width;
  final bool? value;
  final bool readOnly;
  final IconData? leftIcon;
  final String? leftTooltip;
  final String? rightTooltip;
}
