# AIBook Handover (2026-03-25)

AIBook is the mobile-centric client/reader surface of GenRP.

## 1. Current Status ✅

- **Operational Logic**: AIBook is a spec-driven `MaterialApp` using the shared **GenUx** runtime.
- **Routing**: Handled by `AppRuntimeFlow` in `lib/core/gen/app_runtime_flow.dart`.
- **UI Architecture**: Uses `psheet`, `preport`, and `tdboard` templates from `lib/core/ux/`.
- **Data Binding**: Field-level binding (0=state, 1=dataSource, 2=dataSet) is fully operational via `UwStateAccess` on `Autopilot`.
- **Entry Points**: 
  - `lib/main_aibook.dart` (dedicated entry with auto-sign-in)
  - `lib/app/aibook/aibook.dart` (app shell)
  - `lib/app/aibook/aibook_specs.dart` (preset route definitions)

## 2. Recent Architectural Cleanup

- **Action Trio Purged**: The legacy `ActionCommand` and `ActionPerform` layers were removed. System behavior is now driven by direct state manipulation or defined functions.
- **Thin Coordinator**: `Autopilot` remains the single orchestrator but delegates specialized UX and Data logic to copilots.
- **Schema Runtime**: `UschemaRuntime` now manages compilation and caching of the `UxSpec` provided by `AIBookSpecs`.

## 3. Immediate Next Steps ⚠️

### Task 1: Real Transport Integration
- **Goal**: Replace the local `presets` in `AIBookSpecs` with a remote fetch from the C# backend.
- **File to change**: `lib/app/aibook/aibook.dart` (update `bootstrap` in `_AIBookAppState`).
- **Mechanism**: Use `WebClient` from `lib/core/db/webclient.dart` to fetch the initial `UxRouteHeaderSpec`.

### Task 2: Persistence Alignment
- **Goal**: Cache the incoming `UxSpec` from Task 1 into the `SqliteStore`.
- **Mechanism**: Update `UschemaRuntime` or `UschemaCache` to persist to SQLite when a fresh spec is received.

## 4. Key Constraints

1. **Keep it Small**: Do not add heavy dependencies. Use `dart:io` or the existing `sqflite` foundation.
2. **Numeric IDs**: Ensure all new remote specs use integer IDs for routes, templates, and widgets.
3. **No Back Stack**: AIBook routing remains flat/replacement-oriented by design.
4. **Analyzer Clean**: `flutter analyze lib` must pass after every change.
