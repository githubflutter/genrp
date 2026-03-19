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

    final bodies = Map<String, dynamic>.from(spec['bodies'] as Map? ?? const {});

    Map<String, dynamic> bodySpec = {};

    // 1. Try numeric resolution first (Primary Path)
    if (currentBodyValue is num) {
      final targetId = currentBodyValue.toInt();
      for (final value in bodies.values) {
        if (value is Map && value['bodyId'] == targetId) {
          bodySpec = Map<String, dynamic>.from(value);
          break;
        }
      }
    }

    // 2. Fallback to string lookup
    if (bodySpec.isEmpty && currentBodyValue != null) {
      final currentBodyStr = currentBodyValue.toString();
      bodySpec = Map<String, dynamic>.from(bodies[currentBodyStr] as Map? ?? const {});
    }

    // 3. If still empty, try initialBody string fallback
    if (bodySpec.isEmpty && initialBodyValue != null) {
      final initialBodyStr = initialBodyValue.toString();
      bodySpec = Map<String, dynamic>.from(bodies[initialBodyStr] as Map? ?? const {});
    }

    // 4. Default to empty if nothing matched
    final resolvedBodySpec = <String, dynamic>{
      ...spec,
      ...bodySpec,
    };

    // Template resolution: numeric-first, string fallback
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
