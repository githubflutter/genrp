# GenRP — Deep Project Analysis

> **Project:** `genrp` — Generative Resource Planner  
> **Platform:** Flutter (macOS, Linux, Windows, Android, iOS)  
> **SDK:** Dart `>=3.11.3`  
> **Analysis Date:** 2026-03-26

## Executive Summary

GenRP currently has two live runtime shapes:

| App | Role | Current posture |
|---|---|---|
| **AIWork** | Client/workflow CRUD surface | Spec-driven, login/loading/ready shell |
| **AIBook** | Client/runtime reader surface | Spec-driven, login/loading/ready shell |
| **AIStudio** | UX/spec authoring surface | Shared `AdminHome` shell, local state only |
| **AICodex** | Data-model/schema authoring surface | Shared `AdminHome` shell, local state only |

The client apps use `AppRuntimeFlow`, `Autopilot`, `UschemaRuntime`, and `GenUx`. The admin apps still mount `AdminHome` directly.

## Current Metrics

Measured from the current working tree on 2026-03-26:

| Metric | Value |
|---|---|
| Dart source files | `107` |
| Dart source LOC | `13,158` |
| Checked-in Dart test files | `0` |
| Project docs | `3` (`README.md`, this file, `docs/what_we_did.md`) |
| Analyzer | `flutter analyze` -> `No issues found!` |
| Tests | `flutter test` -> no `test/` files present |

## Architecture Snapshot

```text
main*.dart
  -> app shell
     -> AIWork/AIBook: login -> loading -> AppRuntimeFlow -> Autopilot -> UschemaRuntime -> GenUx
     -> AIStudio/AICodex: AdminHome
```

Active repo layout:

```text
lib/
├── app/
├── core/agent/
├── core/base/
├── core/db/
├── core/gen/
├── core/model/
├── core/theme/
└── core/ux/
```

## Findings From This Rerun

1. Every `main*.dart` still wraps the app in `ChangeNotifierProvider<Autopilot>`, but nothing in `lib/` reads that provider.
2. AIWork and AIBook each create a private `Autopilot` inside the home state object instead of consuming the provided instance.
3. AIStudio and AICodex accept `autoSignIn`, but both ignore it and mount `AdminHome` directly.
4. Checked-in route presets only exercise route-root `tworkspace`; no checked-in preset uses `tsheet`, `treport`, `tdboard`, `twizard`, or `tform`.
5. Those other template widgets are still placeholder surfaces rendered through `UwEmpty`.
6. `CopilotUx` still exposes `currentAppId`, `currentRouteId`, `currentOptionalId`, and `currentRootTemplateI`, but there is no write path that populates them.
7. `StateSet` now uses runtime-tree storage (`_rstate`, `_rtindex`, `_rtchildren`) instead of the older encoded ownership math.

## Verification Snapshot

Commands run:

```bash
flutter analyze
flutter test
```

Results:

- `flutter analyze` completed with `No issues found!`
- `flutter test` exited because the repo currently has no `test/` directory or `_test.dart` files

Manual smoke testing of the app entry points was not rerun during this pass.

## Recommended Next Steps

1. Pick one `Autopilot` ownership model for the entry points.
2. Remove or implement the inert `autoSignIn` flags in AIStudio and AICodex.
3. Keep docs explicit that `tworkspace` is the only active checked-in template path today.
4. Either populate the `CopilotUx` identity fields during runtime mount or remove that API surface.
5. Add a small test surface around `AppRuntimeFlow`, `UschemaRuntime`, and runtime state registration.
