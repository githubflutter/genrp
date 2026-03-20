import 'package:flutter/material.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/m/m.dart';
import 'package:genrp/core/ux/p/pfour.dart';
import 'package:genrp/core/ux/p/pone.dart';
import 'package:genrp/core/ux/p/pthree.dart';
import 'package:genrp/core/ux/p/ptwo.dart';
import 'package:genrp/core/ux/p/pzero.dart';
import 'package:genrp/core/ux/t/tcrud.dart';
import 'package:genrp/core/ux/t/tdboard.dart';
import 'package:genrp/core/ux/t/tform.dart';
import 'package:genrp/core/ux/t/treport.dart';
import 'package:genrp/core/ux/t/tsheet.dart';
import 'package:genrp/core/ux/t/twizard.dart';

class UxRuntimeRenderer {
  UxRuntimeRenderer._();

  static Widget buildPaper({
    required UxPaperSpec spec,
    required UxPilot autopilot,
    String? optionalId,
  }) {
    final template = buildTemplate(
      spec: spec.template,
      autopilot: autopilot,
      optionalId: optionalId,
    );

    return switch (spec.pid) {
      0 => Pzero(i: spec.i, autopilot: autopilot, s: spec.s, child: template),
      1 => Pone(i: spec.i, autopilot: autopilot, s: spec.s, child: template),
      2 => Ptwo(
        i: spec.i,
        autopilot: autopilot,
        s: spec.s,
        left: template,
        right: template,
      ),
      3 => Pthree(
        i: spec.i,
        autopilot: autopilot,
        s: spec.s,
        first: template,
        middle: template,
        last: template,
      ),
      4 => Pfour(i: spec.i, autopilot: autopilot, s: spec.s),
      _ => Pzero(i: spec.i, autopilot: autopilot, s: spec.s, child: template),
    };
  }

  static StatelessWidget buildTemplate({
    required UxTemplateSpec spec,
    required UxPilot autopilot,
    String? optionalId,
  }) {
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
          formChildren: _buildFormFields(crud.formFields),
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

  static List<Widget> _buildFormFields(List<UxFieldSpec> fields) {
    return fields
        .map<Widget>(
          (UxFieldSpec field) => SizedBox(
            width: field.width,
            child: TextField(
              decoration: InputDecoration(
                labelText: field.label,
                hintText: field.hint,
              ),
            ),
          ),
        )
        .toList(growable: false);
  }
}
