import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/runtime/template_runtime.dart';

class CollectionTemplate extends StatelessWidget {
  const CollectionTemplate({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((bodySpec['title']?.toString() ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                bodySpec['title'].toString(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          runtime.render(bodySpec, autopilot),
        ],
      ),
    );
  }
}
