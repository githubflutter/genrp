import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';

class XButton extends StatelessWidget {
  const XButton({required this.node, required this.autopilot, super.key});

  final UxNodeSpec node;
  final Autopilot autopilot;

  bool get _isSelected => autopilot.isSelectedUxIdentity(
    hostId: node.hostId,
    bodyId: node.bodyId,
    widgetId: node.widgetId,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = ElevatedButton(
      onPressed: node.actionId == 0
          ? null
          : () => autopilot.triggerActionById(node.actionId),
      child: Text(node.text.isEmpty ? 'Action' : node.text),
    );

    return Padding(
      key: ValueKey('x-button-${node.hostId}-${node.bodyId}-${node.widgetId}'),
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: _isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: _isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
          child: GestureDetector(
            onLongPress: kDebugMode
                ? () => autopilot.selectUxIdentity(
                    hostId: node.hostId,
                    bodyId: node.bodyId,
                    widgetId: node.widgetId,
                  )
                : null,
            child: button,
          ),
        ),
      ),
    );
  }
}
