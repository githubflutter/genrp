import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_registry.dart';
import 'package:genrp/core/model/uschema/ux_spec_mapper.dart';
import 'package:genrp/core/runtime/template_runtime.dart';
import 'package:genrp/core/widgets/x_checkbox.dart';

class CheckboxFormTemplate extends StatelessWidget {
  const CheckboxFormTemplate({
    required this.bodySpec,
    required this.autopilot,
    super.key,
  });

  final Map<String, dynamic> bodySpec;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    const runtime = TemplateRuntime();
    const mapper = UxSpecMapper();
    final registry = UxRegistry.fromSpec(bodySpec);
    final hostId = (bodySpec['hostId'] as num?)?.toInt() ?? 0;
    final bodyId = (bodySpec['bodyId'] as num?)?.toInt() ?? 0;
    final checkboxSpec = Map<String, dynamic>.from(bodySpec['checkbox'] as Map? ?? const {});
    final checkboxModel = checkboxSpec.isEmpty
        ? null
        : mapper.checkBoxFromNode(checkboxSpec, hostId: hostId, bodyId: bodyId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (checkboxModel != null)
                XCheckBox(
                  model: checkboxModel,
                  autopilot: autopilot,
                ),
              runtime.render(bodySpec, autopilot, registry: registry, hostId: hostId, bodyId: bodyId),
            ],
          ),
        ),
      ),
    );
  }
}
