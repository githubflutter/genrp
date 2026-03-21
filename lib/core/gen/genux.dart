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
        final crud = spec as UxCrudTemplateSpec;
        return Tcrud(
          i: crud.i,
          autopilot: autopilot,
          s: crud.s,
          oid: optionalId ?? '-',
          summaryText: crud.summaryText,
          collectionTitle: crud.collectionTitle,
          collectionColumns: crud.collectionColumns,
          collectionRows: crud.collectionRows,
          collectionViewModes: crud.collectionViewModes,
          properties: crud.properties,
          formChildren: _buildFormFields(crud.formFields, autopilot),
          formFooter: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: <Widget>[
                FilledButton(onPressed: () {}, child: const Text('Save')),
                OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              ],
            ),
          ),
          emptyTitle: crud.emptyTitle,
          emptyMessage: crud.emptyMessage,
          defaultAlertMessage: crud.defaultAlertMessage,
          collectionFlex: crud.collectionFlex,
          detailFlex: crud.detailFlex,
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
}
