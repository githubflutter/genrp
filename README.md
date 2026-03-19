# GenRP — Generative Resource Planner

A Flutter monolith with three apps sharing a common core engine.

## Apps

| App | Role | Entry | Status |
|---|---|---|---|
| **AIBook** | Runtime reader / function-driven business-data consumer | `lib/app/aibook/aibook.dart` | ~80% beta; Step 2 pending |
| **AIStudio** | Model-row editing surface (definition CRUD) | `lib/app/aistudio/aistudio.dart` | Step 1 done; Step 2 pending |
| **AICodex** | Configurator / schema-application surface | `lib/app/aicodex/aicodex.dart` | Step 1 done; paused before Step 2 |

## Quick Start

```bash
flutter run -t lib/main.dart
```

A one-way launcher appears — pick AIBook, AICodex, or AIStudio.

## Project Layout

```
lib/
├── main.dart              # Launcher selector
├── meta.dart              # Static version flags
├── app/                   # App entry points (aibook, aicodex, aistudio)
└── core/
    ├── agent/             # Autopilot orchestrator, copilots, actions, transport
    ├── base/              # X transport classes, DataType, sys registries
    ├── db/                # SQLite store + generic PG/SQLite/Web DB builders
    ├── generator/         # DynamicSpecBody (body router)
    ├── model/data/        # 10 data models (Entity, Field, Table, etc.)
    ├── model/ux/          # UX spec models + registry + mapper
    ├── runtime/           # TemplateRuntime (JSON → Flutter widgets)
    ├── template/          # 4 template widgets (form, detail, collection, checkboxForm)
    └── widgets/           # 5 wrapped controls (XButton, XTextBox, XCheckBox, etc.)
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
2. **No route navigation** — single `Scaffold`, body swap only.
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
flutter analyze
flutter test
```
