# AICodex Handover

Progressive step-by-step plan to build the AICodex configurator and schema-application surface.

**Current status:** Placeholder — static three-panel layout with no functionality.

**Role:** AICodex is the **schema configurator**. It reads model definitions (Entity, Field, Table, Column, Function, etc.) and applies them as **create, drop, and alter** operations against the PostgreSQL backend. It does not edit model definitions (that's AIStudio) and does not consume row data at runtime (that's AIBook).

---

## How to use this document

1. Find your current step (the first unchecked `[ ]` box).
2. Read only that step's section.
3. Complete the step, run the quality gate, check the box.
4. Move to the next step.

**Quality gate** (run after every step):
```bash
flutter analyze
flutter test
```

**Prerequisite:** AIStudio Step 3+ should be done first so that model rows exist in SQLite for AICodex to read.

---

## What is already done

- [x] Three-panel layout skeleton inside one `Scaffold.body`
- [x] Left panel: "Model Navigation" placeholder
- [x] Middle panel: "Master/Main Editor" placeholder
- [x] Right panel: "Property Editor" placeholder
- [x] FAB and bottom status bar
- [x] `SqliteStore` shared foundation exists
- [x] All 10 data models exist (Entity, Field, Relation, Action, Function, Parameter, Table, Column, System, User)
- [x] Backend contract documented (single POST endpoint, JSON passthrough, PG router function)

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
│  Action      │                                    │  Status: synced │
│              │                                    │                 │
│              │  [+ Generate]                      │  [Create DDL]   │
│              │                                    │  [Alter DDL]    │
│              │                                    │  [Drop DDL]     │
└──────────────┴───────────────────────────────────┴──────────────────┘
```

| Panel | Purpose |
|---|---|
| **Left** (Navigation) | Pick the model type to work with (Entity, Table, Function, etc.) |
| **Middle** (Master) | Browse model-definition rows for the selected type from SQLite |
| **Right** (Detail) | Inspect the selected row + schema actions (create/alter/drop DDL) |

---

## Step 1 — Navigation panel with model type list

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
   - `Action`
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
- 10 data models exist under `lib/core/model/data/`.

Task:
- Make home a StatefulWidget.
- Add state: _selectedModelType, _selectedRowId.
- Left panel: ListView with two sections:
  - Schema Source: Entity, Field, Relation, Action, Function, Parameter
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

## Step 2 — Master list from SQLite

**Goal:** The middle panel shows model-definition rows from `SqliteStore` for the selected model type.

**Files to change:**
- `lib/app/aicodex/aicodex.dart`

**What to do:**
1. Initialize `SqliteStore.instance` when AICodex loads.
2. When `_selectedModelType` changes, load rows via `SqliteStore.listRows(modelType)`.
3. Display rows as a `ListView`:
   - Each item shows `n` (name), `i` (id), `a` (active indicator).
   - Show a badge or icon for active (`a == true`) vs inactive (`a == false`).
4. Add a search `TextField` at the top of the master list — filter by `n`.
5. Tapping a row sets `_selectedRowId`.
6. Highlight the selected row.

**Done when:**
- Middle panel shows SQLite rows for the selected model type.
- Search filters rows by name.
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
- Tap to select → _selectedRowId.
- Show empty state when no rows.

Constraints:
- AICodex reads model data — it does NOT create/edit model rows (that's AIStudio's job).
- Use SqliteStore.instance.
- Keep setState for now, no Provider needed.
- Keep analyzer green.
```

---

## Step 3 — Detail panel with row inspection

**Goal:** The right panel shows full details of the selected model-definition row in read-only mode.

**Files to change:**
- `lib/app/aicodex/aicodex.dart`

**What to do:**
1. When `_selectedRowId` is set, load the row via `SqliteStore.getRow(modelType, id)`.
2. Display all fields in a read-only layout:
   - `i` — ID
   - `n` — Name
   - `s` — Description / secondary
   - `a` — Active status
   - `d` — Date / discriminator
   - `e` — Entity reference
   - `t` — Type reference
   - `payload` — JSON payload (formatted)
3. If `_selectedModelType` is `Entity`, also show a summary line: "Fields: N" (count of Field rows where `e == this entity's id`).
4. If `_selectedModelType` is `Table`, also show a summary line: "Columns: N" (count of Column rows where `e == this table's id`).
5. Show "No row selected" when nothing is selected.

**Done when:**
- Selecting a row in the master list shows its full details in the right panel.
- Related child count is shown for Entity and Table types.
- Empty state shows "No row selected."
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AICodex Step 3: Detail panel with row inspection.

Current state:
- Step 2 is done — master list shows SQLite rows.
- _selectedRowId is set when a row is tapped.

Task:
- Load row via SqliteStore.getRow when _selectedRowId changes.
- Show all fields in read-only layout (i, n, s, a, d, e, t, payload).
- For Entity type: show "Fields: N" (count Field rows where e matches).
- For Table type: show "Columns: N" (count Column rows where e matches).
- Show "No row selected" empty state.

Constraints:
- Detail panel is READ-ONLY — AICodex inspects, it does not edit definitions.
- Keep analyzer green.
```

---

## Step 4 — DDL generation display

**Goal:** Add schema action buttons and DDL preview to the detail panel. This is what makes AICodex different from AIStudio — it shows the **generated SQL** for the selected model.

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
4. Implement `generateAlter(SqliteCatalogRow entity, List<SqliteCatalogRow> fields)`:
   - Build `ALTER TABLE ADD COLUMN` for new fields (placeholder logic).
5. In the detail panel, show three buttons: **Create DDL**, **Alter DDL**, **Drop DDL**.
6. When pressed, display the generated SQL in a read-only code block below the buttons.
7. Add a "Copy" button to copy the DDL to clipboard.

**Done when:**
- Selecting an Entity and pressing "Create DDL" shows a valid `CREATE TABLE` statement.
- PostgreSQL types are resolved from `TypeMapper`.
- "Drop DDL" shows a `DROP TABLE` statement.
- "Copy" copies DDL text to clipboard.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AICodex Step 4: DDL generation display.

Current state:
- Step 3 is done — detail panel shows selected row.
- `TypeMapper` exists at `lib/core/base/data_type.dart` with Dart↔PostgreSQL↔SQLite type mapping.
- `SqliteCatalogRow.t` holds the type ID for field rows.

Task:
- Create `lib/core/generator/ddl_generator.dart` with DdlGenerator class.
- generateCreate(entity, fields) → CREATE TABLE SQL using TypeMapper for column types.
- generateDrop(entity) → DROP TABLE IF EXISTS SQL.
- generateAlter(entity, fields) → ALTER TABLE ADD COLUMN SQL (basic).
- Add three buttons in detail panel: Create DDL, Alter DDL, Drop DDL.
- Show generated SQL in a read-only code block.
- Add Copy to clipboard button.

Constraints:
- Generate DDL strings only — do NOT execute against any database.
- Use TypeMapper.byId() for PostgreSQL type names.
- Keep analyzer green.
```

---

## Step 5 — Schema action dispatch to backend

**Goal:** Add the ability to send generated DDL to the backend via the real transport endpoint.

**Files to change:**
- `lib/app/aicodex/aicodex.dart`
- `lib/core/agent/transport.dart` (reuse from AIBook Step 4, or `mock_transport.dart` if transport isn't wired yet)

**What to do:**
1. Add an "Execute" button next to each DDL action (Create, Alter, Drop).
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

## Step 6 — Function and Action DDL

**Goal:** Extend DDL generation beyond tables to support Function and Action definitions.

**Files to change:**
- `lib/core/generator/ddl_generator.dart`

**What to do:**
1. `generateCreateFunction(function, parameters)` → `CREATE OR REPLACE FUNCTION` SQL.
2. Use `TypeMapper` for parameter and return types.
3. `generateDropFunction(function)` → `DROP FUNCTION IF EXISTS` SQL.
4. In the detail panel, show function DDL when `_selectedModelType` is `Function`.
5. For `Action` model type, show the action's associated function reference.

**Done when:**
- Function DDL generation works with parameters and return types.
- Detail panel shows appropriate DDL for Function model type.
- `flutter analyze` passes.
- `flutter test` passes.

---

## Step 7 — AICodex test coverage

**Goal:** Add dedicated tests for AICodex panel behavior and DDL generation.

**Files to change:**
- `test/aicodex_test.dart` (new)
- `test/ddl_generator_test.dart` (new)

**What to do:**
1. Test: selecting a model type shows master list.
2. Test: selecting a row shows detail panel.
3. Test: `generateCreate` produces valid SQL for a sample entity + fields.
4. Test: `generateDrop` produces valid SQL.
5. Test: `generateCreateFunction` produces valid SQL with parameters.
6. Test: `TypeMapper` types appear correctly in generated DDL.

**Done when:**
- All test scenarios pass.
- `flutter analyze` passes.
- `flutter test` passes.

---

## Architecture constraints (apply to all steps)

- AICodex **reads** model definitions — it does NOT edit them (editing is AIStudio's job).
- AICodex **generates and applies** schema operations — create, alter, drop.
- Do not redesign AIBook or AIStudio.
- Do not add route navigation.
- Keep one `Scaffold`, everything in `Scaffold.body`.
- Keep implementation direct and incremental.
- Keep analyzer and tests green after every step.

## App role reminder

```
AIStudio ──(edits)──► Model Definitions ──(reads)──► AICodex ──(generates)──► DDL/Schema
                              │
                              └──(consumed by)──► AIBook ──(row CRUD)──► Business Data
```

## Vocabulary quick reference

| Term | Meaning |
|---|---|
| DDL | Data Definition Language — CREATE, ALTER, DROP statements |
| Schema Source | App-facing models: Entity, Field, Relation, Action, Function, Parameter |
| Schema Target | Physical models: Table, Column, System, User |
| `TypeMapper` | Maps type ID → PostgreSQL/Dart/SQLite/JSON type names |
| `i/a/d/e/t/n/s` | id, active, date, entity, type, name, secondary |
