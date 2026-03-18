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
- `lib/core/db/sqlite_store.dart` only if small AIStudio-specific helpers are needed
- future tests for `AIStudio` panel, selection, and SQLite CRUD behavior

Handover cautions
- Do not redesign `AIBook`.
- Do not redesign `AICodex`.
- Do not add route navigation.
- Keep the app runnable after each step.
- Keep analyzer clean after each step.
