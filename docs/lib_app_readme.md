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
- GenRP has three CRUD domains: data-model CRUD, UX model-spec CRUD, and business-model/runtime CRUD.
- Data models are the foundation of the whole system because they are the actual schema layer: the sitting table/function definitions from which the rest of the stack is derived.
- Data-model definitions are single origin, single source of truth, and single user.
- Sensitive data-model CRUD belongs to `AICodex` because those changes can require database recreation or schema regeneration.
- UX model-spec CRUD belongs to `AIStudio`.
- Business-model/runtime CRUD belongs to `AIBook` through function-style actions rather than direct business-table writes.
- `AIStudio` is the UX/spec editing surface. It should focus on CRUD for UX-side model/spec rows rather than the sensitive data-model layer.
- `AIStudio` is now narrowed to the UX/spec explorer/editor path; it should not carry the data-model explorer/collection surface.
- `AICodex` is the sensitive data-model CRUD and schema-application surface. It owns CRUD for data models such as `EntityModel`, `FieldModel`, `TableModel`, and related definition rows because those changes may require database recreation. It also creates/drops structures and generates function/script definitions for PostgreSQL and SQLite. `ALTER TABLE` is not part of the planned flow.
- `AICodex` also owns the data-model explorer/collection flow that was previously shown in AIStudio.
- `AIBook` is the runtime/business-data consumer. It uses the generated structures produced from those models and should invoke function-style actions for business-table CRUD rather than doing direct table CRUD.
- `SystemModel` and `UsrModel` are special base models under `lib/core/model/base/`, not normal generic data rows.
- `SystemModel` carries system/version/timestamp info plus JSON-based bootstrap maps.
- Physical database names should not be assumed to match model names directly.
- Current remembered alias direction for actual database objects is:
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
- Multi-user concurrent schema editing is intentionally unsupported because schema/model definitions are dangerous to edit collaboratively.
- For `base`, `bschema`, and `uschema`, `i` and `e` should stay `int4`.
- New rows in `base`, `bschema`, and `uschema` should allocate `i` with `max(i) + 1`.
- For data-model tables, primary IDs and explicit structural foreign keys should stay `int4`.
- Everywhere in the model and transport vocabulary, `d` is the last date/time field and usually uses UTC epoch milliseconds.
- In that same shared vocabulary, `e` is the last editor reference.
- In `base`, `bschema`, and `uschema`, `e` should stay `int4`.
- In schema-side layers, `e` points to `UsrModel.i`.
- `d` should stay web-safe `int^53` and map to PostgreSQL `bigint` when persisted there.
- Because that layer is single-user/admin-side only, `select max(i) + 1` is acceptable for model-definition ID allocation there.
- UX/spec rows should not become real database foreign-key owners of the data-model layer.
- `UsrModel.i` follows the same `int4` + `max(i) + 1` rule as the rest of the base model layer.
- `UsrModel` is the system/admin-side user concept. Business users should be treated as a separate business-domain concern rather than folded into the base layer.
- `UsrModel` now uses the same field set as business-side `UserModel`: `i, d, e, a, u, p, n, x, l`.
- The difference is policy, not field names: `UsrModel.i` and `UsrModel.e` stay on the base-side `int4 + max(i) + 1` rule.
- Business-side `UserModel` now lives under `lib/core/model/bdata/` and is distinct from base-side `UsrModel`.
- Business-side `UserModel` belongs to the business domain and currently maps to business table entrypoint `t0`.
- In `bdata` and future `udata`, `i` and `e` should stay web-safe `int^53`.
- In data-side layers, `e` points to `UserModel.i`.
- New rows in `bdata` and `udata` should follow the epoch-millisecond-plus-suffix rule we already use for richer transport identities.
- Current `bdata/UserModel` shape is `i, d, e, a, u, p, n, x, l`:
  - `i`, `d`, `e`, `x` = int8 / web-safe integer
  - `a` = bool
  - `u`, `p`, `n` = text
  - `p` stays plain text for now; no hashing policy is applied yet
  - `l` = int4

Convergent shell design
- `AIStudio` and `AICodex` should converge on one **hybrid shell** so users do not have to relearn the layout when switching apps.
- The `Scaffold.body` should be split into two high-level areas:
  - **minor panel** on the left
  - **major panel** on the right
- The **minor panel** is the left-side support area and should have **two tabs**.
- The **major panel** is the working area and should have **three tabs**.
- The major tabs define the body layout mode:
  - **major tab 1** = single-panel mode, with only the mid panel visible
  - **major tab 2** = asymmetric dual-panel mode, with a larger mid panel and a smaller right panel
  - **major tab 3** = symmetric dual-panel mode, with mid and right panels split equally
- The convergent rule is structural first:
  - `AIStudio` and `AICodex` should share the same minor/major shell
  - app differences should happen inside the tab contents, not by inventing different outer layouts
- Shared visual rules should stay the same across both apps:
  - same minor-panel width logic
  - same major-tab behavior
  - same selected-tile highlight treatment
  - same loading, empty, and error state placement
  - same header treatment inside the active major tab content
- App-specific divergence should happen inside the major-tab content:
  - `AIStudio` content focuses on UX/spec rows
  - `AICodex` content focuses on data-model rows and schema actions
- Search, add/create, editor tools, and schema tools should live inside the active major-tab content rather than inside the minor panel.

Backend transport contract
- The server layer is a C# ASP.NET Core Minimal Web API with a single endpoint URL.
- The endpoint accepts `POST` only.
- The request body is handed over as JSON directly; the C# server does not map the body into business-model objects first.
- PostgreSQL returns JSON directly, and the C# server returns that JSON without converting it into response model objects.
- PostgreSQL owns the central router function that interprets the request and performs CRUD behavior.
- PostgreSQL and SQLite are not mirror backends in this architecture.
- Both PostgreSQL and SQLite can have bootstrap/foundation structures.
- PostgreSQL foundation/business behavior can use real database functions.
- SQLite should represent function-like behavior through a `vfun` table/model that stores scripts to run.
- If `vfun` blocks current implementation progress, it can be deferred temporarily; it is not required to unblock the current app surfaces.
- Direct CRUD is allowed for foundation tables.
- Business-table CRUD goes through function-style actions only.
- Runtime/business integers that cross web/JSON boundaries should stay within signed 53-bit safe integer range even if PostgreSQL stores them as `bigint`.
- For base `X` transport IDs:
  - `Xi.i` can use `max(i) + 1`
  - richer variants such as `Xia`, `Xiad`, and `Xiade` should use epoch-millisecond-based IDs in the form `epochMs * 10/100/1000 + suffix`
  - the suffix should stay inside `0..999`
  - in those richer variants, `d` and `e` are also treated as web-safe `int^53` values and can map to PostgreSQL `bigint`
- `bdata` and `udata` should follow that richer epoch-ms-plus-suffix direction for new `i` values rather than the `max(i) + 1` rule used by `base`, `bschema`, and `uschema`
- In this project, function parameters are input-only; returned business shape should be modeled through fields/result rows rather than output parameters.
- All generated columns are treated as never-null in the shared schema contract.
- `ALTER TABLE` is not part of the current design.

Current shared DB scaffolding
- `lib/core/db/db_contract.dart` defines the generic database, table, function, and CRUD specs used by the builders.
- `lib/core/db/pgsqladmin.dart` and `lib/core/db/sqliteadmin.dart` are the admin builders. They generate create-database, create-table, and create-function output only.
- `lib/core/db/pgsqlclient.dart` and `lib/core/db/sqliteclient.dart` are the direct CRUD builders. They are intended for foundation rows and reject direct business-table CRUD.
- `lib/core/db/webclient.dart` builds the generic action/CRUD request envelope used by remote transport layers.
- System entrypoint seeds now live in `lib/core/base/systable.dart`, `lib/core/base/sysfunc.dart`, and `lib/core/base/systype.dart`.
- Shared bootstrap logic for `SystemModel` now lives in `lib/core/base/bootstrap.dart`; it owns default model values, seed rows, and update helpers without changing the generic SQL builders.
- In SQLite, function creation is represented as `vfun` row/script storage rather than true database functions, but that layer can be deferred temporarily if it blocks current progress.

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
- `p` — password, plain text for now.
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
- Business-table writes use one function-style action such as `edit<ModelName>`.
- There are no separate business write functions named `insert<ModelName>`, `update<ModelName>`, or `delete<ModelName>`.
- Within `edit<ModelName>`, `data.i == 0` means create.
- Within `edit<ModelName>`, `data.i > 0` means update.
- Updates are partial; only the fields that actually changed are posted.
- There is no hard delete.
- Within `edit<ModelName>`, `data.a = false` is treated as delete behavior through the function payload.
- Foundation tables can still use direct CRUD paths when appropriate.
- Foundation and business schema creation still belongs to the admin side; runtime clients should not generate create scripts.

Planned UX spec note
- The `lib/core/model/uschema` layer already exists and is already used by the AIBook runtime (`UxRegistry`, `UxSpecMapper`, and typed `Ux*Model` classes).
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
