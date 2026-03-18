import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';

class BoundCheckbox extends StatelessWidget {
  const BoundCheckbox({
    required this.autopilot,
    required this.bind,
    required this.label,
    super.key,
  });

  final Autopilot autopilot;
  final String bind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final currentValue = autopilot.resolve(bind);
    final checked = currentValue is bool ? currentValue : false;

    return CheckboxListTile(
      value: checked,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(label),
      onChanged: (value) => autopilot.updateBinding(bind, value ?? false),
    );
  }
}
