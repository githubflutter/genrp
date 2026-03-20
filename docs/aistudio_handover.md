# AIStudio Handover

Progressive step-by-step plan to build the AIStudio UX/spec editing surface.

**Current status:** Step 3 is done, and the shared hybrid shell is in place — shared dark Material 3 theme, minor panel with two tabs, major panel with three tabs, UX/spec catalog navigation, local selection state, full UX/spec catalog list, SQLite-backed middle-panel row loading, search, draft-first add/new flow, and major-panel placeholders are all in place. Step 4 is next.

**Current next step:** Step 4 — Right panel generic editor for UX/spec rows.

**Scope rule:** Sensitive data-model CRUD now belongs to `AICodex`. AIStudio is now narrowed to UX/spec CRUD and should stay on that path.

**Boundary reminder:** `AIWork` and `AIBook` are client apps, not designer apps. AIStudio should not move UX/spec authoring work into those client surfaces.

**Special rule:** `System` and `Usr` are base-side models under `lib/core/model/base/`, not normal `i/a/d/e/t/n/s` rows. `SystemModel` is structural metadata (`sid`, `n`, `fv`, `cv`, `ld`, `lds`, `ldu`, `ctm`, `uxm`, `m1`, `m2`) and belongs to the sensitive data-model side owned by `AICodex`.

**UX integer rule:** For `uschema`, `i` and `e` stay `int4`. New drafts should start with `i = 0`, and save/edit decides insert vs update: `i = 0` allocates `max(i) + 1`, while `i > 0` updates in place. `d` stays the last date/time integer, usually UTC epoch milliseconds, and should remain web-safe `int^53`. UX rows should not become real database foreign-key owners of the data-model layer.

**Convergent UI rule:** AIStudio should use the same hybrid shell as AICodex:
- left side = **minor panel**
- right side = **major panel**
- minor panel has **two tabs**
- major panel has **three tabs**
- major tab 1 = single mid panel only
- major tab 2 = larger mid + smaller right
- major tab 3 = equal mid + right
- current shell width baseline = `20%` minor + `80%` major
- current dual-mode working split = `20 / 60 / 20`
- the shared shell contract is layout/tab/chrome only
- AIStudio still owns its own left explorer/list mechanism inside that shell
- functional UX/spec work should now continue inside that shared shell

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

- [x] Shared hybrid shell inside one `Scaffold.body`
- [x] Left panel with UX/spec catalog navigation
- [x] UX/spec list: Host, Body, Template, Type, Widget, UX Action, FieldBinding, Body Spec Node
- [x] Local selection state for selected catalog and selected row
- [x] Middle panel header updates from the selected catalog
- [x] Selected catalog is visually highlighted
- [x] Shared dark Material 3 theme + centralized chrome sizing
- [x] Bottom status bar
- [x] No scaffold FAB; future actions should live in header/panel content
- [x] SQLite-backed middle-panel row list for selected UX/spec catalog
- [x] Search filter by `n`
- [x] Draft-first add/new flow with local `i = 0` rows
- [x] Right-side placeholder reacts to draft-vs-selected row state
- [x] Dedicated AIStudio widget coverage for list/search/draft behavior
- [x] `SqliteStore` shared foundation wired into AIStudio list flow
- [x] Shared DB scaffolding exists: `db_contract`, PG/SQLite admin+client builders, and system entrypoint seeds

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
5. Preserve current AIStudio selection behavior inside the new shell.
6. Keep the left explorer/list mechanism app-owned rather than moving it into the shell contract.

**Done when:**
- AIStudio uses the shared hybrid shell.
- The old fixed three-panel layout is gone.
- Current selection/header behavior still works inside the new shell.
- The shared shell remains a layout/tab mechanism only.

---

## [x] Step 1 — Add local selection state

**Status:** Done in the current repo snapshot.

**Goal:** Track what the user has selected so the middle and right panels can respond.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`

**What to do:**
1. Convert `AIStudioApp` to use a `StatefulWidget` for the home scaffold.
2. Add state fields:
   - `String? _selectedCatalog` (e.g., `'Host'`)
   - `int? _selectedRowId`
3. When a left-panel `ListTile` is tapped, set `_selectedCatalog` to that item's name.
4. Show the selected catalog name as a header in the middle panel (replace placeholder text).
5. Keep right panel as placeholder for now.

**Done when:**
- Tapping a left-panel item updates the middle panel header.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIStudio Step 1: Add local selection state.

Current state:
- `lib/app/aistudio/aistudio.dart` has a three-panel static layout.
- Left panel is intended to hold the UX/spec collection list.
- Middle and right panels are placeholder text.

Task:
- Make the home a StatefulWidget.
- Add state: _selectedCatalog, _selectedRowId.
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

## [x] Step 2 — Complete left-panel UX/spec catalog list

**Status:** Done in the current repo snapshot.

**Goal:** Finish the UX/spec explorer list and make the current selection visually obvious.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`

**What to do:**
1. Add missing UX/spec entries:
   - `FieldBinding`
   - `Body Spec Node`
2. Add a visual indicator (e.g., background color or leading icon) for the currently selected catalog.
3. Keep AIStudio focused on UX/spec collection/explorer behavior; sensitive data-model catalogs belong to AICodex.

**Done when:**
- Left panel shows: Host, Body, Template, Type, Widget, UX Action, FieldBinding, Body Spec Node.
- Selected catalog is visually highlighted.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIStudio Step 2: Complete left-panel UX/spec catalog list.

Current state:
- Step 1 is done — local selection state exists.
- AIStudio should focus on UX/spec.
- Current list has: Host, Body, Template, Type, Widget, UX Action.

Task:
- Add UX/Spec entries: FieldBinding, Body Spec Node.
- Highlight the selected catalog visually (e.g., selected ListTile color).

Constraints:
- Do not move sensitive data-model browsing back into AIStudio.
- Keep analyzer green.
```

---

## [x] Step 3 — Middle panel with SQLite-backed UX/spec row list

**Status:** Done in the current repo snapshot.

**Goal:** The middle panel shows rows from `SqliteStore` for the selected UX/spec catalog, with search and a draft-first add/new action.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`
- possibly `lib/core/db/sqlite_store.dart` (if minor changes needed)

**What to do:**
1. Initialize `SqliteStore` when AIStudio loads (use `SqliteStore.instance`).
2. When `_selectedCatalog` changes, call `SqliteStore.listRows(catalogName)`.
3. Display rows as a `ListView` showing `n` (name) and `i` (id).
4. Add a search `TextField` at the top — filter displayed rows by `n`.
5. Add a "New" `IconButton` in the header for UX/spec catalogs — create a local draft row with `i = 0` instead of inserting immediately.
6. Add an `onTap` to each row item that sets `_selectedRowId`.
7. Place the collection UI inside the active major-tab content after the hybrid shell is in place.

**Done when:**
- Middle panel shows rows from SQLite for the selected catalog.
- Search filters by name.
- Add/New opens a draft row with `i = 0`.
- Tapping a row selects it (for the future right panel).
- `flutter analyze` passes.
- `flutter test` passes.

**Snapshot notes:**
- `AIStudio` now initializes `SqliteStore` and loads rows for the selected UX/spec catalog.
- Search filters the visible rows by `n`.
- Add/New creates a local draft row with `i = 0` instead of inserting immediately.
- Selecting a row updates right-panel placeholder state for the future editor step.
- Basic widget coverage exists in `test/aistudio_app_test.dart`.

---

## [ ] Step 4 — Right panel generic editor for UX/spec rows

**Goal:** The right-side workspace inside the active major tab shows a form editor for the selected UX/spec row and saves changes back to SQLite.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`

**What to do:**
1. When `_selectedRowId` is set, load the row via `SqliteStore.getRow(catalog, id)` for persisted rows, but use the local draft row directly when `i = 0`.
2. Show `TextField` widgets for each common field: `n` (readable name), `s` (system name, prefer lower snake_case).
3. Show `Switch` or `Checkbox` for `a` (active).
4. Show read-only display for `i`, `d`, `e`, `t`.
5. Add a "Save" button that calls `SqliteStore.upsertRow` with updated data.
6. Add a "Delete" button that calls `SqliteStore.deleteRow`.
7. After save or delete, refresh the middle panel list.
8. If a sensitive data-model catalog is selected, show a note that editing for that catalog belongs in AICodex instead of AIStudio.
9. Keep the editor inside the active major-tab workspace area of the hybrid shell.
10. Follow the same draft-first rule as AICodex: if the current row has `i = 0`, Save allocates `max(i) + 1`; if `i > 0`, Save updates in place.

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
- Draft rows can already be created locally with `i = 0`; the right panel still needs the real save/delete editor.

Task:
- Load the selected row via SqliteStore.getRow.
- Show editor fields: n (text), s (text), a (checkbox).
- Show read-only: i, d, e, t.
- Add Save button → upsertRow.
- Add Delete button → deleteRow.
- Refresh middle panel after save/delete.

Constraints:
- Start with the common shape for UX/spec catalogs only.
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

**Goal:** Extend the existing AIStudio widget coverage to include full editor save/delete behavior and deeper SQLite CRUD flow.

**Files to change:**
- `test/aistudio_app_test.dart`

**What to do:**
1. Test: selecting a UX/spec catalog updates the middle-panel header.
2. Test: selecting a catalog loads rows from SQLite.
3. Test: adding a draft row keeps `i = 0` locally, and saving it creates the persisted SQLite row.
4. Test: editing a row and saving persists the change.
5. Test: deleting a row removes it from SQLite and the list.

**Done when:**
- All five test scenarios pass.
- `flutter analyze` passes.
- `flutter test` passes.

---

## [ ] Step 7 — Remote transport (after local is solid)

**Goal:** Add remote load/save transport for AIStudio UX/spec rows, using the same backend contract as AIBook.

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
| `catalog` | A model type category (e.g., "Host", "Body", "Template") |
| `i/a/d/e/t/n/s` | id, active, last date, editor, type, readable name, system name |
| `payload` | JSON blob for catalog-specific fields beyond the common shape |
| `SqliteCatalogRow` | The generic persisted row shape in SQLite |
