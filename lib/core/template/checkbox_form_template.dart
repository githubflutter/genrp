import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/runtime/template_runtime.dart';
import 'package:genrp/core/ux/bound_checkbox.dart';

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
    final checkboxSpec = Map<String, dynamic>.from(bodySpec['checkbox'] as Map? ?? const {});

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (checkboxSpec.isNotEmpty)
                BoundCheckbox(
                  autopilot: autopilot,
                  bind: checkboxSpec['bind']?.toString() ?? '',
                  label: checkboxSpec['label']?.toString() ?? 'Enabled',
                ),
              runtime.render(bodySpec, autopilot),
            ],
          ),
        ),
      ),
    );
  }
}
