import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/runtime/template_runtime.dart';

class DetailTemplate extends StatelessWidget {
  const DetailTemplate({
    required this.bodySpec,
    required this.autopilot,
    super.key,
  });

  final Map<String, dynamic> bodySpec;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    const runtime = TemplateRuntime();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: runtime.render(bodySpec, autopilot),
        ),
      ),
    );
  }
}
