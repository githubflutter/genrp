# aistudio_handover_prompt

Use the prompt below to hand off ongoing `AIStudio` work to another coding agent.

```text
Continue in `/Users/Shared/dev/git/genrp`.

You are working on `AIStudio`.

Current app state:
- `AIStudio` now has an initial three-panel shell in `lib/app/aistudio/aistudio.dart`.
- The left panel already has `Data` and `UX/Spec` tabs.
- The middle and right panels are still placeholders.
- The left-panel catalog lists are only partial right now.
- A reusable local SQLite foundation now exists in `lib/core/db/sqlite_store.dart`.

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
- `lib/core/model/data/entity_model.dart`
- `lib/core/model/data/field_model.dart`
- `lib/core/model/data/action_model.dart`
- `lib/core/model/models.dart`
- `docs/lib_app_readme.md`
```
