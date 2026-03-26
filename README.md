# GenRP

Single project readme for the current repo.

## Overview

GenRP is a Flutter monolith with four app targets sharing one `core` runtime and UI foundation.

There are two live app patterns:

- **AIWork** and **AIBook** are spec-driven client shells. They use `AppRuntimeFlow`, `Autopilot`, `UschemaRuntime`, and `GenUx` to render route-root `tworkspace` specs.
- **AIStudio** and **AICodex** are direct admin shells. They mount `AdminHome` and keep local admin state instead of using the full client runtime path.

The old paper-centered runtime is no longer the active checked-in direction.

## Apps

| App | Role | Entry | Current state |
|---|---|---|---|
| `AIWork` | Client/workflow CRUD | `lib/app/aiwork/aiwork.dart` | Login -> loading -> spec-driven runtime |
| `AIBook` | Client/runtime reader | `lib/app/aibook/aibook.dart` | Login -> loading -> spec-driven runtime |
| `AIStudio` | UX/spec authoring | `lib/app/aistudio/aistudio.dart` | Shared `AdminHome` shell |
| `AICodex` | Data-model/schema authoring | `lib/app/aicodex/aicodex.dart` | Shared `AdminHome` shell |

## Run

```bash
flutter run -t lib/main.dart
flutter run -t lib/main_aicodex.dart
flutter run -t lib/main_aistudio.dart
flutter run -t lib/main_aibook.dart
flutter run -t lib/main_aiwork.dart
```

`main.dart` boots AICodex. `autoSignIn` is currently meaningful in AIWork and AIBook only.

## Layout

```text
lib/
├── app/        # AIWork, AIBook, AIStudio, AICodex shells
├── core/
│   ├── agent/  # Autopilot, copilots, runtime/data stores
│   ├── base/   # transport classes, type mapping, converters, helpers
│   ├── db/     # SQLite store and DB/client scaffolding
│   ├── gen/    # AppRuntimeFlow, UschemaRuntime, GenUx, AdminHome
│   ├── model/  # base, bschema, bdata, uschema models
│   ├── theme/  # shared theme helpers
│   └── ux/     # templates, uwidgets, field widgets
└── main*.dart  # entry points
```

## Runtime

- `Autopilot` is the thin coordinator over `CopilotData`, `CopilotUx`, `DataSet`, and `StateSet`.
- `AppRuntimeFlow` owns route bootstrap and route replacement in the client apps.
- `UschemaRuntime` compiles and caches `UxSpec`.
- `GenUx` renders compiled template-layer specs.
- `Tworkspace` is the only rich checked-in template path today.
- `Tsheet`, `Treport`, `Tdboard`, `Twizard`, and `Tform` are still placeholder runtime surfaces.
- AIStudio and AICodex currently use `AdminHome` instead of the route/bootstrap runtime used by AIWork and AIBook.

## Core Data Contracts

### Data Types

`lib/core/base/data_type.dart` defines:

- `DataType` for type metadata fields `i`, `n`, `d`, `p`, `s`, `j`
- `TypeMapper` for registry lookup by id or display name

Built-in ids:

- `0` bool
- `1` Int32
- `2` Int53
- `3` Int64
- `4` Double
- `5` Binary
- `6` Json
- `7` Jsonb
- `9` Guid
- `10` String
- `11` Base64

Ids above `99` are generated numeric types. Example: `1202` means `Numeric(12,2)`.

### X Transport

`lib/core/base/x.dart` defines the compact transport hierarchy:

- `X` -> `v`
- `Xi` -> `i + v`
- `Xia` -> `i + a + v`
- `Xiad` -> `i + a + d + v`
- `Xiade` -> `i + a + d + e + v`

Use this family for compact machine-oriented transport, especially business row payloads where indexed slots matter more than verbose property names.

Identity rules:

- schema-side drafts use `i = 0`
- simple admin-side rows may still use `max(i) + 1`
- richer business-side ids should follow an epoch-millisecond-plus-suffix pattern and stay within web-safe integer range

### BSchema Models

`lib/core/model/bschema` holds the plain structural schema layer:

- `TableModel`
- `ColumnModel`
- `FunctionModel`
- `ParameterModel`
- `EntityModel`
- `FieldModel`

Role split by app:

- `AICodex` owns CRUD for these models
- `AIStudio` may read them for context
- `AIWork` and `AIBook` consume the runtime/business structures produced from them rather than acting as schema-authoring apps

Important field notes:

- `n` is the readable name
- `s` is the system name, preferably lower snake_case
- `d` is the last date/time integer, usually UTC epoch ms
- `e` is the last editor reference
- `ParameterModel` uses `fi` for function id
- `FieldModel` uses `ci` for column id
- `FunctionModel` and `EntityModel` use `tis` for dependent table ids

### SQLite Store

`lib/core/db/sqlite_store.dart` is the current shared local SQLite foundation.

Main use:

- local catalog-row persistence for admin-side editing
- local cache / key-value storage
- shared infrastructure until DB code is split further by app

Current schema:

- `app_kv` for simple key/value JSON storage
- `catalog_row` for generic catalog-based row persistence
- `vfun` for SQLite-side representation of function-like behavior

This is local infrastructure, not a full mirror of PostgreSQL function support.

## UI Basics

### Input Fields

`UwField` is the shared multimode field system. In practice the repo uses these patterns:

- text and number fields
- combo and select dropdowns
- date and datetime pickers
- boolean toggles
- tag-style list editing
- filter fields with operator cycling
- file, color, json, link, checklist, and related specialized modes

### Admin Explorer

In AIStudio and AICodex, `AdminHome` provides the shared left-side explorer and a mode-driven detail area.

Basic behavior:

- expand nodes with the arrow control
- select a node to drive the detail area
- use schema / preview / compare modes through the shared shell

## Quality

Run:

```bash
flutter analyze
flutter test
```

Current snapshot:

- `flutter analyze` passes clean
- `flutter test` reports there are no checked-in `test/` files yet
- manual app smoke testing is still needed for behavioral confidence

## Docs

- `docs/project_deep_analysis.md` — current architecture snapshot and rerun findings
- `docs/what_we_did.md` — short project changelog
