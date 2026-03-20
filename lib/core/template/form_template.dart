import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';
import 'package:genrp/core/runtime/template_runtime.dart';
import 'package:genrp/core/template/action_center_bar.dart';

class FormTemplate extends StatelessWidget {
  const FormTemplate({
    required this.bodySpec,
    required this.autopilot,
    super.key,
  });

  final UxTemplateSpec bodySpec;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    const runtime = TemplateRuntime();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ActionCenterBar(bodySpec: bodySpec, autopilot: autopilot),
              runtime.render(bodySpec.root, autopilot),
            ],
          ),
        ),
      ),
    );
  }
}
