import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/template/checkbox_form_template.dart';
import 'package:genrp/core/template/collection_template.dart';
import 'package:genrp/core/template/detail_template.dart';
import 'package:genrp/core/template/form_template.dart';

/// Generator/router that selects the current template from JSON.
class DynamicSpecBody extends StatelessWidget {
  const DynamicSpecBody({required this.spec, required this.autopilot, super.key});

  final Map<String, dynamic> spec;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    final initialBody = spec['initialBody']?.toString() ?? 'editor';
    final currentBody = autopilot.resolve('ux.currentBody')?.toString() ?? initialBody;
    final bodies = Map<String, dynamic>.from(spec['bodies'] as Map? ?? const {});
    final bodySpec = Map<String, dynamic>.from(bodies[currentBody] as Map? ?? const {});
    final template = bodySpec['template']?.toString() ?? 'basic';

    switch (template) {
      case 'checkboxForm':
        return CheckboxFormTemplate(bodySpec: bodySpec, autopilot: autopilot);
      case 'collection':
        return CollectionTemplate(bodySpec: bodySpec, autopilot: autopilot);
      case 'detail':
        return DetailTemplate(bodySpec: bodySpec, autopilot: autopilot);
      case 'form':
        return FormTemplate(bodySpec: bodySpec, autopilot: autopilot);
      case 'basic':
      default:
        return FormTemplate(bodySpec: bodySpec, autopilot: autopilot);
    }
  }
}
