# AIStudio Handover

Progressive step-by-step plan to build the AIStudio UX/spec editing surface.

**Current status:** Step 1 is done — three-panel shell, tabbed catalog navigation, local selection state, and middle-panel header updates are in place. Step 2 is next. Shared DB scaffolding exists, but AIStudio UI wiring is still Step 3+ work.

**Current next step:** Step 2 — Complete left-panel catalog lists.

**Scope rule:** Sensitive data-model CRUD now belongs to `AICodex`. AIStudio should focus on UX/spec CRUD. If data-model catalogs remain visible in the shell, they should be treated as secondary/reference paths until the UI is narrowed further.

**Special rule:** `System` is not a normal `i/a/d/e/t/n/s` row. `SystemModel` is structural metadata (`sid`, `n`, `fv`, `cv`, `ld`, `lds`, `ldu`, `ctm`, `uxm`, `m1`, `m2`) and belongs to the sensitive data-model side owned by `AICodex`.

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

---

## What is already done

- [x] Three-panel shell inside one `Scaffold.body`
- [x] Left panel with `Data` tab and `UX/Spec` tab
- [x] `Data` tab lists: Entity, Field, Relation, Function
- [x] `UX/Spec` tab lists: Host, Body, Template, Type, Widget, UX Action
- [x] Local selection state for active tab, selected catalog, and selected row
- [x] Middle panel header updates from the selected catalog
- [x] Selected catalog resets when switching tabs
- [x] FAB and bottom status bar
- [x] `SqliteStore` shared foundation (not wired to AIStudio yet)
- [x] Shared DB scaffolding exists: `db_contract`, PG/SQLite admin+client builders, and system entrypoint seeds

---

## [x] Step 1 — Add local selection state

**Status:** Done in the current repo snapshot.

**Goal:** Track what the user has selected so the middle and right panels can respond.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`

**What to do:**
1. Convert `AIStudioApp` to use a `StatefulWidget` for the home scaffold.
2. Add state fields:
   - `int _activeTab` (0 = Data, 1 = UX/Spec)
   - `String? _selectedCatalog` (e.g., `'Entity'`, `'Host'`)
   - `int? _selectedRowId`
   - `String _searchText` (default `''`)
3. When a left-panel `ListTile` is tapped, set `_selectedCatalog` to that item's name.
4. Show the selected catalog name as a header in the middle panel (replace placeholder text).
5. Keep right panel as placeholder for now.

**Done when:**
- Tapping a left-panel item updates the middle panel header.
- Tab switching between Data and UX/Spec works.
- `_selectedCatalog` resets when switching tabs.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIStudio Step 1: Add local selection state.

Current state:
- `lib/app/aistudio/aistudio.dart` has a three-panel static layout.
- Left panel has Data and UX/Spec tabs with ListTiles.
- Middle and right panels are placeholder text.

Task:
- Make the home a StatefulWidget.
- Add state: _activeTab, _selectedCatalog, _selectedRowId, _searchText.
- Wire ListTile taps to set _selectedCatalog.
- Show selected catalog name in middle panel header.
- Keep right panel placeholder.

Constraints:
- Do not touch AIBook or AICodex code.
- Do not add route navigation.
- Keep one Scaffold.
- Keep analyzer green.
```

---

## [ ] Step 2 — Complete left-panel catalog lists

**Goal:** Add all missing catalog entries to both tabs.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`

**What to do:**
1. Add missing `Data` tab entries:
   - `Parameter`
   - `Table`
   - `Column`
   - `System`
   - `User`
2. Add missing `UX/Spec` tab entries:
   - `FieldBinding`
   - `Body Spec Node`
3. Add a visual indicator (e.g., background color or leading icon) for the currently selected catalog.

**Done when:**
- `Data` tab shows: Entity, Field, Relation, Function, Parameter, Table, Column, System, User.
- `UX/Spec` tab shows: Host, Body, Template, Type, Widget, UX Action, FieldBinding, Body Spec Node.
- Selected catalog is visually highlighted.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIStudio Step 2: Complete left-panel catalog lists.

Current state:
- Step 1 is done — local selection state exists.
- Data tab has: Entity, Field, Relation, Function.
- UX/Spec tab has: Host, Body, Template, Type, Widget, UX Action.

Task:
- Add Data entries: Parameter, Table, Column, System, User.
- Add UX/Spec entries: FieldBinding, Body Spec Node.
- Highlight the selected catalog visually (e.g., selected ListTile color).

Constraints:
- Do not touch AIBook or AICodex code.
- Keep analyzer green.
```

---

## [ ] Step 3 — Middle panel with SQLite-backed UX/spec row list

**Goal:** The middle panel shows rows from `SqliteStore` for the selected UX/spec catalog, with search and an add button.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`
- possibly `lib/core/db/sqlite_store.dart` (if minor changes needed)

**What to do:**
1. Initialize `SqliteStore` when AIStudio loads (use `SqliteStore.instance`).
2. When `_selectedCatalog` changes, call `SqliteStore.listRows(catalogName)`.
3. Display rows as a `ListView` showing `n` (name) and `i` (id).
4. Add a search `TextField` at the top — filter displayed rows by `n`.
5. Add an "Add" `IconButton` in the header for UX/spec catalogs — calls `SqliteStore.upsertRow` with a new empty row.
6. Add an `onTap` to each row item that sets `_selectedRowId`.

**Done when:**
- Middle panel shows rows from SQLite for the selected catalog.
- Search filters by name.
- Add button creates a new row.
- Tapping a row selects it (for the future right panel).
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIStudio Step 3: Middle panel with SQLite-backed row list.

Current state:
- Step 2 is done — full catalog lists + selection state.
- `SqliteStore` exists at `lib/core/db/sqlite_store.dart` with `listRows`, `upsertRow`, `getRow`, `deleteRow`.
- `SqliteCatalogRow` has fields: catalog, i, a, d, e, t, n, s, payload, updatedAt.
- Shared DB builders exist, but AIStudio should stay on UX/spec CRUD rather than business-action paths or sensitive data-model CRUD.

Task:
- Init SqliteStore in AIStudio.
- Load rows by selected catalog.
- Display as ListView (show name + id).
- Add search TextField (filter by n).
- Add "Add" button (upsert empty row) for UX/spec catalogs.
- Wire row tap → _selectedRowId.

Constraints:
- Use SqliteStore.instance.
- Treat sensitive data-model CRUD as out of scope for AIStudio.
- Do not add Provider or other state management — keep setState for now.
- Keep analyzer and tests green.
```

---

## [ ] Step 4 — Right panel generic editor for UX/spec rows

**Goal:** The right panel shows a form editor for the selected UX/spec row and saves changes back to SQLite.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`

**What to do:**
1. When `_selectedRowId` is set, load the row via `SqliteStore.getRow(catalog, id)`.
2. Show `TextField` widgets for each common field: `n` (readable name), `s` (system name, prefer lower snake_case).
3. Show `Switch` or `Checkbox` for `a` (active).
4. Show read-only display for `i`, `d`, `e`, `t`.
5. Add a "Save" button that calls `SqliteStore.upsertRow` with updated data.
6. Add a "Delete" button that calls `SqliteStore.deleteRow`.
7. After save or delete, refresh the middle panel list.
8. If a sensitive data-model catalog is selected, show a note that editing for that catalog belongs in AICodex instead of AIStudio.

**Done when:**
- Selecting a row in the middle panel loads it in the right panel editor.
- Editing `n`, `s`, `a` and pressing Save persists the changes.
- Delete removes the row and refreshes the list.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIStudio Step 4: Right panel generic editor.

Current state:
- Step 3 is done — middle panel shows SQLite-backed rows.
- _selectedRowId is set when a row is tapped.

Task:
- Load the selected row via SqliteStore.getRow.
- Show editor fields: n (text), s (text), a (checkbox).
- Show read-only: i, d, e, t.
- Add Save button → upsertRow.
- Add Delete button → deleteRow.
- Refresh middle panel after save/delete.

Constraints:
- Start with the common shape for UX/spec catalogs; sensitive data-model catalogs should redirect conceptually to AICodex.
- Keep it direct — no complex form framework.
- Keep analyzer and tests green.
```

---

## [ ] Step 5 — Catalog-specific UX/spec field editing (payload)

**Goal:** Add catalog-specific editing for UX/spec rows that don't fit the common `i/a/d/e/t/n/s` shape.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`

**What to do:**
1. Add catalog-specific editor handling for UX/spec catalogs that need more than the common fields.
2. Add a collapsible "Payload" section for catalogs that still need free-form JSON.
3. Validate that any edited payload is valid JSON before saving.
4. Save catalog-specific data through the `payload` field of `SqliteCatalogRow` until dedicated storage is introduced.

**Done when:**
- The right panel shows payload editing below the common fields for other catalogs.
- Invalid JSON shows a validation error.
- Valid payload saves correctly.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIStudio Step 5: Catalog-specific UX/spec field editing.

Current state:
- Step 4 handles the common row shape for most catalogs.
- Sensitive data-model CRUD belongs to AICodex.

Task:
- Add catalog-specific editor handling for UX/spec rows that need more than the common fields.
- Keep payload editing for other catalogs that still need free-form JSON.
- Validate payload JSON before save.

Constraints:
- Do not move sensitive data-model CRUD back into AIStudio.
- Keep setState/local editing simple for now.
- Keep analyzer and tests green.
```

---

## [ ] Step 6 — AIStudio test coverage

**Goal:** Add dedicated tests for AIStudio panel behavior and SQLite CRUD flow.

**Files to change:**
- `test/aistudio_test.dart` (new)

**What to do:**
1. Test: switching tabs changes available catalog list.
2. Test: selecting a catalog loads rows from SQLite.
3. Test: adding a row creates it in SQLite and appears in the list.
4. Test: editing a row and saving persists the change.
5. Test: deleting a row removes it from SQLite and the list.

**Done when:**
- All five test scenarios pass.
- `flutter analyze` passes.
- `flutter test` passes.

---

## [ ] Step 7 — Remote transport (after local is solid)

**Goal:** Add remote load/save transport for AIStudio model rows, using the same backend contract as AIBook.

**What to do:**
1. Reuse the `Transport` class from AIBook Step 4 (or create a shared one).
2. Add load-from-server for selected catalog rows.
3. Add save-to-server when a row is saved locally.
4. Keep local SQLite as the primary store — remote is sync, not replacement.
5. Handle transport failures gracefully (show error, keep local data).

**Done when:**
- AIStudio can sync rows with a remote server.
- Local SQLite remains the source of truth.
- Transport failures don't lose local data.
- `flutter analyze` passes.
- `flutter test` passes.

---

## Architecture constraints (apply to all steps)

- Do not redesign AIBook or AICodex.
- Do not add route navigation.
- Keep one `Scaffold`, everything in `Scaffold.body`.
- AIStudio is the **UX/spec editing surface**.
- Sensitive data-model CRUD belongs to AICodex, not AIStudio.
- AIBook is the **runtime consumer** — it uses those definitions.
- Prefer row-level save units, not one giant JSON blob.
- Keep implementation direct and incremental.
- Keep analyzer and tests green after every step.

## Vocabulary quick reference

| Term | Meaning |
|---|---|
| `catalog` | A model type category (e.g., "Entity", "Field", "Host") |
| `i/a/d/e/t/n/s` | id, active, date, entity, type, readable name, system name |
| `payload` | JSON blob for catalog-specific fields beyond the common shape |
| `SqliteCatalogRow` | The generic persisted row shape in SQLite |
