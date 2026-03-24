import 'package:genrp/core/gen/uschema_compiled.dart';
import 'package:genrp/core/model/uschema/ux_spec.dart';

class UschemaCacheEntry {
  const UschemaCacheEntry({
    required this.specId,
    required this.editedAt,
    required this.compiled,
  });

  final int specId;
  final int editedAt;
  final UschemaCompiled compiled;

  bool matches(UxSpec spec) => specId == spec.i && editedAt == spec.d;
}

/// Cache for compiled UX schema trees.
///
/// Source of truth stays in raw `UxSpec`; this cache is only the reusable
/// speed layer for compiled runtime form.
class UschemaCache {
  final Map<int, UschemaCacheEntry> _byId = <int, UschemaCacheEntry>{};

  UschemaCacheEntry? get(int id) => _byId[id];

  void put(UxSpec spec, UschemaCompiled compiled) {
    _byId[compiled.i] = UschemaCacheEntry(
      specId: spec.i,
      editedAt: spec.d,
      compiled: compiled,
    );
  }

  void remove(int id) {
    _byId.remove(id);
  }

  void clear() {
    _byId.clear();
  }
}
