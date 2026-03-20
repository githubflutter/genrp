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
- `AIStudio` and `AICodex` no longer imply a second runtime; they are dedicated hard-coded shells that reuse the same shared UX primitives.

Historical references in older docs to things like extra session wrappers,
body-router pipelines, `AutopilotGo`, or generator-heavy runtime layers should
be read as past experiment phases, not as the current architecture target.

## Apps

| App | Role | Entry | Status |
|---|---|---|---|
| **AIWork** | Client/workflow CRUD surface | `lib/app/aiwork/aiwork.dart` | Ready to run from spec data |
| **AIBook** | Client/runtime reader surface | `lib/app/aibook/aibook.dart` | Ready to run from spec data |
| **AIStudio** | UX/spec editing surface | `lib/app/aistudio/aistudio.dart` | Dedicated hard-coded authoring shell |
| **AICodex** | Sensitive data-model CRUD + schema-application surface | `lib/app/aicodex/aicodex.dart` | Dedicated hard-coded authoring shell |

## Quick Start

```bash
flutter run -t lib/main.dart
```

`main.dart` now boots directly into AIWork.

Current UI baseline:
- Shared Material 3 theme across all apps via `UxTheme`
- Each app owns a dedicated login screen and a dedicated loading screen
- `AIWork` and `AIBook` are currently local spec-driven through `GenUx`; the final client goal is server-spec-driven UI
- AIStudio and AICodex are currently in the hard-coded/demo authoring-shell stage and use the same convergent authoring direction
- Scaffold-level FABs are removed; actions now live in headers or active panel content

## Project Layout

```
lib/
├── main.dart              # Default app entry (boots AIWork)
├── meta.dart              # Static version flags
├── app/                   # App entry points (aiwork, aibook, aicodex, aistudio)
└── core/
    ├── agent/             # Autopilot orchestrator, copilots, actions, route state
    ├── base/              # X transport classes, DataType, sys registries
    ├── db/                # SQLite store + generic PG/SQLite/remote DB builders
    ├── gen/               # GenUx runtime builder
    ├── model/             # base, bschema, bdata, uschema (+ ux_specs.dart barrel)
    ├── theme/             # shared Material 3 theme + UX chrome helpers
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

## Key Architecture Rules

1. **One orchestrator** — `Autopilot` owns all state, bindings, and action dispatch.
2. **Narrow route model** — `CopilotRoute` + preset specs drive app/page selection; no user-facing back stack is planned.
3. **Numeric identity** — integer IDs for all runtime references, and persisted `uschema` UX-spec ids stay `int32/int4` with draft `i = 0` then first-save `max(i) + 1`.
4. **Compact transport** — base `X` with slot-addressable `v[]` for business data.
5. **Copilot split** — `CopilotData` and `CopilotUX` never merge.
6. **Foundation vs business split** — foundation tables can use direct CRUD; business-table writes go through function/action paths only.
7. **Admin/client DB split** — admin builders create databases, tables, and functions; client builders do CRUD or action-envelope work only.
8. **No `ALTER TABLE` / never-null columns** — generated columns are `NOT NULL`; schema evolution is create/drop/script oriented.
9. **Incremental** — keep analyzer green, keep tests green, keep app runnable after every step.

## Quality Gate

Every change must pass:

```bash
flutter analyze lib test
```

Current snapshot note: checked-in Dart test files have been deleted in this working tree, so `flutter analyze lib test` is currently an analyzer-only gate.
The active apps have also been manually tested in this snapshot.
