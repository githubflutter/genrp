import 'package:genrp/core/gen/uschema_compiled.dart';
import 'package:genrp/core/model/uschema/ux_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

/// Compiler from raw `UxSpec` documents into normalized runtime form.
class UschemaCodec {
  const UschemaCodec();

  UschemaCompiled compile(UxSpec spec) {
    final layer = UxLayer.fromCode(spec.l);
    return UschemaCompiled(
      spec: spec,
      layer: layer,
      typeName: _typeName(spec, layer),
      uxzones: spec.uxzones.map(
        (key, value) => MapEntry(
          key,
          value.map(compile).toList(growable: false),
        ),
      ),
      workspace: layer == UxLayer.template && spec.t == 1 ? spec.workspace : null,
      workspaceSlots:
          layer == UxLayer.template && spec.t == 1 ? spec.workspaceSlots : null,
    );
  }

  String _typeName(UxSpec spec, UxLayer layer) {
    switch (layer) {
      case UxLayer.app:
        return UxRegister.apps[spec.i] ?? spec.n;
      case UxLayer.paper:
        return UxRegister.papers[spec.t] ?? spec.n;
      case UxLayer.template:
        return UxRegister.templates[spec.t] ?? spec.n;
      case UxLayer.uwidget:
        return UxRegister.uwidgets[spec.t] ?? spec.n;
      case UxLayer.route:
      case UxLayer.field:
        return spec.n;
    }
  }
}
