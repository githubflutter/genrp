import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/ux/ux_button_model.dart';

class XButton extends StatelessWidget {
  const XButton({required this.model, required this.autopilot, super.key});

  final UxButtonModel model;
  final Autopilot autopilot;

  bool get _isSelected => autopilot.isSelectedUxIdentity(
    hostId: model.hostId,
    bodyId: model.bodyId,
    widgetId: model.i,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = ElevatedButton(
      onPressed: model.actionId != 0
          ? () => autopilot.triggerActionById(model.actionId)
          : model.actionName.isEmpty
          ? null
          : () => autopilot.triggerAction(model.actionName),
      child: Text(model.n.isEmpty ? 'Action' : model.n),
    );

    return Padding(
      key: ValueKey('x-button-${model.hostId}-${model.bodyId}-${model.i}'),
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
                      hostId: model.hostId,
                      bodyId: model.bodyId,
                      widgetId: model.i,
                    )
                : null,
            child: button,
          ),
        ),
      ),
    );
  }
}
