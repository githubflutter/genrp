import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';

class ActionCenterBar extends StatelessWidget {
  const ActionCenterBar({
    this.bodySpec,
    this.actionCenters,
    required this.autopilot,
    this.payload,
    this.keyPrefix = 'action-center',
    super.key,
  }) : assert(bodySpec != null || actionCenters != null);

  final UxTemplateSpec? bodySpec;
  final Iterable<UxActionCenterSpec>? actionCenters;
  final Autopilot autopilot;
  final dynamic payload;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final centers =
        actionCenters?.toList(growable: false) ??
        bodySpec!.actionCenters.values.toList(growable: false);
    if (centers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: centers
          .map((center) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (center.label.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        center.label,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: center.actionIds
                        .map((actionId) {
                          final label = autopilot.actionLabelForId(actionId);
                          return FilledButton.tonal(
                            key: ValueKey('$keyPrefix-${center.id}-$actionId'),
                            onPressed: autopilot.hasAction(actionId)
                                ? () => autopilot.triggerActionById(
                                    actionId,
                                    payload,
                                  )
                                : null,
                            child: Text(
                              label.isEmpty ? 'Action $actionId' : label,
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
