import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/ux/ux_checkbox_model.dart';

class XCheckBox extends StatelessWidget {
  const XCheckBox({
    required this.model,
    required this.autopilot,
    super.key,
  });

  final UxCheckBoxModel model;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    final currentValue = autopilot.resolveFieldBinding(
      src: model.src,
      fieldId: model.fieldId,
      fallbackPath: model.bind,
    );
    final checked = currentValue is bool ? currentValue : false;

    return CheckboxListTile(
      value: checked,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(model.n),
      onChanged: (value) => autopilot.updateFieldBinding(
        src: model.src,
        fieldId: model.fieldId,
        fallbackPath: model.bind,
        value: value ?? false,
      ),
    );
  }
}
