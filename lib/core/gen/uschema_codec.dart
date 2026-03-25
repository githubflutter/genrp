import 'package:genrp/core/gen/uschema_compiled.dart';
import 'package:genrp/core/model/uschema/ux_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

/// Compiler from raw `UxSpec` documents into normalized runtime form.
class UschemaCodec {
  const UschemaCodec();

  UschemaCompiled compile(UxSpec spec) {
    if (UxLayer.fromCode(spec.l) == UxLayer.paper) {
      spec = _normalizeLegacyPaper(spec);
    }
    final rootLayer = UxLayer.fromCode(spec.l);
    return _compile(spec, isRouteRoot: rootLayer == UxLayer.template);
  }

  UxSpec _normalizeLegacyPaper(UxSpec spec) {
    if (spec.t == 2 || spec.t == 3 || spec.t == 4) {
      throw UnsupportedError('Unsupported legacy paper type: p${spec.t}');
    }

    final templateChild = spec.uxzones[UxZone.content]?.firstOrNull;
    if (templateChild == null) {
      throw StateError('Legacy paper missing template child in content zone');
    }

    String scroll;
    if (spec.t == 0) {
      scroll = 'none';
    } else if (spec.t == 1 && spec.style == 1) {
      scroll = 'horizontal';
    } else {
      scroll = 'vertical';
    }

    return UxSpec.rootTemplate(
      i: spec.i,
      n: templateChild.n,
      t: templateChild.t,
      m: templateChild.m,
      s: templateChild.s,
      uxzones: templateChild.uxzones,
      frame: UxFrameMeta(scroll: scroll),
    );
  }

  UschemaCompiled _compile(UxSpec spec, {required bool isRouteRoot}) {
    final layer = UxLayer.fromCode(spec.l);
    return UschemaCompiled(
      spec: spec,
      layer: layer,
      typeName: _typeName(spec, layer),
      isRouteRoot: isRouteRoot,
      uxzones: spec.uxzones.map(
        (key, value) => MapEntry(
          key,
          value.map((child) => _compile(child, isRouteRoot: false)).toList(growable: false),
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
