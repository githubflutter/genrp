# lib_core_model_data_readme

This document is generated from `lib/core/model/data/README.md` and documents the `data` directory models.

Directory: `lib/core/model/data`

This directory contains the plain Dart structural classes shared by the project.

Role by app
- In `AIStudio`, these classes are edited as model-definition rows.
- In `AICodex`, these classes are consumed as schema-generation input for create/drop/alter work.
- In `AIBook`, these classes are not the primary authoring surface; `AIBook` uses the resulting row-level CRUD structures produced from them.
- This means the class shape is shared, but the semantic role depends on the app.

Examples
- In `AIStudio`, `EntityModel` and `FieldModel` are edited as stored model rows.
- In `AICodex`, `EntityModel` and `FieldModel` act as the source definitions used to create, drop, or alter generated table/function structure.
- In `AIBook`, the app works with CRUD on the generated row structures rather than owning schema authoring.
- For `AIBook`, the effective app-facing dynamic schema comes from `EntityModel` and `FieldModel`, not directly from `TableModel` and `ColumnModel`.
- A physical table may contain storage-level columns that are intentionally not exposed in the app-facing entity/field schema. Example: table `user` may contain column `password`, while entity `user` does not expose field `password`.

Boundary notes
- The model layer defines structure only.
- Authoritative runtime data should live in the app state holders owned by `Autopilot`, not in the model classes themselves.
- A shared model class does not imply one fixed meaning across all apps.
- `TableModel` and `ColumnModel` represent lower-level physical schema structure.
- `EntityModel` and `FieldModel` represent the higher-level app-facing schema surface used by the dynamic parts of the system.

Files
- `table_model.dart` — `TableModel` (fields: `int i`, `bool a`, `int d`, `int e`, `int t`, `String n`, `String s`).
- `column_model.dart` — `ColumnModel` (same fields as `TableModel`).
- `action_model.dart` — `ActionModel` (same fields as `TableModel`).
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
- `d` — int
- `e` — int
- `t` — int
- `n` — String
- `s` — String

How to import
 - Use the barrel export to import all models from `lib/core/model/models.dart`:

```dart
import 'package:genrp/core/model/models.dart';

final t = TableModel(i: 1, a: true, d: 0, e: 0, t: 0, n: 'name', s: 's');
final json = t.toJson();
final restored = TableModel.fromJson(json);
```

Notes
- The models are intentionally simple and duplicated; consider refactoring (shared base class, mixin, or codegen) if you add more fields or behavior.
- For this project, treat `core/model/data` as shared structural vocabulary across `AIStudio`, `AICodex`, and `AIBook`, with each app consuming the same structures at a different stage of the workflow.
