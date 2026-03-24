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
      UxLayer.paper =>
        _buildCompiledPaper(compiled: compiled, autopilot: autopilot, optionalId: optionalId),
      UxLayer.template => _buildCompiledTemplate(
        compiled: compiled,
        autopilot: autopilot,
        optionalId: optionalId,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  static Widget _buildCompiledPaper({
    required UschemaCompiled compiled,
    required Autopilot autopilot,
    String? optionalId,
  }) {
    final templateSpec = compiled.firstOfLayer(UxLayer.template, uxzone: UxZone.content);
    final StatelessWidget template = templateSpec == null
        ? Container()
        : _buildCompiledTemplate(
            compiled: templateSpec,
            autopilot: autopilot,
            optionalId: optionalId,
          );

    return switch (compiled.t) {
      0 => Pzero(i: compiled.i, autopilot: autopilot, s: compiled.spec.style, child: template),
      1 => Pone(i: compiled.i, autopilot: autopilot, s: compiled.spec.style, child: template),
      2 => Ptwo(
        i: compiled.i,
        autopilot: autopilot,
        s: compiled.spec.style,
        left: template,
        right: template,
      ),
      3 => Pthree(
        i: compiled.i,
        autopilot: autopilot,
        s: compiled.spec.style,
        first: template,
        middle: template,
        last: template,
      ),
      4 => Pfour(i: compiled.i, autopilot: autopilot, s: compiled.spec.style),
      _ => Pzero(i: compiled.i, autopilot: autopilot, s: compiled.spec.style, child: template),
    };
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

  // Actions removed for presentation mode
}
