# aistudio_handover_prompt

Use the prompt below to hand off ongoing `AIStudio` work to another coding agent.

```text
Continue in `/Users/Shared/dev/git/genrp`.

You are working on `AIStudio`.

Current app state:
- `AIStudio` is still a placeholder app in `lib/app/aistudio.dart`.
- It is currently a minimal `MaterialApp` with a single `Scaffold`, placeholder body text, FAB, and bottom status bar.

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
1. Replace the placeholder center body in `lib/app/aistudio.dart` with a three-panel `Row`.
2. Add local `AIStudio` state for:
   - active left tab
   - selected catalog type
   - selected row id
   - optional search/filter text
3. Build the left panel first with the `Data` and `UX/Spec` tabs.
4. Build the middle panel second with sample rows and selection.
5. Build the right panel third with a generic editor for the common `i/a/d/e/t/n/s` shape.
6. Start with in-memory sample data only.
7. After shell interaction feels right, add the `UX/Spec` catalog set.
8. Only after that, add real load/save transport.

Important constraints:
- Do not redesign `AIBook`.
- Do not redesign `AICodex`.
- Do not add route navigation.
- Keep implementation incremental.
- Keep the app runnable after each step.
- Keep analyzer clean after each step.

Immediate next recommended step:
- Implement Phase 1 only:
  - three-panel shell
  - left panel with `Data` and `UX/Spec` tabs
  - middle panel placeholder list
  - right panel placeholder editor

Relevant files:
- `lib/app/aistudio.dart`
- `lib/core/model/data/entity_model.dart`
- `lib/core/model/data/field_model.dart`
- `lib/core/model/data/action_model.dart`
- `lib/core/model/models.dart`
- `docs/lib_app_readme.md`
```
