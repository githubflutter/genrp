# lib_core_model_data_readme

This document is generated from `lib/core/model/data/README.md` and documents the `data` directory models.

Directory: `lib/core/model/data`

This directory contains the plain Dart model classes used by the project.

Files
- `table_model.dart` — `TableModel` (fields: `int i`, `bool a`, `bool d`, `bool e`, `int t`, `String n`, `String s`).
- `column_model.dart` — `ColumnModel` (same fields as `TableModel`).
- `function_model.dart` — `FunctionModel` (same fields as `TableModel`).
- `parameter_model.dart` — `ParameterModel` (same fields as `TableModel`).
- `entity_model.dart` — `EntityModel` (same fields as `TableModel`).
- `field_model.dart` — `FieldModel` (same fields as `TableModel`).
- `relation_model.dart` — `RelationModel` (same fields as `TableModel`).
- `system_model.dart` — `SystemModel` (same fields as `TableModel`).
- `user_model.dart` — `UserModel` (same fields as `TableModel`).

Common API
- All models are immutable, have a `const` constructor, and implement:
  - `factory <Model>.fromJson(Map<String, dynamic>)`
  - `Map<String, dynamic> toJson()`
  - `copyWith(...)` for convenient partial updates
  - `==` and `hashCode`

Fields (all models)
- `i` — int
- `a` — bool
- `d` — bool
- `e` — bool
- `t` — int
- `n` — String
- `s` — String

How to import
 - Use the barrel export to import all models from `lib/core/model/models.dart`:

```dart
import 'package:genrp/core/model/models.dart';

final t = TableModel(i: 1, a: true, d: false, e: false, t: 0, n: 'name', s: 's');
final json = t.toJson();
final restored = TableModel.fromJson(json);
```

Notes
- The models are intentionally simple and duplicated; consider refactoring (shared base class, mixin, or codegen) if you add more fields or behavior.
