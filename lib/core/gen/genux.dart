import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
// import removed
import 'package:genrp/core/gen/uschema_compiled.dart';
import 'package:genrp/core/model/uschema/ux_field_spec.dart';
import 'package:genrp/core/ux/ux.dart';

/// Renderer for compiled unified UX schema trees.
///
/// The active render path dispatches from compiled `l` and `t`, with
/// template configuration and slot resolution already normalized before
/// rendering.
class GenUx {
  GenUx._();

  static Widget build({
    required UschemaCompiled compiled,
    required Autopilot autopilot,
    String? optionalId,
  }) {
    return switch (compiled.layer) {
      UxLayer.template => compiled.isRouteRoot
          ? _buildCompiledRootTemplate(
              compiled: compiled, autopilot: autopilot, optionalId: optionalId)
          : _buildCompiledTemplate(
              compiled: compiled,
              autopilot: autopilot,
              optionalId: optionalId,
            ),
      _ => const SizedBox.shrink(),
    };
  }

  static Widget _buildCompiledRootTemplate({
    required UschemaCompiled compiled,
    required Autopilot autopilot,
    String? optionalId,
  }) {
    final template = _buildCompiledTemplate(
      compiled: compiled,
      autopilot: autopilot,
      optionalId: optionalId,
    );
    final scroll = compiled.frame?.scroll ?? 'none';
    final inner = switch (scroll) {
      'vertical' => SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(children: <Widget>[template]),
        ),
      'horizontal' => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: <Widget>[template]),
        ),
      _ => Container(child: template),
    };
    return UxRootTemplateHost(
      i: compiled.i,
      autopilot: autopilot,
      child: inner,
    );
  }

  static StatelessWidget _buildCompiledTemplate({
    required UschemaCompiled compiled,
    required Autopilot autopilot,
    String? optionalId,
  }) {
    switch (compiled.t) {
      case 1:
        final workspace = compiled.workspace ?? compiled.spec.workspace;
        final slots = compiled.workspaceSlots ?? compiled.spec.workspaceSlots;
        return Tworkspace(
          i: compiled.i,
          autopilot: autopilot,
          s: compiled.spec.style,
          oid: optionalId ?? '-',
          meta: workspace,
          slots: slots,
          formChildren: _buildFormFields(workspace.formFields, autopilot),
          formFooter: null,
        );
      case 2:
        return Tsheet(i: compiled.i, autopilot: autopilot, s: compiled.spec.style);
      case 3:
        return Treport(i: compiled.i, autopilot: autopilot, s: compiled.spec.style);
      case 4:
        return Tdboard(i: compiled.i, autopilot: autopilot, s: compiled.spec.style);
      case 5:
        return Twizard(i: compiled.i, autopilot: autopilot, s: compiled.spec.style);
      case 6:
        return Tform(i: compiled.i, autopilot: autopilot, s: compiled.spec.style);
      default:
        return Tform(i: compiled.i, autopilot: autopilot, s: compiled.spec.style);
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

}
