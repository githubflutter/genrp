# GenRP

Project overview for the current repo.

## Overview

GenRP is a Flutter monolith with four app targets sharing one `core` runtime and UI foundation.

Two runtime shapes are active today:

- **AIWork** and **AIBook** are spec-driven client shells using `AppRuntimeFlow`, `Autopilot`, `UschemaRuntime`, and `GenUx`.
- **AIStudio** and **AICodex** are direct admin shells using `AdminHome`.

The older paper-centered runtime is no longer the active checked-in direction.

## Apps

| App | Role | Entry | Current state |
|---|---|---|---|
| `AIWork` | Client/workflow CRUD | `lib/app/aiwork/aiwork.dart` | Login -> loading -> spec-driven runtime |
| `AIBook` | Client/runtime reader | `lib/app/aibook/aibook.dart` | Login -> loading -> spec-driven runtime |
| `AIStudio` | UX/spec authoring | `lib/app/aistudio/aistudio.dart` | Shared `AdminHome` shell |
| `AICodex` | Data-model/schema authoring | `lib/app/aicodex/aicodex.dart` | Shared `AdminHome` shell |

## Run

```bash
flutter run -t lib/main.dart
flutter run -t lib/main_aicodex.dart
flutter run -t lib/main_aistudio.dart
flutter run -t lib/main_aibook.dart
flutter run -t lib/main_aiwork.dart
```

`main.dart` boots AICodex. `autoSignIn` is currently meaningful only in AIWork and AIBook.

## Layout

```text
lib/
├── app/        # AIWork, AIBook, AIStudio, AICodex shells
├── core/
│   ├── agent/  # Autopilot, copilots, runtime/data stores
│   ├── base/   # transport classes, type mapping, converters, helpers
│   ├── db/     # SQLite store and DB/client scaffolding
│   ├── gen/    # AppRuntimeFlow, UschemaRuntime, GenUx, AdminHome
│   ├── model/  # base, bschema, bdata, uschema models
│   ├── theme/  # shared theme helpers
│   └── ux/     # templates, uwidgets, field widgets
└── main*.dart  # entry points
```

## Current Snapshot

- `Autopilot` is the thin coordinator over `CopilotData`, `CopilotUx`, `DataSet`, and `StateSet`.
- `Tworkspace` is the only rich checked-in template path today.
- `Tsheet`, `Treport`, `Tdboard`, `Twizard`, and `Tform` are still placeholder runtime surfaces.
- `flutter analyze` passes clean.
- `flutter test` currently reports there are no checked-in `test/` files.

## Quality

```bash
flutter analyze
flutter test
```

Manual app smoke testing is still needed for behavioral confidence.

## Docs

- `docs/project_deep_analysis.md` — current architecture snapshot, metrics, findings, and verification notes
- `docs/what_we_did.md` — short project changelog
