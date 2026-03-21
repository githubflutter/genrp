# Project docs

Index of documentation files in `docs/`:

## Handover & Progress (start here)

- `aibook_handover.md` — AIBook progressive step-by-step handover with micro-tasks and per-step prompts.
- `aistudio_handover.md` — AIStudio progressive step-by-step handover with micro-tasks and per-step prompts.
- `aicodex_handover.md` — AICodex progressive step-by-step handover with master-detail panels and DDL generation.

Current verification in this snapshot:
- `flutter analyze lib test` passes on `2026-03-21`.
- All four active apps have already been manually tested in this snapshot.
- Checked-in Dart test files have been deleted in this working tree.

Current handover status in this snapshot:
- `AIWork` — ready-to-run spec-driven client surface; no dedicated handover doc yet.
- `AIBook` — ready-to-run spec-driven client surface; the handover doc keeps older pre-`core/ux` steps as historical context.
- `AIStudio` — dedicated hard-coded authoring shell with app-owned seeded section data and shared UX components; older step history remains as context.
- `AICodex` — dedicated hard-coded authoring shell with app-owned seeded section data and shared UX components; older step history remains as context.

Current next focus:
- Continue feature work on the dedicated AIStudio/AICodex shells while reusing shared UX components and keeping their current hard-coded/demo stage explicit in the docs.
- Keep the client-app direction clear: `AIWork` / `AIBook` are local spec-driven today, but the final target is server-spec-driven UI after the real transport/bootstrap path is wired.
- Keep using `flutter analyze lib test` plus manual app runs as the active validation path for this snapshot.
- Add an `AIWork` handover doc when active feature work begins there.

Current UI baseline in this snapshot:
- Shared Material 3 theme via `UxTheme` across the main entry and app modules
- Each app currently owns a dedicated login screen before the loading/ready flow
- All four apps use the same login -> loading -> ready stage flow
- AIStudio and AICodex still share the convergent authoring-shell direction
- Scaffold FABs are gone; actions should live in headers or active panel content

Current ownership reminder:
- `AIWork` is a desktop/tablet-centric client app.
- `AIBook` is a mobile-centric client app.
- `AIWork` and `AIBook` are client CRUD apps only.
- `AIWork` and `AIBook` do not own data designer or UX designer surfaces.
- `AIStudio` owns UX/spec CRUD.
- `AICodex` owns sensitive data-model CRUD plus schema apply/generation work.
- `AIBook` owns runtime business-data consumption through function-style actions.

## Architecture & Contracts

- `project_deep_analysis.md` — full architecture analysis with diagrams, subsystem breakdowns, data flow, gap analysis, and roadmap.
- `project_deep_analysis.md` also records the phase change from the older engine/runtime/renderer/builder/generator overlap into the current single active runtime path.
- `lib_app_readme.md` — app roles, backend transport contract, shared DB builder split, vocabulary, and naming rules.
- `spec_first_schema_experiments.md` — experimental plan for moving schemas to spec documents after September 2026.

## Code Reference

- `lib_core_base_data_type_readme.md` — docs for `lib/core/base/data_type.dart` (DataType + TypeMapper).
- `lib_core_base_x_readme.md` — docs for `lib/core/base/x.dart` (base X transport hierarchy).
- `lib_core_db_sqlite_store_readme.md` — docs for `lib/core/db/sqlite_store.dart` (SQLite store).
- `lib_core_model_bschema_readme.md` — docs for `lib/core/model/bschema` models, with notes about special base models now living under `lib/core/model/base`.

## Guidelines

- Use snake_case filenames derived from the directory path (e.g., `lib_core_model_bschema_readme.md`).
- Keep docs short and point to code locations.
- Update handover docs after completing each step.
