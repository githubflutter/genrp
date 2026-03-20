import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';

class XCheckBox extends StatelessWidget {
  const XCheckBox({required this.node, required this.autopilot, super.key});

  final UxNodeSpec node;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentValue = autopilot.resolveFieldBinding(
      src: node.src,
      fieldId: node.fieldId,
      fallbackPath: node.bind,
    );
    final checked = currentValue is bool ? currentValue : false;
    final isSelected = autopilot.isSelectedUxIdentity(
      hostId: node.hostId,
      bodyId: node.bodyId,
      widgetId: node.widgetId,
    );

    return DecoratedBox(
      key: ValueKey(
        'x-checkbox-${node.hostId}-${node.bodyId}-${node.widgetId}',
      ),
      decoration: BoxDecoration(
        border: isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
        child: GestureDetector(
          onLongPress: kDebugMode
              ? () => autopilot.selectUxIdentity(
                  hostId: node.hostId,
                  bodyId: node.bodyId,
                  widgetId: node.widgetId,
                )
              : null,
          child: CheckboxListTile(
            value: checked,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(node.label.isEmpty ? node.n : node.label),
            onChanged: (value) => autopilot.updateFieldBinding(
              src: node.src,
              fieldId: node.fieldId,
              fallbackPath: node.bind,
              value: value ?? false,
            ),
          ),
        ),
      ),
    );
  }
}
