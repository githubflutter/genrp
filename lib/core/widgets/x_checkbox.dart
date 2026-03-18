import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/ux/ux_checkbox_model.dart';

class XCheckBox extends StatelessWidget {
  const XCheckBox({required this.model, required this.autopilot, super.key});

  final UxCheckBoxModel model;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentValue = autopilot.resolveFieldBinding(
      src: model.src,
      fieldId: model.fieldId,
      fallbackPath: model.bind,
    );
    final checked = currentValue is bool ? currentValue : false;
    final isSelected = autopilot.isSelectedUxIdentity(
      hostId: model.hostId,
      bodyId: model.bodyId,
      widgetId: model.i,
    );

    return DecoratedBox(
      key: ValueKey('x-checkbox-${model.hostId}-${model.bodyId}-${model.i}'),
      decoration: BoxDecoration(
        border: isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
        child: CheckboxListTile(
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
        ),
      ),
    );
  }
}
