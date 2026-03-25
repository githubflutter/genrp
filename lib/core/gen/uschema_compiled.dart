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
    required this.uxzones,
    required this.isRouteRoot,
    this.workspace,
    this.workspaceSlots,
  });

  final UxSpec spec;
  final bool isRouteRoot;
  UxFrameMeta? get frame => spec.hasFrame ? spec.frame : null;
  final UxLayer layer;
  final String typeName;
  final Map<String, List<UschemaCompiled>> uxzones;
  final UxWorkspaceMeta? workspace;
  final UxWorkspaceSlots? workspaceSlots;

  int get i => spec.i;
  int get t => spec.t;
  int get l => spec.l;
  String get n => spec.n;
  Map<String, dynamic> get m => spec.m;
  Map<String, dynamic> get s => spec.s;

  List<UschemaCompiled> uxzoneChildren(String uxzone) =>
      uxzones[uxzone] ?? const <UschemaCompiled>[];

  UschemaCompiled? firstInUxZone(String uxzone) {
    final items = uxzoneChildren(uxzone);
    return items.isEmpty ? null : items.first;
  }

  UschemaCompiled? firstOfLayer(UxLayer layer, {String? uxzone}) {
    final groups =
        uxzone == null ? uxzones.values : <List<UschemaCompiled>>[uxzoneChildren(uxzone)];
    for (final group in groups) {
      for (final child in group) {
        if (child.layer == layer) return child;
      }
    }
    return null;
  }

  UschemaCompiled? firstOfType(int type, {UxLayer layer = UxLayer.uwidget, String? uxzone}) {
    final groups =
        uxzone == null ? uxzones.values : <List<UschemaCompiled>>[uxzoneChildren(uxzone)];
    for (final group in groups) {
      for (final child in group) {
        if (child.layer == layer && child.t == type) return child;
      }
    }
    return null;
  }
}
