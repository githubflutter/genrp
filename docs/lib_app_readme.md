**Apps: AIBook, AICodex, AIStudio**

- **Purpose:** Combined documentation for the app entry points under `lib/app/`.
- **Location:** [lib/app](lib/app)

**Overview**

This document describes the current app entry points:

- `AIBook` — [lib/app/aibook.dart](lib/app/aibook.dart)
- `AICodex` — [lib/app/aicodex.dart](lib/app/aicodex.dart)
- `AIStudio` — [lib/app/aistudio.dart](lib/app/aistudio.dart)

Main constitution
- Performance and efficiency come first.
- Prefer direct, low-overhead implementation over heavy abstraction.
- Prefer flat transport shapes where possible.
- Avoid unnecessary object conversion in C#, Flutter, and PostgreSQL boundaries.
- Keep orchestration centralized and traceable through `Autopilot`.
- Treat integer IDs in transport/runtime contracts as an intentional optimization, not just a naming preference.

Identifier precaution
- Human-readable names may still be useful in docs, constants, and authoring tools.
- Transport/runtime contracts should prefer integer identifiers for action, template, widget, type, source, and field references when possible.
- The move from text keys to integers is primarily for smaller payloads, cheaper comparisons, simpler routing, and lower runtime overhead.

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

AIBook transport split
- For `AIBook`, UX/UI composition data can come from the web as normal JSON.
- For `AIBook`, business-bound row data should prefer the base `X` variants from `lib/core/base/x.dart`.
- This split is intentional: composition wants readable JSON structure, while bound business transport wants the smallest and cheapest machine-oriented shape.
- In architecture language, `base X` means the transport/data shape from `lib/core/base/x.dart`.
- `X*` under `lib/core/widgets` still means wrapped implementation controls such as `XButton`, `XTextBox`, and `XCheckBox`.

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

Planned UX spec transport shape
- The preferred JSON shape is as flat as possible for direct C# and PostgreSQL conversion.
- Template identity, widget identity, widget type, action identity, and binding references are intended to use integer IDs rather than text keys.
- A template/widget identity may still be thought of conceptually like `templateId.widgetId`, but the wire format is intended to stay numeric.

Planned UX binding shape
- `src = 0` means `state`.
- `src = 1` means `dataSource`.
- `src = 2` means `dataSet`.
- `f` or equivalent binding field stores the bound field ID from the selected source.
- The combination of source ID and field ID identifies the binding target.
- For business-bound `AIBook` data, the preferred target is slot/index resolution into `X.v`, not human-readable property-path lookup.
- Human-readable binding paths such as `data.book.title` can remain as migration fallback, but they are not the intended long-term runtime transport for dynamic business data.

Planned UX routing implications
- `AIBook` runtime should resolve numeric UX spec IDs into predefined Flutter templates and widgets.
- `Autopilot` should remain the only orchestrator that resolves source ID plus field ID into actual reads and writes.
- The client should not treat incoming JSON as an arbitrary scripting engine; it should inject values into predefined templates and predefined widget slots.

Registry direction
- Registry-style support JSON may live under `assets/json`.
- Registry data should be separated from screen/body composition when doing so improves clarity and keeps the transport flat.
- The current preferred example is keeping field-binding registration in a dedicated registry JSON such as `aibook_registry.json`, while `aibook_spec.json` stays focused on UI composition.
- Action metadata is also a good candidate for the same registry JSON when the goal is to keep screen/body specs composition-only.
- Host identity can live in the same registry, with typical examples such as `main`, `left`, and `right`.
- Body identity and widget identity can follow the same pattern through `bodyId` and `widgetId`, with string names kept only as migration fallback.
- Runtime output bindings should follow the same `src + fieldId` resolution path as input bindings whenever practical.
- For business-bound `X` transport, field-binding registry entries should prefer slot/index metadata over property names when possible.

Current vocabulary direction
- `Ux*Model` is the definition-side naming for planned UX/UI models.
- `X*` is the implementation-side naming for wrapped Flutter controls under `lib/core/widgets` that know how to work with `Autopilot`.
- Base `X` / `Xi` / `Xia` / `Xiad` / `Xiade` is the transport/data-side naming from `lib/core/base/x.dart`.
- Preview selection/highlighting can use the full identity scope `hostId + bodyId + widgetId`, with no effect when no selected identity is present.
- Example pairing:
  - `UxButtonModel` describes a button definition.
  - `XButton` renders that definition as a real Flutter button.

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
- See `docs/aibook_beta_handover.md` for the current `AIBook` progress snapshot and ordered beta handover plan.
