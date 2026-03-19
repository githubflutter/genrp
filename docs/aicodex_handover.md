# AICodex Handover

Progressive step-by-step plan to build the AICodex sensitive data-model CRUD and schema-application surface.

**Current status:** Step 3 is done, and the shared hybrid shell is in place — minor panel with two tabs, major panel with three tabs, grouped model navigation, SQLite-backed master list, search, add-row action, row selection, and the right-side detail editor are all in place. Step 4 is next.

**Current next step:** Step 4 — DDL and function-script generation display.

**Role:** AICodex is the **sensitive data-model CRUD and schema configurator**. It owns CRUD for model definitions such as Entity, Field, Table, Column, Function, and related rows because those edits can require database recreation or schema regeneration. It also applies those definitions as **create, drop, and function/script** operations against the PostgreSQL backend and SQLite foundation. It does not consume runtime row data the way AIBook does.

**Database rule:** PostgreSQL and SQLite are not mirror backends. PostgreSQL can use real foundation/business functions. SQLite should represent function-like behavior through a `vfun` table/model that stores scripts to run. Foundation tables allow direct CRUD; business tables go through function/script paths only. `ALTER TABLE` is not part of this project. If `vfun` blocks current implementation progress, it can be deferred temporarily.

**Authority rule:** The data-model layer is the foundation schema layer of the whole system. It is the single origin, single source of truth, and single-user/admin-side editing surface. Multi-user concurrent schema editing is intentionally unsupported.

**ID rule:** For `base`, `bschema`, and `uschema`, `i` and `e` stay `int4`. New rows allocate `i` with `max(i) + 1`. `d` is the last date/time integer, usually UTC epoch milliseconds, and stays web-safe `int^53` / PostgreSQL `bigint`. Because this layer is single-user/admin-side only, `max(i) + 1` is acceptable for model-definition ID allocation.

**Convergent UI rule:** AICodex should use the same hybrid shell as AIStudio:
- left side = **minor panel**
- right side = **major panel**
- minor panel has **two tabs**
- major panel has **three tabs**
- major tab 1 = single mid panel only
- major tab 2 = larger mid + smaller right
- major tab 3 = equal mid + right
- functional data-model CRUD and schema work should now continue inside that shared shell

---

## How to use this document

1. Find your current step (the first `[ ] Step` heading).
2. Read only that step's section.
3. Complete the step, run the quality gate, check the box.
4. Move to the next step.

**Quality gate** (run after every step):
```bash
flutter analyze
flutter test
```

**Prerequisite:** None beyond the shared SQLite foundation. AICodex now owns the sensitive data-model CRUD path, so it no longer depends on AIStudio finishing model-row editing first.

---

## What is already done

- [x] Three-panel layout skeleton inside one `Scaffold.body`
- [x] Left panel navigation with grouped model types
- [x] Local selection state for model type and selected row
- [x] Middle panel header reflects the selected model type
- [x] Middle panel: SQLite-backed master list for the selected model type
- [x] Search box filters rows by `n`
- [x] Add button creates a new row in the selected catalog
- [x] Row selection highlighting in the master list
- [x] Right panel: detail editor with save/delete flow
- [x] FAB and bottom status bar
- [x] `SqliteStore` shared foundation exists
- [x] Shared DB scaffolding exists: `db_contract`, PG/SQLite admin+client builders, and system entrypoint seeds
- [x] Core models exist, with `ActionModel` now treated as UX-side metadata under `lib/core/model/uschema`
- [x] Backend contract documented (single POST endpoint, JSON passthrough, PG router function)

## [x] UI convergence prerequisite — Hybrid shell

**Status:** Done in the current repo snapshot.

**Goal:** Replace the earlier fixed three-panel shell with the shared hybrid minor/major shell before continuing feature steps.

**What to do:**
1. Convert the current body layout into:
   - left minor panel
   - right major panel
2. Add **two tabs** to the minor panel.
3. Add **three tabs** to the major panel.
4. Implement the three major layout modes:
   - tab 1: single mid only
   - tab 2: larger mid + smaller right
   - tab 3: equal mid + right
5. Preserve current AICodex navigation/master-list behavior inside the new shell.

**Done when:**
- AICodex uses the shared hybrid shell.
- The old fixed three-panel layout is gone.
- Current navigation/master-list behavior still works inside the new shell.

---

## Panel Responsibilities

```
┌──────────────┬───────────────────────────────────┬──────────────────┐
│  Navigation  │          Master List               │  Detail / DDL   │
│              │                                    │                 │
│  Entity  ◄── │  user                              │  Entity: user   │
│  Field       │  customer                          │  id: 42         │
│  Table       │  invoice         ◄── selected ──►  │  Table: t_user  │
│  Column      │  product                           │                 │
│  Function    │  order_item                        │  Fields: 6      │
│              │                                    │                 │
│              │  [+ Generate]                      │  [Create DDL]   │
│              │                                    │  [Create Fn]    │
│              │                                    │  [Drop DDL]     │
└──────────────┴───────────────────────────────────┴──────────────────┘
```

| Panel | Purpose |
|---|---|
| **Minor** (Left) | Support area with two tabs |
| **Major / Tab 1** | Single mid-only working surface |
| **Major / Tab 2** | Larger mid + smaller right |
| **Major / Tab 3** | Equal mid + right working split |

---

## [x] Step 1 — Navigation panel with model type list

**Status:** Done in the current repo snapshot.

**Goal:** Replace the left placeholder with a real model type list that tracks selection.

**Files to change:**
- `lib/app/aicodex/aicodex.dart`

**What to do:**
1. Convert `AICodexApp` home to a `StatefulWidget`.
2. Add state fields:
   - `String? _selectedModelType` (e.g., `'Entity'`, `'Table'`, `'Function'`)
   - `int? _selectedRowId`
3. Build the left panel as a `ListView` with these model types grouped into two sections:

   **Schema Source** (app-facing definitions):
   - `Entity`
   - `Field`
   - `Relation`
   - `Function`
   - `Parameter`

   **Schema Target** (physical structure):
   - `Table`
   - `Column`
   - `System`
   - `User`

4. Tapping a model type sets `_selectedModelType` and clears `_selectedRowId`.
5. Highlight the selected model type visually.
6. Show the selected model type name in the middle panel header.

**Done when:**
- Left panel shows all model types in two groups.
- Tapping one updates `_selectedModelType`.
- Middle panel header reflects the selection.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AICodex Step 1: Navigation panel with model type list.

Current state:
- `lib/app/aicodex/aicodex.dart` is a static three-panel layout. All panels are placeholders.
- 7 regular bschema models exist under `lib/core/model/bschema/`, and 2 special base models (`SystemModel`, `UsrModel`) now live under `lib/core/model/base/`.
- `ActionModel` now lives under `lib/core/model/uschema/`.

Task:
- Make home a StatefulWidget.
- Add state: _selectedModelType, _selectedRowId.
- Left panel: ListView with two sections:
  - Schema Source: Entity, Field, Relation, Function, Parameter
  - Schema Target: Table, Column, System, User
- Tap sets _selectedModelType, clears _selectedRowId.
- Highlight selected item.
- Show selected name in middle panel header.

Constraints:
- Do not touch AIBook or AIStudio.
- Do not add route navigation.
- Keep one Scaffold.
- Keep analyzer green.
```

---

## [x] Step 2 — Master list from SQLite

**Status:** Done in the current repo snapshot.

**Goal:** The middle panel shows model-definition rows from `SqliteStore` for the selected model type and supports the first CRUD entrypoint into that catalog.

**Files to change:**
- `lib/app/aicodex/aicodex.dart`

**What to do:**
1. Initialize `SqliteStore.instance` when AICodex loads.
2. When `_selectedModelType` changes, load rows via `SqliteStore.listRows(modelType)`.
3. Display rows as a `ListView`:
   - Each item shows `n` (name), `i` (id), `a` (active indicator).
   - Show a badge or icon for active (`a == true`) vs inactive (`a == false`).
4. Add a search `TextField` at the top of the master list — filter by `n`.
5. Add an "Add" button in the header that creates a new empty row for the selected catalog.
6. Tapping a row sets `_selectedRowId`.
7. Highlight the selected row.
8. Place the collection UI inside the active major-tab content after the hybrid shell is in place.

**Done when:**
- Middle panel shows SQLite rows for the selected model type.
- Search filters rows by name.
- Add button creates a new row.
- Tapping a row selects it.
- Empty state shows "No rows" message.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AICodex Step 2: Master list from SQLite.

Current state:
- Step 1 is done — navigation panel with model type selection.
- `SqliteStore` exists with `listRows(catalog)` returning `List<SqliteCatalogRow>`.
- `SqliteCatalogRow` has: catalog, i, a, d, e, t, n, s, payload, updatedAt.

Task:
- Init SqliteStore in AICodex.
- Load rows when _selectedModelType changes.
- Show as ListView: name, id, active badge.
- Add search TextField (filter by n).
- Add button for a new row in the selected catalog.
- Tap to select → _selectedRowId.
- Show empty state when no rows.

Constraints:
- AICodex owns sensitive data-model CRUD for these catalogs.
- Use SqliteStore.instance.
- Keep setState for now, no Provider needed.
- Keep analyzer green.
```

---

## [x] Step 3 — Detail panel with data-model editor

**Status:** Done in the current repo snapshot.

**Goal:** The right-side workspace inside the active major tab shows the selected model-definition row in editable form so AICodex can own sensitive data-model CRUD locally before schema generation.

**Files to change:**
- `lib/app/aicodex/aicodex.dart`

**What to do:**
1. When `_selectedRowId` is set, load the row via `SqliteStore.getRow(modelType, id)`.
2. Display editable controls for the common fields:
   - `n` — Readable name
   - `s` — System name (prefer lower snake_case)
   - `a` — Active status
3. Display read-only or lightly editable handling for structural fields such as `i`, `d`, `e`, `t`, and `payload` as appropriate for the selected catalog.
4. Add a "Save" button that calls `SqliteStore.upsertRow` with the edited row.
5. Add a "Delete" button that calls `SqliteStore.deleteRow` for the selected row.
6. Show "No row selected" when nothing is selected.
7. Keep the editor and schema actions inside the active major-tab workspace area of the hybrid shell.
8. If a relationship summary cannot be derived cleanly from the current model contract, show a deferral note instead of reusing stale assumptions.

**Done when:**
- Selecting a row in the master list loads it in the right panel editor.
- Save persists the row back to SQLite.
- Delete removes the row from SQLite and refreshes the master list.
- Structural fields are visible and the JSON payload is editable.
- Narrow dual-pane layouts still keep the action area usable.
- Empty state shows "No row selected."
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AICodex Step 3: Detail panel with data-model editor.

Current state:
- Step 2 is done — master list shows SQLite rows.
- _selectedRowId is set when a row is tapped.

Task:
- Load row via SqliteStore.getRow when _selectedRowId changes.
- Show editable controls for n, s, and a.
- Show structural fields and payload in a simple direct editor/read-only layout as appropriate.
- Add Save button -> upsertRow.
- Add Delete button -> deleteRow.
- Show "No row selected" empty state.
- If relationship counts are not valid under the current model rules, show a deferral note instead of inventing a stale mapping.

Constraints:
- AICodex owns sensitive data-model CRUD for these catalogs.
- Keep analyzer green.
```

---

## [ ] Step 4 — DDL and function-script generation display

**Goal:** Add schema action buttons and SQL/script preview to the detail panel after the row editing surface exists. This is what makes AICodex different from AIStudio — it both owns sensitive data-model CRUD and shows the generated table DDL and function/`vfun` scripts for the selected model.

**Current state:** Step 3 is done — selected rows now load into the right panel, `n/s/a/payload` can be edited, and save/delete already round-trip through SQLite with widget coverage.

**Files to change:**
- `lib/app/aicodex/aicodex.dart`
- `lib/core/generator/` (new file: `ddl_generator.dart`)

**What to do:**
1. Create `lib/core/generator/ddl_generator.dart` with a `DdlGenerator` class.
2. Implement `generateCreate(SqliteCatalogRow entity, List<SqliteCatalogRow> fields)`:
   - Build a `CREATE TABLE` statement from entity name and field definitions.
   - Use `TypeMapper.byId(field.t)` to resolve PostgreSQL column types.
3. Implement `generateDrop(SqliteCatalogRow entity)`:
   - Build a `DROP TABLE IF EXISTS` statement.
4. Implement `generateCreateFunction(...)` for PostgreSQL foundation/business function SQL.
   - Treat `Parameter` rows as input-only parameters.
   - Treat returned business shape as field/result structure rather than `OUT` or `INOUT` parameters.
5. Implement `generateVirtualFun(...)` for SQLite `vfun` payload/script generation where function behavior needs local representation.
6. In the detail panel, show three buttons: **Create Table**, **Create Function**, **Drop Table**.
7. When pressed, display the generated SQL/script in a read-only code block below the buttons.
8. Add a "Copy" button to copy the SQL/script to clipboard.

**Done when:**
- Selecting an Entity and pressing "Create Table" shows a valid `CREATE TABLE` statement.
- PostgreSQL types are resolved from `TypeMapper`.
- "Create Function" shows appropriate function SQL or SQLite `vfun` script output.
- "Drop Table" shows a `DROP TABLE` statement.
- "Copy" copies the generated SQL/script text.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AICodex Step 4: DDL and function-script generation display.

Current state:
- Step 3 is done — detail panel shows selected row.
- `TypeMapper` exists at `lib/core/base/data_type.dart` with Dart↔PostgreSQL↔SQLite type mapping.
- `SqliteCatalogRow.t` holds the type ID for field rows.

Task:
- Create `lib/core/generator/ddl_generator.dart` with DdlGenerator class.
- generateCreate(entity, fields) → CREATE TABLE SQL using TypeMapper for column types.
- generateDrop(entity) → DROP TABLE IF EXISTS SQL.
- generateCreateFunction(...) → function SQL for PostgreSQL.
- generateVirtualFun(...) → SQLite `vfun` script/payload for function-like behavior.
- Add three buttons in detail panel: Create Table, Create Function, Drop Table.
- Show generated SQL/script in a read-only code block.
- Add Copy to clipboard button.

Constraints:
- Generate SQL/script strings only — do NOT execute against any database.
- Use TypeMapper.byId() for PostgreSQL type names.
- Do not introduce `ALTER TABLE`.
- Keep analyzer green.
```

---

## [ ] Step 5 — Schema action dispatch to backend

**Goal:** Add the ability to send generated DDL to the backend via the real transport endpoint.

**Files to change:**
- `lib/app/aicodex/aicodex.dart`
- `lib/core/agent/transport.dart` (reuse from AIBook Step 4, or `mock_transport.dart` if transport isn't wired yet)

**What to do:**
1. Add an "Execute" button next to each schema action (Create Table, Create Function, Drop Table).
2. On press, POST the DDL action to the backend using the transport contract:
   ```json
   {"a": <schema_action_id>, "u": "...", "p": "...", "data": {"ddl": "...", "entityId": N}}
   ```
3. Show a confirmation dialog before executing Drop.
4. Show success/failure result from the server response.
5. Add a status indicator in the detail panel showing last sync state.

**Done when:**
- Execute sends the DDL action to the backend.
- Drop requires confirmation.
- Success/failure is shown to the user.
- `flutter analyze` passes.
- `flutter test` passes.

---

## [ ] Step 6 — Foundation and business function scripts

**Goal:** Extend generation beyond tables to support PostgreSQL foundation/business functions and SQLite `vfun` records.

**Files to change:**
- `lib/core/generator/ddl_generator.dart`

**What to do:**
1. `generateCreateFunction(function, parameters)` → `CREATE OR REPLACE FUNCTION` SQL for PostgreSQL.
2. Use `TypeMapper` for input parameter types and field/result return types.
3. `generateDropFunction(function)` → `DROP FUNCTION IF EXISTS` SQL.
4. `generateVirtualFun(function, script)` → SQLite `vfun` row payload/script.
5. In the detail panel, show function SQL or `vfun` output when `_selectedModelType` is `Function`.
 
**Done when:**
- Function SQL generation works with input parameters and field/result return shape.
- SQLite `vfun` payload generation works for local function-like behavior.
- Detail panel shows appropriate SQL/script output for Function model type.
- `flutter analyze` passes.
- `flutter test` passes.

---

## [ ] Step 7 — AICodex test coverage

**Goal:** Add dedicated tests for AICodex panel behavior and DDL generation.

**Files to change:**
- `test/aicodex_test.dart` (new)
- `test/ddl_generator_test.dart` (new)

**What to do:**
1. Test: selecting a model type shows master list.
2. Test: adding, editing, and deleting a row works through AICodex.
3. Test: selecting a row shows detail panel.
4. Test: `generateCreate` produces valid SQL for a sample entity + fields.
5. Test: `generateDrop` produces valid SQL.
6. Test: `generateCreateFunction` produces valid SQL with input parameters only.
7. Test: `TypeMapper` types appear correctly in generated DDL.

**Done when:**
- All test scenarios pass.
- `flutter analyze` passes.
- `flutter test` passes.

---

## Architecture constraints (apply to all steps)

- AICodex **owns sensitive data-model CRUD** for the shared data-model catalogs.
- AICodex **generates and applies** schema operations — create, drop, and function/script actions.
- Do not introduce `ALTER TABLE`.
- PostgreSQL can use real functions.
- SQLite function behavior should be represented via `vfun` records/scripts.
- Do not redesign AIBook or AIStudio.
- Do not add route navigation.
- Keep one `Scaffold`, everything in `Scaffold.body`.
- Keep implementation direct and incremental.
- Keep analyzer and tests green after every step.

## App role reminder

```
AIStudio ──(edits UX/spec)──────────────────────────────────────────────► UX Definitions
AICodex ──(CRUD + schema apply)──► Data Model Definitions ──(generates)──► Tables/Functions
                                                                       │
                                                                       └──(consumed by)──► AIBook ──(function CRUD)──► Business Data
```

## Vocabulary quick reference

| Term | Meaning |
|---|---|
| DDL | Data Definition Language — CREATE, DROP, and related function/script statements |
| Schema Source | App-facing models: Entity, Field, Relation, Function, Parameter |
| Schema Target | Physical models: Table, Column, System, User |
| `vfun` | SQLite-side script store used when function behavior needs local representation |
| `TypeMapper` | Maps type ID → PostgreSQL/Dart/SQLite/JSON type names |
| `i/a/d/e/t/n/s` | id, active, last date, editor, type, readable name, system name |
