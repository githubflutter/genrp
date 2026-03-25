# AIStudio Handover (2026-03-25)

AIStudio is the UX/spec authoring surface of GenRP.

## 1. Current Status ✅

- **Operational Shell**: Uses the convergent **AdminHome** shell in `lib/core/gen/adminhome.dart`.
- **Explorer**: Left-side **UExplorer** is seeded with UX-spec nodes (Host, Body, Template, Type, Widget, FieldBinding, Route).
- **Architecture**: AIStudio is now narrowed to UX/Spec CRUD. Sensitive Data-model CRUD belongs to **AICodex**.
- **Entry Points**: 
  - `lib/main_aistudio.dart` (dedicated entry with auto-sign-in)
  - `lib/app/aistudio/aistudio.dart` (app shell + explorer nodes)

## 2. Recent Architectural Cleanup

- **Convergent Shell**: Shared layout (minor/major) with AICodex.
- **Action Trio Purged**: Legacy action terminology and logic (performed, listener) removed in favor of direct binding and system function calls.
- **Spec Unified**: AIStudio manages `UxSpec` (Paper, Template, View) and `UxRouteSpec` (Header + Spec + Meta).

## 3. Immediate Next Steps ⚠️

### Task 1: Spec Preview Engine
- **Goal**: In `preview` mode, render a real-time preview of the selected UX Spec.
- **Mechanism**: Bind the selected `UxSpec` to a local **GenUx** instance inside the Major area of the `AdminHome` shell.

### Task 2: uschema CRUD Wiring
- **Goal**: Enable editing of `UxPaperSpec`, `UxTemplateSpec`, etc. using the **UwField** system.
- **Mechanism**: When a row is selected (e.g., a Template), provide an editor panel in the Major area (symmetric dual-pane mode is recommended for editing and preview side-by-side).

## 4. Key Constraints

1. **UX Spec Only**: Do not cross-pollinate with data-model authoring (that's AICodex's domain).
2. **Preview Parity**: The preview in AIStudio should exactly match how it renders in AIBook/AIWork.
3. **Numeric Identity**: All newly authored `UxSpec` IDs must be integers; `i = 0` for drafts.
4. **Analyzer Clean**: `flutter analyze lib` must pass after every change.
