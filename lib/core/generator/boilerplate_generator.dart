import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_document_spec.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';
import 'package:genrp/core/template/checkbox_form_template.dart';
import 'package:genrp/core/template/collection_template.dart';
import 'package:genrp/core/template/detail_template.dart';
import 'package:genrp/core/template/form_template.dart';

/// Generator/router that selects the current template from JSON.
class DynamicSpecBody extends StatelessWidget {
  const DynamicSpecBody({
    required this.spec,
    required this.autopilot,
    super.key,
  });

  final dynamic spec;
  final Autopilot autopilot;

  @override
  Widget build(BuildContext context) {
    final document = spec is UxSpecDocument
        ? spec as UxSpecDocument
        : UxSpecDocument.fromJson(Map<String, dynamic>.from(spec as Map));
    final currentBodyValue =
        autopilot.resolve('ux.currentBody') ?? document.initialBody;
    final bodySpec = document.resolveBody(currentBodyValue);
    if (bodySpec == null) {
      return const SizedBox.shrink();
    }

    switch (bodySpec.templateTypeId) {
      case UxTemplateType.checkboxForm:
        return CheckboxFormTemplate(bodySpec: bodySpec, autopilot: autopilot);
      case UxTemplateType.collection:
        return CollectionTemplate(bodySpec: bodySpec, autopilot: autopilot);
      case UxTemplateType.detail:
        return DetailTemplate(bodySpec: bodySpec, autopilot: autopilot);
      case UxTemplateType.form:
        return FormTemplate(bodySpec: bodySpec, autopilot: autopilot);
      default:
        return _TemplateErrorPanel(
          message: 'Unknown template type ${bodySpec.templateTypeId}',
        );
    }
  }
}

class _TemplateErrorPanel extends StatelessWidget {
  const _TemplateErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
