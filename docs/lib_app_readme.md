**Apps: AIBook, AICodex, AIStudio**

- **Purpose:** Combined documentation for the app entry points under `lib/app/`.
- **Location:** [lib/app](lib/app)

**Overview**

This document describes the current app entry points:

- `AIBook` — [lib/app/aibook.dart](lib/app/aibook.dart)
- `AICodex` — [lib/app/aicodex.dart](lib/app/aicodex.dart)
- `AIStudio` — [lib/app/aistudio.dart](lib/app/aistudio.dart)

Current semantic split
- `AIStudio` is the model-row editing surface. It performs CRUD on stored model rows such as `EntityModel` and `FieldModel`.
- `AICodex` is the configurator/schema-application surface. It uses those models to create, drop, and alter generated table/function structure.
- `AIBook` is the row-level CRUD consumer. It uses the generated structures produced from those models rather than owning schema authoring directly.

Backend transport contract
- The server layer is a C# ASP.NET Core Minimal Web API with a single endpoint URL.
- The endpoint accepts `POST` only.
- The request body is handed over as JSON directly; the C# server does not map the body into business-model objects first.
- PostgreSQL returns JSON directly, and the C# server returns that JSON without converting it into response model objects.
- PostgreSQL owns the central router function that interprets the request and performs CRUD behavior.

Request body shape
- `a` — action ID (`bigint`).
- `u` — username.
- `p` — password.
- `data` — the actual payload JSON.

Example request

```json
{
  "a": 1001,
  "u": "demo",
  "p": "secret",
  "data": {
    "i": 0,
    "n": "User"
  }
}
```

Edit rule
- There is no separate `insert`, `update`, or `delete` endpoint/function surface.
- Each model uses one edit-style function such as `edit_modelname`.
- `data.i == 0` means insert.
- `data.i > 0` means update.
- Updates are partial; only the fields that actually changed are posted.
- There is no hard delete.
- Soft delete means posting `data.a = false`.

Planned UX spec note
- A separate UX/UI spec surface is planned for `AIBook`.
- That future work is intended to live under `lib/core/model/ux`.
- It is not implemented yet and should be treated as experimental rather than stable.
- For `AIBook`, those UX models will act as UX/UI spec.
- For `AIStudio`, those same UX models are expected to act as editable models.

Each app:

- Is a minimal `MaterialApp` with `debugShowCheckedModeBanner: false`.
- Exposes a top-level widget (`AIBookApp`, `AICodexApp`, `AIStudioApp`) — no `main()` inside these files.
- Shows a `FloatingActionButton` (FAB) for a sample action.
- Shows a right-aligned bottom status bar in the `BottomAppBar` containing:

  `<AppName>:<number>/<f>/<v>`

  where `<number>` is the app-specific flag and `f` / `v` are the global flags provided by `lib/meta.dart`.

**How to run each app**

Start any app directly with Flutter by targeting its file. Example:

```bash
flutter run -t lib/app/aibook.dart
```

**Where to change the values**

- Per-app numbers are defined in `lib/meta.dart` as `AppMeta.aibook`, `AppMeta.aicode`, `AppMeta.aistudio`.
- Global flags are `AppMeta.f` and `AppMeta.v`.

**Customization notes**

- Change FAB behavior by editing the `floatingActionButton.onPressed` in the relevant file.
- Modify status format by editing the `BottomAppBar` text in the app's file.

**Next steps**

- Expand app-specific docs as each app moves from placeholder UI into its intended workflow role.
