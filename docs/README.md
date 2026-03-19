# Project docs

Index of documentation files in `docs/`:

## Handover & Progress (start here)

- `aibook_handover.md` — AIBook progressive step-by-step handover with micro-tasks and per-step prompts.
- `aistudio_handover.md` — AIStudio progressive step-by-step handover with micro-tasks and per-step prompts.
- `aicodex_handover.md` — AICodex progressive step-by-step handover with master-detail panels and DDL generation.

Current next steps in this snapshot:
- `AIBook` — Step 3
- `AIStudio` — Step 3
- `AICodex` — paused after Step 1; resume from Step 2 later

Current ownership reminder:
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
- `lib_core_model_data_readme.md` — docs for `lib/core/model/data` models (shared structural vocabulary).

## Guidelines

- Use snake_case filenames derived from the directory path (e.g., `lib_core_model_data_readme.md`).
- Keep docs short and point to code locations.
- Update handover docs after completing each step.
