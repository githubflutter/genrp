import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/model/uschema/ux_field_spec.dart';
import 'package:genrp/core/model/uschema/ux_spec.dart';
import 'package:genrp/core/ux/ux.dart';

class GenUx {
  GenUx._();

  static Widget build({
    required UxSpec spec,
    required Autopilot autopilot,
    String? optionalId,
  }) {
    return switch (UxLayer.fromCode(spec.l)) {
      UxLayer.paper => _buildPaper(spec: spec, autopilot: autopilot, optionalId: optionalId),
      UxLayer.template => _buildTemplate(spec: spec, autopilot: autopilot, optionalId: optionalId),
      _ => const SizedBox.shrink(),
    };
  }

  static Widget _buildPaper({
    required UxSpec spec,
    required Autopilot autopilot,
    String? optionalId,
  }) {
    final templateSpec = spec.firstChildOfLayerInUxZone(UxLayer.template, uxzone: UxZone.content);
    final StatelessWidget template = templateSpec == null
        ? Container()
        : _buildTemplate(
            spec: templateSpec,
            autopilot: autopilot,
            optionalId: optionalId,
          );

    return switch (spec.t) {
      0 => Pzero(i: spec.i, autopilot: autopilot, s: spec.style, child: template),
      1 => Pone(i: spec.i, autopilot: autopilot, s: spec.style, child: template),
      2 => Ptwo(i: spec.i, autopilot: autopilot, s: spec.style, left: template, right: template),
      3 => Pthree(i: spec.i, autopilot: autopilot, s: spec.style, first: template, middle: template, last: template),
      4 => Pfour(i: spec.i, autopilot: autopilot, s: spec.style),
      _ => Pzero(i: spec.i, autopilot: autopilot, s: spec.style, child: template),
    };
  }

  static StatelessWidget _buildTemplate({
    required UxSpec spec,
    required Autopilot autopilot,
    String? optionalId,
  }) {
    switch (spec.t) {
      case 1:
        final workspace = spec.workspaceMeta();
        final topToolbarSpec = _firstUwidgetOfType(spec, UxZone.header, 4);
        final bottomToolbarSpec = _firstUwidgetOfType(spec, UxZone.footer, 4);
        final collectionSpec = _firstUwidgetOfType(spec, UxZone.collection, 12);
        final plistSpec = _firstUwidgetOfType(spec, UxZone.detail, 6);
        final formSpec = _firstUwidgetOfType(spec, UxZone.detail, 5);
        final emptySpec = _firstUwidgetOfType(spec, UxZone.feedback, 9);
        final alertSpec = _firstUwidgetOfType(spec, UxZone.feedback, 11);
        return Tworkspace(
          i: spec.i,
          autopilot: autopilot,
          s: spec.style,
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
          topToolbarI: topToolbarSpec?.i,
          topToolbarStyle: topToolbarSpec?.style,
          bottomToolbarI: bottomToolbarSpec?.i,
          bottomToolbarStyle: bottomToolbarSpec?.style,
          collectionI: collectionSpec?.i,
          collectionStyle: collectionSpec?.style,
          plistI: plistSpec?.i,
          plistStyle: plistSpec?.style,
          formI: formSpec?.i,
          formStyle: formSpec?.style,
          emptyI: emptySpec?.i,
          emptyStyle: emptySpec?.style,
          alertI: alertSpec?.i,
          alertStyle: alertSpec?.style,
        );
      case 2:
        return Tsheet(i: spec.i, autopilot: autopilot, s: spec.style);
      case 3:
        return Treport(i: spec.i, autopilot: autopilot, s: spec.style);
      case 4:
        return Tdboard(i: spec.i, autopilot: autopilot, s: spec.style);
      case 5:
        return Twizard(i: spec.i, autopilot: autopilot, s: spec.style);
      case 6:
        return Tform(i: spec.i, autopilot: autopilot, s: spec.style);
      default:
        return Tform(i: spec.i, autopilot: autopilot, s: spec.style);
    }
  }

  static List<Widget> _buildFormFields(List<UxFieldSpec> fields, Autopilot autopilot) {
    return fields
        .map<Widget>(
          (UxFieldSpec field) => UwField(
            i: 0,
            autopilot: autopilot,
            spec: field.toUwFieldSpec(),
          ),
        )
        .toList(growable: false);
  }

  static UxSpec? _firstUwidgetOfType(UxSpec spec, String uxzone, int type) {
    for (final child in spec.childrenInUxZone(uxzone)) {
      if (UxLayer.fromCode(child.l) == UxLayer.uwidget && child.t == type) {
        return child;
      }
    }
    return null;
  }

  static Widget? _buildFormFooter(List<UxTemplateActionSpec> actions) {
    final visibleActions = actions.where((action) => action.visible).toList(growable: false);
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
