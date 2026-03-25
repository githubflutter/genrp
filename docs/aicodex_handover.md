# AICodex Handover (2026-03-25)

AICodex is the sensitive data-model CRUD and schema-application surface of GenRP.

## 1. Current Status ✅

- **Operational Shell**: Uses the convergent **AdminHome** shell in `lib/core/gen/adminhome.dart`.
- **Navigation**: Left-side **UExplorer** is seeded with schema-model nodes (Entity, Field, Table, Column, Function, Parameter).
- **Architecture**: Shared `UxTheme` and `AdminHome` logic ensures visual parity with AIStudio.
- **Entry Points**: 
  - `lib/main_aicodex.dart` (dedicated entry with auto-sign-in)
  - `lib/app/aicodex/aicodex.dart` (app shell + explorer nodes)

## 2. Recent Architectural Cleanup

- **Convergent Shell**: AICodex and AIStudio now share the same 2-panel minor/major layout.
- **Admin Modes**: The shell supports `schema`, `preview`, and `compare` modes.
- **Action Trio Purged**: Terminal "Action" terminology has been removed in favor of system functions and direct state binding.

## 3. Immediate Next Steps ⚠️

### Task 1: Real DDL Preview
- **Goal**: In `schema` mode, show the generated PostgreSQL `CREATE TABLE` or `CREATE FUNCTION` DDL for the selected model row.
- **File to change**: `lib/app/aicodex/aicodex.dart`.
- **Mechanism**: Bind the `onSelected` callback of `UExplorer` to a state that triggers a DDL generator service (to be built).

### Task 2: bschema CRUD Wiring
- **Goal**: Enable editing of `EntityModel`, `FieldModel`, etc. using the new **UwField** system.
- **Mechanism**: When a row is selected, render an editor panel in the Major/Mid area using typed `UwField` widgets.

## 4. Key Constraints

1. **No ALTER TABLE**: Schema evolution remains create/drop/script oriented.
2. **PostgreSQL First**: The primary target for schema application is PostgreSQL.
3. **Foundation Tables**: Allow direct CRUD for foundation rows (e.g., system constants).
4. **Analyzer Clean**: `flutter analyze lib` must pass after every change.
