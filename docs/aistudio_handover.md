# aistudio_handover

Current AIStudio status and ordered handover plan.

Current status
- Roughly `35%` of the intended `AIStudio` shell.
- `AIStudio` is no longer a placeholder-only screen.
- A three-panel shell exists inside one `Scaffold.body`.
- The left panel already has `Data` and `UX/Spec` tabs.
- The middle and right panels are still placeholders.
- The left-panel catalog lists are still incomplete.
- A reusable local SQLite foundation now exists and is ready for `AIStudio` catalog persistence.
- Under `lib/core/db`, future `AIStudio` db code should live under `lib/core/db/aistudio/`.
- Current verification status: `flutter analyze` passed and `flutter test` passed.

Implemented now
- `lib/app/aistudio/aistudio.dart`
  Provides:
  - one `Scaffold`
  - left panel with `Data` and `UX/Spec` tabs
  - middle placeholder panel
  - right placeholder panel
  - existing FAB and bottom status bar
- `lib/core/db/sqlite_store.dart`
  Provides a generic local SQLite store suitable for `AIStudio` catalog rows and JSON key/value storage.
  This is shared infrastructure; `AIStudio`-specific db code should move under `lib/core/db/aistudio/`.

Current left-panel content
- `Data`
  - `Entity`
  - `Field`
  - `Relation`
  - `Action`
  - `Function`
- `UX/Spec`
  - `Host`
  - `Body`
  - `Template`
  - `Type`
  - `Widget`

What is still missing
- No persistent local state for:
  - active tab
  - selected catalog
  - selected row id
  - search/filter
- No real middle-panel list for the selected catalog.
- No real right-panel editor/inspector.
- No actual `AIStudio` wiring to the new SQLite store yet.
- No complete `Data` catalog coverage yet.
- No complete `UX/Spec` catalog coverage yet.
- No row-level CRUD flow yet.
- No dedicated `AIStudio` test coverage yet.

Architecture direction
- Keep one `Scaffold` and put everything in `Scaffold.body`.
- Do not add route navigation.
- Keep `AIStudio` as the model-row editing surface.
- Keep `AIBook` as the runtime consumer.
- Prefer row-level save units for UX/spec authoring, not one giant primary JSON blob.
- Keep implementation direct and incremental.
- Under `lib/core/db`, app-facing db code should move toward app-specific directories such as `lib/core/db/aistudio/`.

Ordered handover plan
1. Add local `AIStudio` state in `lib/app/aistudio/aistudio.dart`.
   Track active tab, selected catalog, selected row id, and optional search/filter text.
2. Finish the left-panel catalog lists.
   Add the missing `Data` entries:
   - `Parameter`
   - `Table`
   - `Column`
   - `System`
   - `User`
   Add the missing `UX/Spec` entries:
   - `FieldBinding`
   - `UX Action`
   - `Body Spec Node`
3. Make the middle panel respond to selected catalog and load rows from `SqliteStore`.
   Show current catalog name, search, add button, and SQLite-backed rows.
4. Build the right panel as a generic editor shell and save rows back through `SqliteStore`.
   Start with the common `i/a/d/e/t/n/s` shape plus optional JSON `payload`.
5. Add row-level UX/spec editing shapes after the shell is stable.
6. Add dedicated `AIStudio` tests for panel switching, row selection, and SQLite-backed CRUD flow.
7. Add real remote load/save transport only after local SQLite-backed editing structure is solid.

Immediate next recommended step
- Add local `AIStudio` state and make the middle panel load rows by selected catalog from `SqliteStore`.

Files expected to change next
- `lib/app/aistudio/aistudio.dart`
- `lib/core/db/aistudio/` for `AIStudio`-specific db wiring
- `lib/core/db/sqlite_store.dart` only while shared low-level SQLite foundation is still being reused
- future tests for `AIStudio` panel, selection, and SQLite CRUD behavior

Handover cautions
- Do not redesign `AIBook`.
- Do not redesign `AICodex`.
- Do not add route navigation.
- Keep the app runnable after each step.
- Keep analyzer clean after each step.

Copy-paste prompt

```text
Continue in `/Users/Shared/dev/git/genrp`.

You are working on `AIStudio`.

Current app state:
- `AIStudio` now has an initial three-panel shell in `lib/app/aistudio/aistudio.dart`.
- The left panel already has `Data` and `UX/Spec` tabs.
- The middle and right panels are still placeholders.
- The left-panel catalog lists are only partial right now.
- A reusable local SQLite foundation now exists in `lib/core/db/sqlite_store.dart`.
- Under `lib/core/db`, future `AIStudio` db code should live under `lib/core/db/aistudio/`.

Role of AIStudio:
- `AIStudio` is the model-row editing surface.
- It should edit stored model-definition rows for both data-side models and UX/spec-side models.
- `AIBook` remains the runtime consumer.
- `AICodex` remains the configurator/schema-application surface.

Requested target layout:
- Build `AIStudio` as a three-panel setup inside one `Scaffold.body`.
- Left panel = navigation only.
- Middle panel = list for the selected model/spec type.
- Right panel = editor/inspector for the selected row.

Left panel requirement:
- Left panel must have two tabs:
  1. `Data`
  2. `UX/Spec`

Left panel tab contents:
- `Data` tab should list model types under `lib/core/model/data`, especially:
  - `Entity`
  - `Field`
  - `Relation`
  - `Action`
  - `Function`
  - `Parameter`
  - `Table`
  - `Column`
  - `System`
  - `User`
- `UX/Spec` tab should list the UX/spec units that need to be saved in database, especially:
  - `Host`
  - `Body`
  - `Template`
  - `Type`
  - `Widget`
  - `FieldBinding`
  - `UX Action`
  - `Body Spec Node`

Current implemented shell state:
- Left panel exists with:
  - `Data` tab
  - `UX/Spec` tab
- Current `Data` list is only:
  - `Entity`
  - `Field`
  - `Relation`
  - `Action`
  - `Function`
- Current `UX/Spec` list is only:
  - `Host`
  - `Body`
  - `Template`
  - `Type`
  - `Widget`
- Middle panel is currently placeholder text.
- Right panel is currently placeholder text.
- No dedicated `AIStudio` state model or selection flow exists yet.
- No actual `AIStudio` wiring to the SQLite store exists yet.

Architecture direction:
- Keep the UI simple and efficient.
- Do not introduce route navigation for this.
- Keep one `Scaffold` and put the three-panel setup inside `Scaffold.body`.
- Prefer direct implementation and minimal abstraction.
- Treat `Ux*Model` as definition-side UX/UI data.
- If UX/spec is persisted, prefer row-level save units rather than one giant primary JSON blob.

Recommended panel responsibilities:
- Left panel:
  - tab switcher
  - catalog list
- Middle panel:
  - current catalog header
  - search/filter
  - add button
  - list of rows for the selected catalog
- Right panel:
  - editor for selected row
  - save/delete/clone actions
  - optional raw JSON preview for debugging

Recommended build order:
1. Keep the existing three-panel shell and add local `AIStudio` state for:
   - active left tab
   - selected catalog type
   - selected row id
   - optional search/filter text
2. Finish the left panel catalog lists so they cover the intended data and UX/spec units.
3. Build the middle panel next with SQLite-backed rows, current-catalog header, search, and selection.
4. Build the right panel next with a generic editor for the common `i/a/d/e/t/n/s` shape and save back to SQLite.
5. After shell interaction feels right, add the missing `UX/Spec` catalog set and row-level editing shapes.
6. Add dedicated `AIStudio` tests for panel and SQLite CRUD behavior.
7. Only after that, add real remote load/save transport.

Important constraints:
- Do not redesign `AIBook`.
- Do not redesign `AICodex`.
- Do not add route navigation.
- Keep implementation incremental.
- Keep the app runnable after each step.
- Keep analyzer clean after each step.

Immediate next recommended step:
- Implement Phase 2:
  - local `AIStudio` selection state
  - complete left-panel catalog lists
  - middle panel that changes based on selected catalog and reads rows from SQLite
  - keep right panel simple placeholder if needed for this step

Relevant files:
- `lib/app/aistudio/aistudio.dart`
- `lib/core/db/sqlite_store.dart`
- future `AIStudio`-specific db files under `lib/core/db/aistudio/`
- `lib/core/model/data/entity_model.dart`
- `lib/core/model/data/field_model.dart`
- `lib/core/model/data/action_model.dart`
- `lib/core/model/models.dart`
- `docs/lib_app_readme.md`
```
