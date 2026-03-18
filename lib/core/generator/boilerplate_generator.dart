import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/ux/ux_registry.dart';
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
    final registry = UxRegistry.fromSpec(spec);
    final initialBodyValue = spec['initialBody'];
    final currentBodyValue = autopilot.resolve('ux.currentBody') ?? initialBodyValue;
    final initialBody = initialBodyValue is num
        ? registry.bodyName(initialBodyValue.toInt()) ?? 'editor'
        : initialBodyValue?.toString() ?? 'editor';
    final currentBodyStr = currentBodyValue is num
        ? registry.bodyName(currentBodyValue.toInt()) ?? initialBody
        : currentBodyValue?.toString() ?? initialBody;
    final bodies = Map<String, dynamic>.from(spec['bodies'] as Map? ?? const {});

    Map<String, dynamic> bodySpec = {};
    if (currentBodyValue is num) {
      final targetId = currentBodyValue.toInt();
      for (final value in bodies.values) {
        if (value is Map && value['bodyId'] == targetId) {
          bodySpec = Map<String, dynamic>.from(value);
          break;
        }
      }
    }

    if (bodySpec.isEmpty) {
      bodySpec = Map<String, dynamic>.from(bodies[currentBodyStr] as Map? ?? const {});
    }
    final resolvedBodySpec = <String, dynamic>{
      ...spec,
      ...bodySpec,
    };
    final templateId = (bodySpec['templateId'] as num?)?.toInt();
    final template = registry.templateName(templateId) ?? bodySpec['template']?.toString() ?? 'basic';

    switch (template) {
      case 'checkboxForm':
        return CheckboxFormTemplate(bodySpec: resolvedBodySpec, autopilot: autopilot);
      case 'collection':
        return CollectionTemplate(bodySpec: resolvedBodySpec, autopilot: autopilot);
      case 'detail':
        return DetailTemplate(bodySpec: resolvedBodySpec, autopilot: autopilot);
      case 'form':
        return FormTemplate(bodySpec: resolvedBodySpec, autopilot: autopilot);
      case 'basic':
      default:
        return FormTemplate(bodySpec: resolvedBodySpec, autopilot: autopilot);
    }
  }
}
