# Project docs

Index of documentation files in `docs/`:

## Handover & Progress (start here)

- `aibook_handover.md` — AIBook progressive step-by-step handover with micro-tasks and per-step prompts.
- `aistudio_handover.md` — AIStudio progressive step-by-step handover with micro-tasks and per-step prompts.
- `aicodex_handover.md` — AICodex progressive step-by-step handover with master-detail panels and DDL generation.

Current next steps in this snapshot:
- `AIBook` — Step 3
- `AIStudio` — Step 4
- `AICodex` — Step 4

Current UI baseline in this snapshot:
- Shared dark Material 3 theme across launcher and apps
- AIStudio and AICodex share one hybrid shell
- Dual authoring mode currently uses a `20 / 60 / 20` layout
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
- `lib_app_readme.md` — app roles, backend transport contract, shared DB builder split, vocabulary, and naming rules.

## Code Reference

- `lib_core_base_data_type_readme.md` — docs for `lib/core/base/data_type.dart` (DataType + TypeMapper).
- `lib_core_base_x_readme.md` — docs for `lib/core/base/x.dart` (base X transport hierarchy).
- `lib_core_db_sqlite_store_readme.md` — docs for `lib/core/db/sqlite_store.dart` (SQLite store).
- `lib_core_model_bschema_readme.md` — docs for `lib/core/model/bschema` models, with notes about special base models now living under `lib/core/model/base`.

## Guidelines

- Use snake_case filenames derived from the directory path (e.g., `lib_core_model_bschema_readme.md`).
- Keep docs short and point to code locations.
- Update handover docs after completing each step.
