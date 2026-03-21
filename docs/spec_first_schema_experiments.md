# Spec-First Schema Experiments

> **Status:** Experimental — do not implement before **September 2026**.  
> **Merged from:** `bschema_uschema_reshape_plan.md` + `toexperiment_after_v2_launched.md`

---

## 1. Goal

Reshape `bschema` and `uschema` so the repo keeps a small hard-coded core, while schema truth moves to serializable spec documents with compiled runtime caches for speed.

**Core rule:**
- source of truth = spec
- source of speed = compiled cache

---

## 2. What Stays Hard-Coded

Keep these concrete — they are engine/runtime infrastructure:

- `lib/core/base/x.dart` (transport hierarchy)
- `lib/core/base/converter.dart` (type conversions)
- `lib/core/base/data_type.dart` (DataType + TypeMapper)
- DB/client/admin helpers (`lib/core/db/`)
- Runtime helpers, `Autopilot`, `GenUx`

---

## 3. BSchema Reshape

Current `bschema` concrete model files (`*_model.dart`) are no longer the desired final truth.

**Forward direction:**
- Move toward JSON-schema-based documents
- Allow project-specific `x-*` extension fields where needed
- Keep schema transportable, serializable, and easy to edit in AICodex

**Practical rule:**
- `bschema` should describe structure
- Not become a growing set of concrete Dart classes

### Allowed JSON Schema Content

- `type`, `properties`, `required`, `enum`, `default`, `description`, `items`
- `x-db-*` (database-specific metadata: table name, index hints)
- `x-ui-*` (UI-specific metadata: labels, visibility, order)
- `x-action-*` (action-specific metadata: validation, triggers)

### Business Object Physical Convention

For business object persistence, use this compact physical rule:

| Field | Type | Notes |
|---|---|---|
| `i` | `int32` | Row ID |
| `a` | `bool` | Active flag |
| `d` | `int53` app / `int64` DB | Last date/time |
| `e` | `int32` | Last editor |
| `c1..cn` | user-defined | Business columns |

Physical table names: `t1` to `tn`.

This keeps indexing predictable, DB shape compact, and schema evolution driven by spec rather than by many hard-coded column names.

### JSON Schema Example

```json
{
  "title": "customer",
  "type": "object",
  "properties": {
    "i":  { "type": "int32" },
    "a":  { "type": "boolean", "default": true },
    "d":  { "type": "int53" },
    "e":  { "type": "int32" },
    "c1": { "type": "string", "x-label": "name", "minLength": 1 },
    "c2": { "type": "boolean", "x-label": "active", "default": true }
  },
  "required": ["i", "c1"],
  "x-db-table": "t1",
  "x-ui-label": "Customer"
}
```

---

## 4. USchema Reshape

`uschema` should remain spec-first too.

Keep the existing direction:
- route spec, paper spec, template spec, widget/view spec, field/action/meta bindings

But keep them as:
- serializable documents, transportable specs, cacheable compile targets

Not as:
- runtime ownership objects or hand-coded widget truth

---

## 5. Proposed File Structure

```text
lib/
└── core/
    ├── base/
    │   ├── x.dart
    │   ├── converter.dart
    │   └── data_type.dart
    ├── gen/
    │   ├── admin_state.dart
    │   ├── explorer_state.dart
    │   ├── adminhome.dart
    │   ├── uexplorer.dart
    │   └── genux.dart
    └── model/
        ├── bschema/
        │   ├── bschema_spec.dart
        │   ├── bschema_compiled.dart
        │   ├── bschema_cache.dart
        │   ├── bschema_index.dart
        │   └── bschema_codec.dart
        └── uschema/
            ├── ux_specs.dart
            ├── ux_route_spec.dart
            ├── ux_paper_spec.dart
            ├── ux_field_spec.dart
            ├── uxm_template_spec.dart
            ├── uschema_compiled.dart
            ├── uschema_cache.dart
            └── uschema_codec.dart
```

---

## 6. Runtime Shape (Sample Code)

### Raw Spec

Editable, transportable, persistable.

```dart
typedef JsonMap = Map<String, dynamic>;

class BSchemaSpec {
  const BSchemaSpec({
    required this.id,
    required this.schema,
  });

  final String id;
  final JsonMap schema;
}
```

### Compiled Shape

Normalized once for runtime use.

```dart
class BSchemaCompiled {
  const BSchemaCompiled({
    required this.id,
    required this.title,
    required this.properties,
    required this.requiredKeys,
  });

  final String id;
  final String title;
  final Map<String, JsonMap> properties;
  final Set<String> requiredKeys;
}
```

### Cache Shape

Parse once, reuse many times.

```dart
class BSchemaCache {
  final Map<String, BSchemaCompiled> _byId = <String, BSchemaCompiled>{};

  BSchemaCompiled? get(String id) => _byId[id];

  void put(BSchemaCompiled value) {
    _byId[value.id] = value;
  }

  void clear() {
    _byId.clear();
  }
}
```

### Compile Pattern

```dart
class BSchemaCodec {
  const BSchemaCodec();

  BSchemaCompiled compile(BSchemaSpec spec) {
    final schema = spec.schema;
    final properties =
        (schema['properties'] as Map<String, dynamic>? ?? <String, dynamic>{})
            .map(
              (key, value) => MapEntry(
                key,
                (value as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
              ),
            );

    final requiredKeys =
        ((schema['required'] as List?) ?? const <dynamic>[])
            .map((value) => value.toString())
            .toSet();

    return BSchemaCompiled(
      id: spec.id,
      title: schema['title']?.toString() ?? spec.id,
      properties: properties,
      requiredKeys: requiredKeys,
    );
  }
}
```

---

## 7. Performance Plan

1. Load raw spec once
2. Compile once
3. Cache compiled form
4. Use compiled/indexed form in runtime/editor/preview
5. Recompile only when schema changes

Do not keep concrete schema models just for speed. Use: specs as truth → parser/compiler as adapter → cached runtime form for speed.

---

## 8. App Impact

### AICodex
- Current hard-coded shell can stay
- Current shared `AdminHome` / `UExplorer` work can stay
- Explorer content should evolve toward spec documents
- Schema editing should move toward JSON-schema-like rows/documents
- SQL / apply / preview tools should derive from spec, not from many concrete schema classes

### AIStudio
- Keep the dedicated authoring shell
- Continue to reuse the same admin-shell direction where useful
- Keep `uschema` as UX-spec truth
- Avoid introducing a second runtime path

---

## 9. Migration Steps (When Ready)

1. Freeze the minimum `bschema` JSON-schema shape
2. Define allowed `x-*` extensions
3. Stop expanding concrete `bschema/*_model.dart` as the forward truth
4. Add `bschema_spec.dart`
5. Add `bschema_codec.dart`
6. Add `bschema_compiled.dart`
7. Add `bschema_cache.dart`
8. Wire `AICodex` explorer/editor to those specs
9. Keep `uschema` spec-first and serializable
10. Add `uschema_compiled.dart` + `uschema_cache.dart` + `uschema_codec.dart` if runtime speed demands it

---

## 10. Short Summary

- Keep the core engine concrete
- Keep schema truth as specs
- Compile for speed
- Cache for runtime
- Do not use concrete schema model classes as the final long-term truth
- **Do not start this work before September 2026**
