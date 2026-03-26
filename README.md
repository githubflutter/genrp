# GenRP — Generative Resource Planner

A Flutter monolith with four apps sharing a common core.

## Architecture Phase Change

GenRP has successfully transitioned from an experimental "everything-is-an-action" model to a consolidated **schema-driven binding model**. 

The current repo is optimized around a single active runtime direction:

- **Autopilot** is the thin coordinator, delegating specialized state/logic to `CopilotUx` and `CopilotData` but owning the global truth via `DataSet` and `StateSet`.
- **AppRuntimeFlow** centralizes navigation and bootstrap using `UxRouteHeaderSpec` (raw) and `UxRouteSpec` (resolved).
- **UschemaRuntime** provides on-demand compilation and caching of UX specs via `UschemaCodec` and `UschemaCache`.
- **GenUx** is the spec-to-widget renderer used by the spec-driven apps (`AIWork` and `AIBook`).
- **core/ux** holds the shared UI contracts and primitives through `mixins.dart`, `template/`, and `uwidget/` (including 21 specialized field types in `uwfields/`).
- **AIStudio** and **AICodex** share the **AdminHome** shell, reusing the same UX primitives without introducing a second runtime.
- **The "Action Trio" (Command/Perform/Listener) system has been purged** in favor of direct state/data binding and system-level functions, significantly reducing architectural overhead.

## Apps

| App | Role | Entry | Status |
|---|---|---|---|
| **AIWork** | Client/workflow CRUD surface | `lib/app/aiwork/aiwork.dart` | Ready to run from spec data |
| **AIBook** | Client/runtime reader surface | `lib/app/aibook/aibook.dart` | Ready to run from spec data |
| **AIStudio** | UX/spec editing surface | `lib/app/aistudio/aistudio.dart` | Shared admin shell, halfway restored |
| **AICodex** | Sensitive data-model CRUD + schema-application surface | `lib/app/aicodex/aicodex.dart` | Shared admin shell, halfway restored |

## Quick Start

```bash
# Default entry — boots AICodex
flutter run -t lib/main.dart

# Dedicated entry points (with autoSignIn)
flutter run -t lib/main_aicodex.dart
flutter run -t lib/main_aistudio.dart
flutter run -t lib/main_aibook.dart
flutter run -t lib/main_aiwork.dart
```

`main.dart` boots directly into **AICodex**. Dedicated entry points for all apps are available, supporting `autoSignIn` for developer workflows.

## Codebase at a Glance

| Metric | Value |
|---|---|
| **Source files** (`lib/`) | 106 Dart files |
| **Source LOC** (`lib/`) | 13,373 lines |
| **Dependencies** | flutter, cupertino_icons, path, path_provider, provider, sqflite, sqflite_common_ffi |
| **Analyzer** | `flutter analyze` passes clean on 2026-03-26 |

## Project Layout

```
lib/
├── main.dart              # Default app entry (boots AICodex)
├── main_*.dart            # Dedicated app entries
├── meta.dart              # Static version flags
├── app/                   # App entry points (aiwork, aibook, aicodex, aistudio)
└── core/
    ├── agent/             # Autopilot coordinator, data/ux copilots, stores
    ├── base/              # X transport classes, DataType, sys registries/functions
    ├── db/                # SQLite store + generic PG/SQLite/remote DB builders
    ├── gen/               # AdminHome shell, AppRuntimeFlow, UschemaRuntime, GenUx
    ├── model/             # base, bschema, bdata, uschema models
    ├── theme/             # Shared Material 3 theme + UX chrome helpers
    └── ux/                # UX mixins, template/uwidget primitives, uwfields
```

## Documentation

All docs live in `docs/`. Start with:

- `docs/what_we_did.md` — log of changes and current status index.
- `docs/project_deep_analysis.md` — full architecture snapshot and subsystem analysis (Source of Truth).
- `docs/lib_app_readme.md` — app roles, backend transport contract, vocabulary.
- `docs/aibook_handover.md` — AIBook progressive handover.
- `docs/aistudio_handover.md` — AIStudio progressive handover.
- `docs/aicodex_handover.md` — AICodex progressive handover.

## Key Architecture Rules

1. **One orchestrator** — `Autopilot` owns all state and bindings.
2. **Narrow route model** — `AppRuntimeFlow` + preset specs drive app/page selection.
3. **Numeric identity** — integer IDs for all runtime references; `i = 0` for drafts.
4. **Compact transport** — base `X` with slot-addressable `v[]` for business data.
5. **Copilot split** — `CopilotData` and `CopilotUX` never merge.
6. **No `ALTER TABLE`** — schema evolution is create/drop/script oriented.
7. **Convergent shell** — AIStudio and AICodex share `AdminHome` with app-specific explorer nodes.
8. **Incremental quality** — keep analyzer green and apps runnable after every step.

## Quality Gate

Every change must pass:

```bash
flutter analyze lib
```

Current snapshot note: checked-in Dart test files have been deleted in this working tree. Manual app testing remains the primary verification path alongside clean analyzer status.
