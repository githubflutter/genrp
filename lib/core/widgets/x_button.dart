import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/ux/ux_button_model.dart';

class XButton extends StatelessWidget {
  const XButton({
    required this.model,
    required this.autopilot,
    super.key,
  });

  final UxButtonModel model;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ElevatedButton(
        onPressed: model.actionId != 0
            ? () => autopilot.triggerActionById(model.actionId)
            : model.actionName.isEmpty
                ? null
                : () => autopilot.triggerAction(model.actionName),
        child: Text(model.n.isEmpty ? 'Action' : model.n),
      ),
    );
  }
}
