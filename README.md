# GenRP — Generative Resource Planner

A Flutter monolith with four apps sharing a common core.

## Architecture Phase Change

Early GenRP went through a long exploratory phase where the docs and code used
many overlapping labels for nearby responsibilities: engine, runtime,
renderer, builder, generator, router, session, and layout helper. That phase
was useful for discovery, but it also meant the architecture could read as
several partially competing stacks around the same UX problem.

The current repo is intentionally simpler. There is now one active runtime
direction:

- `Autopilot` is the single orchestrator for app state, bindings, actions, and route state.
- `GenUx` is the spec renderer used by the spec-driven apps (`AIWork` and `AIBook`).
- `core/ux` holds the shared UI contracts and primitives through `mixins.dart`, `paper/`, `template/`, and `uwidget/`.
- `AIStudio` and `AICodex` no longer imply a second runtime; they delegate to a shared `AdminHome` shell that reuses the same UX primitives.

Historical references in older docs to things like extra session wrappers,
body-router pipelines, `AutopilotGo`, or generator-heavy runtime layers should
be read as past experiment phases, not as the current architecture target.

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
```

`main.dart` boots directly into **AICodex**. Dedicated entry points for AICodex and AIStudio skip the login screen via `autoSignIn: true`.

Current UI baseline:
- Shared Material 3 theme across all apps via `UxTheme`
- `AIWork` and `AIBook` own dedicated login → loading → ready stage flows with `Autopilot`
- `AIStudio` and `AICodex` delegate directly to `AdminHome` with app-specific title, status text, and explorer nodes
- `AdminHome` provides a left explorer panel + mode-driven detail area (`schema` / `preview` / `compare`)
- `AICodex` uses flat bschema nodes (Entity, Field, Table, Column, Function, Parameter)
- `AIStudio` uses hierarchical default nodes (Business → Entity/Field, Database → Table/Column/Function)
- Scaffold-level FABs are removed; actions now live in headers or active panel content

## Codebase at a Glance

| Metric | Value |
|---|---|
| **Source files** (`lib/`) | 83 Dart files |
| **Source LOC** (`lib/`) | ~8,509 lines |
| **Dependencies** | flutter, cupertino_icons, path, path_provider, provider, sqflite, sqflite_common_ffi |
| **Analyzer** | `flutter analyze` passes clean |

## Project Layout

```
lib/
├── main.dart              # Default app entry (boots AICodex)
├── main_aistudio.dart     # AIStudio dedicated entry (autoSignIn)
├── main_aicodex.dart      # AICodex dedicated entry (autoSignIn)
├── meta.dart              # Static version flags
├── app/                   # App entry points (aiwork, aibook, aicodex, aistudio)
├── hub/                   # Reserved (empty)
└── core/
    ├── agent/             # Autopilot orchestrator, copilots, actions, route state
    ├── base/              # X transport classes, DataType, sys registries
    ├── db/                # SQLite store + generic PG/SQLite/remote DB builders
    ├── gen/               # AdminHome shell, GenUx runtime, explorer, authoring panels
    ├── model/             # base, bschema, bdata, uschema (+ ux_specs.dart barrel)
    ├── theme/             # Shared Material 3 theme + UX chrome helpers
    └── ux/                # UX mixins, paper/template/uwidget primitives, UX barrel
```

## Documentation

All docs live in `docs/`. Start with:

- `docs/README.md` — index of all docs
- `docs/project_deep_analysis.md` — current architecture snapshot and subsystem analysis
- `docs/aibook_handover.md` — AIBook progressive handover (start here for AIBook work)
- `docs/aistudio_handover.md` — AIStudio progressive handover (start here for AIStudio work)
- `docs/aicodex_handover.md` — AICodex progressive handover (start here for AICodex work)
- `docs/lib_app_readme.md` — architecture, transport contract, vocabulary
- `docs/bschema_uschema_reshape_plan.md` — forward plan for spec-first schema documents
- `docs/toexperiment_after_v2_launched.md` — post-v2 experiment ideas

## Key Architecture Rules

1. **One orchestrator** — `Autopilot` owns all state, bindings, and action dispatch.
2. **Narrow route model** — `CopilotRoute` + preset specs drive app/page selection; no user-facing back stack is planned.
3. **Numeric identity** — integer IDs for all runtime references, and persisted `uschema` UX-spec ids stay `int32/int4` with draft `i = 0` then first-save `max(i) + 1`.
4. **Compact transport** — base `X` with slot-addressable `v[]` for business data.
5. **Copilot split** — `CopilotData` and `CopilotUX` never merge.
6. **Foundation vs business split** — foundation tables can use direct CRUD; business-table writes go through function/action paths only.
7. **Admin/client DB split** — admin builders create databases, tables, and functions; client builders do CRUD or action-envelope work only.
8. **No `ALTER TABLE` / never-null columns** — generated columns are `NOT NULL`; schema evolution is create/drop/script oriented.
9. **Convergent shell** — AIStudio and AICodex share `AdminHome` with app-specific explorer nodes and data; role differences stay semantic rather than structural.
10. **Incremental** — keep analyzer green, keep tests green, keep app runnable after every step.

## Quality Gate

Every change must pass:

```bash
flutter analyze lib test
```

Current snapshot note: checked-in Dart test files have been deleted in this working tree, so `flutter analyze lib test` is currently an analyzer-only gate.
The active apps have also been manually tested in this snapshot.
