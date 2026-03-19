**Apps: AIBook, AICodex, AIStudio**

- **Purpose:** Combined documentation for the app entry points under `lib/app/`.
- **Location:** [lib/app](lib/app)

**Overview**

This document describes the current app entry widgets:

- `AIBook` — [lib/app/aibook/aibook.dart](lib/app/aibook/aibook.dart)
- `AICodex` — [lib/app/aicodex/aicodex.dart](lib/app/aicodex/aicodex.dart)
- `AIStudio` — [lib/app/aistudio/aistudio.dart](lib/app/aistudio/aistudio.dart)

Main constitution
- Performance and efficiency come first.
- Prefer direct, low-overhead implementation over heavy abstraction.
- Prefer flat transport shapes where possible.
- Avoid unnecessary object conversion in C#, Flutter, and PostgreSQL boundaries.
- Keep orchestration centralized and traceable through `Autopilot`.
- Treat integer IDs in transport/runtime contracts as an intentional optimization, not just a naming preference.

Identifier precaution
- Human-readable names may still be useful in docs, constants, and authoring tools.
- Transport/runtime contracts should prefer integer identifiers for action, template, widget, type, source, and field references when possible.
- The move from text keys to integers is primarily for smaller payloads, cheaper comparisons, simpler routing, and lower runtime overhead.

Current semantic split
- `AIStudio` is the model-row editing surface. It performs direct CRUD on stored foundation/model rows such as `EntityModel` and `FieldModel`.
- `AICodex` is the configurator/schema-application surface. It uses those models to create/drop structures and generate function/script definitions for PostgreSQL and SQLite. `ALTER TABLE` is not part of the planned flow.
- `AIBook` is the runtime/business-data consumer. It uses the generated structures produced from those models and should invoke function-style actions for business-table CRUD rather than doing direct table CRUD.

Backend transport contract
- The server layer is a C# ASP.NET Core Minimal Web API with a single endpoint URL.
- The endpoint accepts `POST` only.
- The request body is handed over as JSON directly; the C# server does not map the body into business-model objects first.
- PostgreSQL returns JSON directly, and the C# server returns that JSON without converting it into response model objects.
- PostgreSQL owns the central router function that interprets the request and performs CRUD behavior.
- PostgreSQL and SQLite are not mirror backends in this architecture.
- Both PostgreSQL and SQLite can have bootstrap/foundation structures.
- PostgreSQL foundation/business behavior can use real database functions.
- SQLite should represent function-like behavior through a `virtualfun` table/model that stores scripts to run.
- Direct CRUD is allowed for foundation tables.
- Business-table CRUD goes through function-style actions only.
- All generated columns are treated as never-null in the shared schema contract.
- `ALTER TABLE` is not part of the current design.

Current shared DB scaffolding
- `lib/core/db/db_contract.dart` defines the generic database, table, function, and CRUD specs used by the builders.
- `lib/core/db/pgsqladmin.dart` and `lib/core/db/sqliteadmin.dart` are the admin builders. They generate create-database, create-table, and create-function output only.
- `lib/core/db/pgsqlclient.dart` and `lib/core/db/sqliteclient.dart` are the direct CRUD builders. They are intended for foundation rows and reject direct business-table CRUD.
- `lib/core/db/webclient.dart` builds the generic action/CRUD request envelope used by remote transport layers.
- System entrypoint seeds now live in `lib/core/base/systable.dart`, `lib/core/base/sysfunc.dart`, and `lib/core/base/systype.dart`.
- In SQLite, function creation is represented as `virtualfun` row/script storage rather than true database functions.

AIBook transport split
- For `AIBook`, UX/UI composition data can come from the web as normal JSON.
- For `AIBook`, business-bound row data should prefer the base `X` variants from `lib/core/base/x.dart`.
- This split is intentional: composition wants readable JSON structure, while bound business transport wants the smallest and cheapest machine-oriented shape.
- In architecture language, `base X` means the transport/data shape from `lib/core/base/x.dart`.
- `X*` under `lib/core/widgets` still means wrapped implementation controls such as `XButton`, `XTextBox`, and `XCheckBox`.
- HTTP transport for business data should invoke function-style actions; it should not mirror direct SQLite table writes for business tables.

Request body shape
- `a` — action ID (`bigint`).
- `u` — username.
- `p` — password.
- `data` — the actual payload JSON.

Example request

```json
{
  "a": 1001,
  "u": "demo",
  "p": "secret",
  "data": {
    "i": 0,
    "n": "User"
  }
}
```

Business write rule
- There is no direct `insert`, `update`, or `delete` endpoint for business tables.
- Business-table writes use one function-style action such as `edit_modelname`.
- `data.i == 0` means insert.
- `data.i > 0` means update.
- Updates are partial; only the fields that actually changed are posted.
- There is no hard delete.
- Soft delete means posting `data.a = false` through the function payload.
- Foundation tables can still use direct CRUD paths when appropriate.
- Foundation and business schema creation still belongs to the admin side; runtime clients should not generate create scripts.

Planned UX spec note
- The `lib/core/model/ux` layer already exists and is already used by the AIBook runtime (`UxRegistry`, `UxSpecMapper`, and typed `Ux*Model` classes).
- The editing surfaces around those UX models are still incomplete and should be treated as evolving rather than finalized.
- For `AIBook`, those UX models already act as runtime spec support.
- For `AIStudio`, those same UX models are still expected to become editable models.

Planned UX spec transport shape
- The preferred JSON shape is as flat as possible for direct C# and PostgreSQL conversion.
- Template identity, widget identity, widget type, action identity, and binding references are intended to use integer IDs rather than text keys.
- A template/widget identity may still be thought of conceptually like `templateId.widgetId`, but the wire format is intended to stay numeric.

Planned UX binding shape
- `src = 0` means `state`.
- `src = 1` means `dataSource`.
- `src = 2` means `dataSet`.
- `f` or equivalent binding field stores the bound field ID from the selected source.
- The combination of source ID and field ID identifies the binding target.
- For business-bound `AIBook` data, the preferred target is slot/index resolution into `X.v`, not human-readable property-path lookup.
- Human-readable binding paths such as `data.book.title` can remain as migration fallback, but they are not the intended long-term runtime transport for dynamic business data.

Planned UX routing implications
- `AIBook` runtime should resolve numeric UX spec IDs into predefined Flutter templates and widgets.
- `Autopilot` should remain the only orchestrator that resolves source ID plus field ID into actual reads and writes.
- The client should not treat incoming JSON as an arbitrary scripting engine; it should inject values into predefined templates and predefined widget slots.

Registry direction
- Registry-style support JSON may live under `assets/json`.
- Registry data should be separated from screen/body composition when doing so improves clarity and keeps the transport flat.
- The current preferred example is keeping field-binding registration in a dedicated registry JSON such as `aibook_registry.json`, while `aibook_spec.json` stays focused on UI composition.
- Action metadata is also a good candidate for the same registry JSON when the goal is to keep screen/body specs composition-only.
- Host identity can live in the same registry, with typical examples such as `main`, `left`, and `right`.
- Body identity and widget identity can follow the same pattern through `bodyId` and `widgetId`, with string names kept only as migration fallback.
- Runtime output bindings should follow the same `src + fieldId` resolution path as input bindings whenever practical.
- For business-bound `X` transport, field-binding registry entries should prefer slot/index metadata over property names when possible.

Current vocabulary direction
- `Ux*Model` is the definition-side naming for planned UX/UI models.
- `X*` is the implementation-side naming for wrapped Flutter controls under `lib/core/widgets` that know how to work with `Autopilot`.
- Base `X` / `Xi` / `Xia` / `Xiad` / `Xiade` is the transport/data-side naming from `lib/core/base/x.dart`.
- Preview selection/highlighting can use the full identity scope `hostId + bodyId + widgetId`, with no effect when no selected identity is present.
- Example pairing:
  - `UxButtonModel` describes a button definition.
  - `XButton` renders that definition as a real Flutter button.

Each app:

- Is a minimal `MaterialApp` with `debugShowCheckedModeBanner: false`.
- Exposes a top-level widget (`AIBookApp`, `AICodexApp`, `AIStudioApp`) under its own app directory — no `main()` inside these files.
- Shows a `FloatingActionButton` (FAB) for a sample action.
- Shows a right-aligned bottom status bar in the `BottomAppBar` containing:

  `<AppName>:<number>/<f>/<v>`

  where `<number>` is the app-specific flag and `f` / `v` are the global flags provided by `lib/meta.dart`.

**How to run each app**

App widgets now live under app-specific directories. The current `lib/main.dart` launches a small one-way selector app that can open `AIBook`, `AICodex`, or `AIStudio`. Example:

```bash
flutter run -t lib/main.dart
```

**Where to change the values**

- Per-app numbers are defined in `lib/meta.dart` as `AppMeta.aibook`, `AppMeta.aicode`, `AppMeta.aistudio`.
- Global flags are `AppMeta.f` and `AppMeta.v`.

**Customization notes**

- Change FAB behavior by editing the `floatingActionButton.onPressed` in the relevant file.
- Modify status format by editing the `BottomAppBar` text in the app's file.

**Next steps**

- Expand app-specific docs as each app moves from early shell work into its intended workflow role.
- See `docs/aibook_handover.md`, `docs/aistudio_handover.md`, and `docs/aicodex_handover.md` for the current handover docs.
