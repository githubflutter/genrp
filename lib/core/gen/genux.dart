import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_specs.dart';
import 'package:genrp/core/ux/ux.dart';

class GenUx {
  GenUx._();
  static Widget buildPaper({required UxPaperSpec spec, required Autopilot autopilot, String? optionalId}) {
    final template = buildTemplate(spec: spec.template, autopilot: autopilot, optionalId: optionalId);

    return switch (spec.pid) {
      0 => Pzero(i: spec.i, autopilot: autopilot, s: spec.s, child: template),
      1 => Pone(i: spec.i, autopilot: autopilot, s: spec.s, child: template),
      2 => Ptwo(i: spec.i, autopilot: autopilot, s: spec.s, left: template, right: template),
      3 => Pthree(i: spec.i, autopilot: autopilot, s: spec.s, first: template, middle: template, last: template),
      4 => Pfour(i: spec.i, autopilot: autopilot, s: spec.s),
      _ => Pzero(i: spec.i, autopilot: autopilot, s: spec.s, child: template),
    };
  }

  static StatelessWidget buildTemplate({required UxTemplateSpec spec, required Autopilot autopilot, String? optionalId}) {
    switch (spec.tid) {
      case 1:
        final workspace = spec as UxWorkspaceTemplateSpec;
        return Tworkspace(
          i: workspace.i,
          autopilot: autopilot,
          s: workspace.s,
          oid: optionalId ?? '-',
          summaryText: workspace.summaryText,
          collectionTitle: workspace.collectionTitle,
          collectionColumns: workspace.collectionColumns,
          collectionRows: workspace.collectionRows,
          collectionViewModes: workspace.collectionViewModes,
          properties: workspace.properties,
          actions: workspace.actions,
          actionHolders: workspace.actionHolders,
          formChildren: _buildFormFields(workspace.formFields, autopilot),
          formFooter: _buildFormFooter(workspace.actions),
          emptyTitle: workspace.emptyTitle,
          emptyMessage: workspace.emptyMessage,
          defaultAlertMessage: workspace.defaultAlertMessage,
          collectionFlex: workspace.collectionFlex,
          detailFlex: workspace.detailFlex,
        );
      case 2:
        return Tsheet(i: spec.i, autopilot: autopilot, s: spec.s);
      case 3:
        return Treport(i: spec.i, autopilot: autopilot, s: spec.s);
      case 4:
        return Tdboard(i: spec.i, autopilot: autopilot, s: spec.s);
      case 5:
        return Twizard(i: spec.i, autopilot: autopilot, s: spec.s);
      case 6:
        return Tform(i: spec.i, autopilot: autopilot, s: spec.s);
      default:
        return Tform(i: spec.i, autopilot: autopilot, s: spec.s);
    }
  }

  static List<Widget> _buildFormFields(List<UxFieldSpec> fields, Autopilot autopilot) {
    return fields
        .map<Widget>(
          (UxFieldSpec field) => UwField(
            i: 0, // Since inline form fields don't have explicit widget IDs in the current design
            autopilot: autopilot,
            spec: UwFieldSpec(
              label: field.label,
              hint: field.hint,
              width: field.width,
              dataTypeId: field.dataTypeId,
              mode: field.fieldMode,
            ),
          ),
        )
        .toList(growable: false);
  }

  static Widget? _buildFormFooter(List<UxTemplateActionSpec> actions) {
    final List<UxTemplateActionSpec> visibleActions = actions
        .where((UxTemplateActionSpec action) => action.visible)
        .toList(growable: false);
    if (visibleActions.isEmpty) return null;

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        children: visibleActions.map<Widget>(_buildActionButton).toList(growable: false),
      ),
    );
  }

  static Widget _buildActionButton(UxTemplateActionSpec action) {
    final VoidCallback? onPressed = action.enabled ? () {} : null;
    switch (action.action) {
      case UxTemplateAction.commit:
        return FilledButton(onPressed: onPressed, child: Text(action.effectiveLabel));
      case UxTemplateAction.cancel:
        return OutlinedButton(onPressed: onPressed, child: Text(action.effectiveLabel));
      case UxTemplateAction.refetch:
      case UxTemplateAction.share:
        return TextButton(onPressed: onPressed, child: Text(action.effectiveLabel));
    }
  }
}
