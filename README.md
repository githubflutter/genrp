# GenRP — Generative Resource Planner

A Flutter monolith with four apps sharing a common core engine.

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

A launcher appears — pick AIWork, AIBook, AICodex, or AIStudio.

Current UI baseline:
- Shared Material 3 theme across all apps via `UxTheme`
- Each app owns a dedicated login screen and a dedicated loading screen
- AIStudio and AICodex use the same convergent authoring direction
- Scaffold-level FABs are removed; actions now live in headers or active panel content

## Project Layout

```
lib/
├── main.dart              # Launcher selector
├── meta.dart              # Static version flags
├── app/                   # App entry points (aiwork, aibook, aicodex, aistudio)
└── core/
    ├── agent/             # Autopilot orchestrator, copilots, actions, route state
    ├── base/              # X transport classes, DataType, sys registries
    ├── db/                # SQLite store + generic PG/SQLite/remote DB builders
    ├── model/             # base, bschema, bdata, uschema
    ├── theme/             # shared Material 3 theme + UX chrome helpers
    └── ux/                # GenUx runtime, papers, templates, views, UX barrel
```

## Documentation

All docs live in `docs/`. Start with:

- `docs/README.md` — index of all docs
- `docs/aibook_handover.md` — AIBook progressive handover (start here for AIBook work)
- `docs/aistudio_handover.md` — AIStudio progressive handover (start here for AIStudio work)
- `docs/aicodex_handover.md` — AICodex progressive handover (start here for AICodex work)
- `docs/lib_app_readme.md` — architecture, transport contract, vocabulary

## Key Architecture Rules

1. **One orchestrator** — `Autopilot` owns all state, bindings, and action dispatch.
2. **Narrow route model** — `CopilotRoute` + preset specs drive app/page selection; no user-facing back stack is planned.
3. **Numeric identity** — integer IDs for all runtime references (body, template, widget, action, binding).
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
