# lib_core_model_bschema_readme

This document is generated from `lib/core/model/bschema/README.md` and documents the `bschema` directory models.

Directory: `lib/core/model/bschema`

This directory contains the plain Dart structural classes shared by the project.

Special base models such as `SystemModel` and `UsrModel` now live under `lib/core/model/base/` and should not be treated as normal generic data rows.

Role by app
- In `AICodex`, these classes are the sensitive data-model authoring surface. `AICodex` owns CRUD for them and uses them as schema-generation input for create/drop/function-script work.
- In `AIStudio`, these classes may still be read for context, but `AIStudio` should not own sensitive data-model CRUD.
- In `AIBook`, these classes are not the primary authoring surface; `AIBook` uses the resulting business-data structures produced from them and reaches them through function-driven CRUD.
- This means the class shape is shared, but the semantic role depends on the app.
- In `AIBook`, current business-bound runtime transport is expected to prefer the base `X` variants from `lib/core/base/x.dart` rather than human-readable object maps.
- Treat these models as the foundation schema layer of the whole system, not as ordinary collaborative app content.
- This layer is single origin, single source of truth, and single user under `AICodex`.

Examples
- In `AICodex`, `EntityModel` and `FieldModel` are edited as stored model rows and act as the source definitions used to create, drop, or script generated table/function structure.
- In `AIStudio`, UX/spec models are the primary editing target; data models can be shown for reference but should not be treated as the main CRUD surface.
- In `AIBook`, the app works with function-driven CRUD on the generated business structures rather than owning schema authoring.
- For `AIBook`, the effective app-facing dynamic schema comes from `EntityModel` and `FieldModel`, not directly from `TableModel` and `ColumnModel`.
- A physical table may contain storage-level columns that are intentionally not exposed in the app-facing entity/field schema. Example: table `user` may contain column `password`, while entity `user` does not expose field `password`.
- `SystemModel` and `UsrModel` are exceptions to the generic row pattern and now live under `lib/core/model/base/`.

Boundary notes
- The model layer defines structure only.
- Authoritative runtime data should live in the app state holders owned by `Autopilot`, not in the model classes themselves.
- A shared model class does not imply one fixed meaning across all apps.
- The data-model layer is the actual schema side of the system: it describes the sitting tables/functions that the rest of the stack depends on.
- `TableModel` and `ColumnModel` represent lower-level physical schema structure.
- `EntityModel` and `FieldModel` represent the higher-level app-facing schema surface used by the dynamic parts of the system.
- `SystemModel` and `UsrModel` should not be treated as normal `i/a/d/e/t/n/s` row clones.
- Across the common row models, `n` is the readable/display name and `s` is the system name, preferably lower snake_case.
- The actual physical database object names do not have to match the model names directly.
- Current remembered alias direction for physical database names is:
  - `s0` = `usr`
  - `s1` = `systemmodel`
  - `s2` = `table`
  - `s3` = `column`
  - `s4` = `function`
  - `s5` = `param`
  - `s6` = `entity`
  - `s7` = `field`
- Business tables should start with `t`.
- Current remembered business-table entrypoint is:
  - `t0` = `UserModel`
- `ParameterModel` now uses `fi` for function ID instead of the generic `t` field.
- `ParameterModel` is input-only in this architecture; function output should be modeled through fields/result shape rather than output parameters.
- `FunctionModel` keeps `t` as function type and adds `tis` for zero, one, or many dependent table IDs.
- `EntityModel` keeps `t` as entity type and adds `tis` for zero, one, or many dependent table IDs.
- `FieldModel` keeps `t` as field type and adds `ci` for the mapped column ID.
- `ActionModel` has been moved to `lib/core/model/uschema` because it is now treated as UX-side metadata rather than a data/schema model.
- For `AIBook`, those model classes help define runtime meaning, but business payload transport should stay compact and index-oriented when possible.
- For `base`, `bschema`, and `uschema`, `i` and `e` are intended to stay `int4`.
- New schema-side drafts should start with `i = 0`.
- Save/edit is what decides insert vs update:
  - `i = 0` means insert, and save allocates `max(i) + 1`
  - `i > 0` means update
- `d` keeps the same cross-layer rule here too: it is the last date/time integer, usually UTC epoch milliseconds, and should stay web-safe `int^53` / PostgreSQL `bigint`.
- Because schema editing is single-user/admin-side only, `max(i) + 1` is acceptable for model-definition ID allocation.

Files
- `table_model.dart` — `TableModel` (fields: `int i`, `bool a`, `int d`, `int e`, `int t`, `String n`, `String s`).
- `column_model.dart` — `ColumnModel` (same fields as `TableModel`).
- `function_model.dart` — `FunctionModel` (fields: `int i`, `bool a`, `int d`, `int e`, `int ei`, `int t`, `List<int> tis`, `String n`, `String s`).
- `parameter_model.dart` — `ParameterModel` (fields: `int i`, `bool a`, `int d`, `int e`, `int fi`, `String n`, `String s`).
- `entity_model.dart` — `EntityModel` (fields: `int i`, `bool a`, `int d`, `int e`, `int t`, `List<int> tis`, `String n`, `String s`).
- `field_model.dart` — `FieldModel` (fields: `int i`, `bool a`, `int d`, `int e`, `int ci`, `int t`, `String n`, `String s`).

Common API
- All models are immutable, have a `const` constructor, and implement:
  - `factory <Model>.fromJson(Map<String, dynamic>)`
  - `Map<String, dynamic> toJson()`
  - `copyWith(...)` for convenient partial updates
  - `==` and `hashCode`

Fields (most models)
- `i` — int
- In data-model tables, `i` is typically the `int4` primary ID.
- `a` — bool
- `d` — last date/time int, usually UTC epoch milliseconds; keep it within web-safe `int^53` and map to PostgreSQL `bigint`
- `e` — last editor reference; keep it as `int4` in `base`, `bschema`, and `uschema`, where it points to `UsrModel.i`
- `t` — int
- `n` — String readable/display name
- `s` — String system name / slug, preferably lower snake_case

Fields (`ParameterModel`)
- `fi` — function ID
- Parameters are input-only; output belongs to field/result structure rather than `out`/`inout` parameters.

Fields (`FunctionModel`)
- `ei` — output entity ID foreign key
- `t` — function type
- Function type values: `0 = sys-get`, `1 = sys-set`, `2 = jss-get`, `3 = jss-set`, `4 = biz-get`, `5 = biz-set`.
- `tis` — dependent table IDs (`[0]` by default); function may depend on no table, one table, or many tables.

Fields (`EntityModel`)
- `t` — entity type
- `tis` — dependent table IDs (`[0]` by default); entity may depend on no table, one table, or many tables.

Fields (`FieldModel`)
- `ci` — mapped column ID foreign key
- `t` — field type

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
- For this project, treat `core/model/bschema` as shared structural vocabulary across `AIStudio`, `AICodex`, and `AIBook`, with `AICodex` as the authoritative single-user data-model CRUD surface, `AIStudio` as the UX/spec CRUD surface, and `AIBook` as the runtime/business consumer.
- `SystemModel` and `UsrModel` now live in `lib/core/model/base/` because they are special base models rather than ordinary schema-row models.
- Business-side `UserModel` now lives separately under `lib/core/model/bdata/` and should not be confused with base-side `UsrModel`.
- `UsrModel` now uses the same field set as business-side `UserModel` (`i, d, e, a, u, p, n, x, l`), but keeps the base-side `int4 + max(i) + 1` identity policy.
- `bdata` and future `udata` use a different identity rule from `base`/`bschema`/`uschema`: `i` and `e` should stay web-safe `int^53`, `e` points to `UserModel.i`, and new rows should follow the epoch-millisecond-plus-suffix allocator rather than `max(i) + 1`.
