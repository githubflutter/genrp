import 'package:genrp/core/model/uschema/ux_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

/// Normalized runtime form compiled from raw `UxSpec`.
///
/// Raw `UxSpec` remains the persisted/editable truth. `UschemaCompiled`
/// exists so runtime code can work from resolved layer/type information and
/// pre-indexed child zones without reparsing the raw shape repeatedly.
class UschemaCompiled {
  const UschemaCompiled({
    required this.spec,
    required this.layer,
    required this.typeName,
    required this.children,
    required this.isRouteRoot,
    this.workspace,
    this.workspaceSlots,
  });

  final UxSpec spec;
  final bool isRouteRoot;
  UxFrameMeta? get frame => spec.hasFrame ? spec.frame : null;
  final UxLayer layer;
  final String typeName;
  final List<UschemaCompiled> children;
  final UxWorkspaceMeta? workspace;
  final UxWorkspaceSlots? workspaceSlots;

  int get i => spec.i;
  int get t => spec.t;
  int get l => spec.l;
  String get n => spec.n;
  Map<String, dynamic> get m => spec.m;
  Map<String, dynamic> get s => spec.s;

  UschemaCompiled? firstOfLayer(UxLayer layer) {
    for (final child in children) {
      if (child.layer == layer) return child;
    }
    return null;
  }

  UschemaCompiled? firstOfType(int type, {UxLayer layer = UxLayer.uwidget}) {
    for (final child in children) {
      if (child.layer == layer && child.t == type) return child;
    }
    return null;
  }
}
