# What We Did

## README / Project Docs Overview

# Project docs

Index of documentation files in `docs/`:

## User Guides (Help Desk SLM)
Documents designed specifically for the embedded Small Language Model (SLM) Help Desk. These are atomic, Q&A/Intent-based markdown files for end-users.

- `user_guides/common/understanding_input_fields.md` — Guide to the advanced UwField multimode inputs.
- `user_guides/aicodex/navigating_the_explorer.md` — Guide to the Explorer and Admin Home navigation.

## Handover & Progress (start here)

- `aibook_handover.md` — AIBook progressive step-by-step handover with micro-tasks and per-step prompts.
- `aistudio_handover.md` — AIStudio progressive step-by-step handover with micro-tasks and per-step prompts.
- `aicodex_handover.md` — AICodex progressive step-by-step handover with master-detail panels and DDL generation.

Current verification in this snapshot:
- `flutter analyze lib test` passes on `2026-03-21`.
- All four active apps have already been manually tested in this snapshot.
- Checked-in Dart test files have been deleted in this working tree.

Current handover status in this snapshot:
- `AIWork` — ready-to-run spec-driven client surface; no dedicated handover doc yet.
- `AIBook` — ready-to-run spec-driven client surface; the handover doc keeps older pre-`core/ux` steps as historical context.
- `AIStudio` — dedicated hard-coded authoring shell with app-owned seeded section data and shared UX components; older step history remains as context.
- `AICodex` — dedicated hard-coded authoring shell with app-owned seeded section data and shared UX components; older step history remains as context.

Current next focus:
- Continue feature work on the dedicated AIStudio/AICodex shells while reusing shared UX components and keeping their current hard-coded/demo stage explicit in the docs.
- Keep the client-app direction clear: `AIWork` / `AIBook` are local spec-driven today, but the final target is server-spec-driven UI after the real transport/bootstrap path is wired.
- Keep using `flutter analyze lib test` plus manual app runs as the active validation path for this snapshot.
- Add an `AIWork` handover doc when active feature work begins there.

Current UI baseline in this snapshot:
- Shared Material 3 theme via `UxTheme` across the main entry and app modules
- Each app currently owns a dedicated login screen before the loading/ready flow
- All four apps use the same login -> loading -> ready stage flow
- AIStudio and AICodex still share the convergent authoring-shell direction
- Scaffold FABs are gone; actions should live in headers or active panel content

Current ownership reminder:
- `AIWork` is a desktop/tablet-centric client app.
- `AIBook` is a mobile-centric client app.
- `AIWork` and `AIBook` are client CRUD apps only.
- `AIWork` and `AIBook` do not own data designer or UX designer surfaces.
- `AIStudio` owns UX/spec CRUD.
- `AICodex` owns sensitive data-model CRUD plus schema apply/generation work.
- `AIBook` owns runtime business-data consumption through function-style actions.

## Architecture & Contracts

- `project_deep_analysis.md` — full architecture analysis with diagrams, subsystem breakdowns, data flow, gap analysis, and roadmap.
- `project_deep_analysis.md` also records the phase change from the older engine/runtime/renderer/builder/generator overlap into the current single active runtime path.
- `lib_app_readme.md` — app roles, backend transport contract, shared DB builder split, vocabulary, and naming rules.
- `spec_first_schema_experiments.md` — experimental plan for moving schemas to spec documents after September 2026.

## Code Reference

- `lib_core_base_data_type_readme.md` — docs for `lib/core/base/data_type.dart` (DataType + TypeMapper).
- `lib_core_base_x_readme.md` — docs for `lib/core/base/x.dart` (base X transport hierarchy).
- `lib_core_db_sqlite_store_readme.md` — docs for `lib/core/db/sqlite_store.dart` (SQLite store).
- `lib_core_model_bschema_readme.md` — docs for `lib/core/model/bschema` models, with notes about special base models now living under `lib/core/model/base`.

## Guidelines

- Use snake_case filenames derived from the directory path (e.g., `lib_core_model_bschema_readme.md`).
- Keep docs short and point to code locations.
- Update handover docs after completing each step.


---

## spec_first_schema_experiments.md

# Spec-First Schema Experiments

> **Status:** Experimental — do not implement before **September 2026**.  
> **Merged from:** `bschema_uschema_reshape_plan.md` + `toexperiment_after_v2_launched.md`

---

## 1. Goal

Reshape `bschema` and `uschema` so the repo keeps a small hard-coded core, while schema truth moves to serializable spec documents with compiled runtime caches for speed.

**Core rule:**
- source of truth = spec
- source of speed = compiled cache

---

## 2. What Stays Hard-Coded

Keep these concrete — they are engine/runtime infrastructure:

- `lib/core/base/x.dart` (transport hierarchy)
- `lib/core/base/converter.dart` (type conversions)
- `lib/core/base/data_type.dart` (DataType + DataTypeRegister)
- DB/client/admin helpers (`lib/core/db/`)
- Runtime helpers, `Autopilot`, `GenUx`, `UschemaRuntime`

---

## 3. BSchema Reshape

Current `bschema` concrete model files (`*_model.dart`) are no longer the desired final truth.

**Forward direction:**
- Move toward JSON-schema-based documents
- Allow project-specific `x-*` extension fields where needed
- Keep schema transportable, serializable, and easy to edit in AICodex

**Practical rule:**
- `bschema` should describe structure
- Not become a growing set of concrete Dart classes

### Allowed JSON Schema Content

- `type`, `properties`, `required`, `enum`, `default`, `description`, `items`
- `x-db-*` (database-specific metadata: table name, index hints)
- `x-ui-*` (UI-specific metadata: labels, visibility, order)
- `x-action-*` (action-specific metadata: validation, triggers)

### Business Object Physical Convention

For business object persistence, use this compact physical rule:

| Field | Type | Notes |
|---|---|---|
| `i` | `int32` | Row ID |
| `a` | `bool` | Active flag |
| `d` | `int53` app / `int64` DB | Last date/time |
| `e` | `int32` | Last editor |
| `c1..cn` | user-defined | Business columns |

Physical table names: `t1` to `tn`.

This keeps indexing predictable, DB shape compact, and schema evolution driven by spec rather than by many hard-coded column names.

### JSON Schema Example

```json
{
  "title": "customer",
  "type": "object",
  "properties": {
    "i":  { "type": "int32" },
    "a":  { "type": "boolean", "default": true },
    "d":  { "type": "int53" },
    "e":  { "type": "int32" },
    "c1": { "type": "string", "x-label": "name", "minLength": 1 },
    "c2": { "type": "boolean", "x-label": "active", "default": true }
  },
  "required": ["i", "c1"],
  "x-db-table": "t1",
  "x-ui-label": "Customer"
}
```

---

## 4. USchema Reshape

`uschema` should remain spec-first too.

Current forward direction:
- `UxSpec` is the unified serializable UX schema record
- `UxRouteSpec` remains a thin route wrapper around a root `UxSpec`
- stable template config lives in typed metadata such as `UxWorkspaceMeta`
- child structure lives in recursive `uxzones`
- compiled runtime form lives beside raw truth, not instead of it

But keep them as:
- serializable documents, transportable specs, cacheable compile targets

Not as:
- runtime ownership objects or hand-coded widget truth

---

## 5. Proposed File Structure

```text
lib/
└── core/
    ├── base/
    │   ├── x.dart
    │   ├── converter.dart
    │   └── data_type.dart
    ├── gen/
    │   ├── admin_state.dart
    │   ├── explorer_state.dart
    │   ├── adminhome.dart
    │   ├── uexplorer.dart
    │   ├── genux.dart
    │   ├── uschema_compiled.dart
    │   ├── uschema_cache.dart
    │   ├── uschema_codec.dart
    │   └── uschema_runtime.dart
    └── model/
        ├── bschema/
        │   ├── bschema_spec.dart
        │   ├── bschema_compiled.dart
        │   ├── bschema_cache.dart
        │   ├── bschema_index.dart
        │   └── bschema_codec.dart
        └── uschema/
            ├── ux_spec.dart
            ├── ux_route_spec.dart
            ├── ux_specs.dart
            └── ux_field_spec.dart
```

Current code note:
- the old per-layer structural files like `ux_paper_spec.dart` and `ux_template_spec.dart` are no longer the forward target
- unified `UxSpec` plus compiled/cache helpers is the active direction

---

## 6. Runtime Shape (Sample Code)

### Raw Spec

Editable, transportable, persistable.

```dart
typedef JsonMap = Map<String, dynamic>;

class BSchemaSpec {
  const BSchemaSpec({
    required this.id,
    required this.schema,
  });

  final String id;
  final JsonMap schema;
}
```

### Compiled Shape

Normalized once for runtime use.

```dart
class BSchemaCompiled {
  const BSchemaCompiled({
    required this.id,
    required this.title,
    required this.properties,
    required this.requiredKeys,
  });

  final String id;
  final String title;
  final Map<String, JsonMap> properties;
  final Set<String> requiredKeys;
}
```

### Cache Shape

Parse once, reuse many times.

```dart
class BSchemaCache {
  final Map<String, BSchemaCompiled> _byId = <String, BSchemaCompiled>{};

  BSchemaCompiled? get(String id) => _byId[id];

  void put(BSchemaCompiled value) {
    _byId[value.id] = value;
  }

  void clear() {
    _byId.clear();
  }
}
```

### Compile Pattern

```dart
class BSchemaCodec {
  const BSchemaCodec();

  BSchemaCompiled compile(BSchemaSpec spec) {
    final schema = spec.schema;
    final properties =
        (schema['properties'] as Map<String, dynamic>? ?? <String, dynamic>{})
            .map(
              (key, value) => MapEntry(
                key,
                (value as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
              ),
            );

    final requiredKeys =
        ((schema['required'] as List?) ?? const <dynamic>[])
            .map((value) => value.toString())
            .toSet();

    return BSchemaCompiled(
      id: spec.id,
      title: schema['title']?.toString() ?? spec.id,
      properties: properties,
      requiredKeys: requiredKeys,
    );
  }
}
```

---

## 7. Performance Plan

1. Load raw spec once
2. Compile once
3. Cache compiled form
4. Use compiled/indexed form in runtime/editor/preview
5. Recompile only when schema changes

Do not keep concrete schema models just for speed. Use: specs as truth → parser/compiler as adapter → cached runtime form for speed.

### What "Compile" Means Here

In this experiment, **compile** does not mean code generation or machine-code compilation.

It means:

- cast raw values into stronger runtime shapes
- create normalized runtime objects
- resolve ids into typed/runtime meanings
- pre-index recursive child structures
- precompute metadata-derived helpers such as slots

So for `uschema`, compile is best read as:

- raw spec document -> runtime-ready object graph

Examples:

- raw `l` -> resolved `UxLayer`
- raw `m` -> typed metadata like `UxWorkspaceMeta`
- raw child `uxzones` -> compiled recursive tree
- repeated child scanning -> precomputed slot resolution
- persisted document -> cached runtime form

### Current UX Runtime Shape

The active `uschema` runtime now follows this pattern:

- `UxSpec` = raw editable/persisted truth
- `UschemaCodec` = compile step
- `UschemaCompiled` = normalized runtime form
- `UschemaCache` = speed layer with freshness-aware entries
- `UschemaRuntime` = practical compile/cache helper for app/runtime surfaces, including resolved-route refresh
- `GenUx.build(...)` = compiled render path

Current cache validity rule:

- cache lookup is by `spec.i`
- cache reuse is valid only when incoming `spec.d` matches cached `editedAt`
- if `i` matches but `d` changed, runtime recompiles and refreshes cache

Current prototype:

- `AIBook` already renders through the compiled path
- `AIWork` already renders through the compiled path
- both client apps now use shared compile/cache runtime behavior from `core/gen/uschema_runtime.dart`

---

## 8. App Impact

### AICodex
- Current hard-coded shell can stay
- Current shared `AdminHome` / `UExplorer` work can stay
- Explorer content should evolve toward spec documents
- Schema editing should move toward JSON-schema-like rows/documents
- SQL / apply / preview tools should derive from spec, not from many concrete schema classes

### AIStudio
- Keep the dedicated authoring shell
- Continue to reuse the same admin-shell direction where useful
- Keep `uschema` as UX-spec truth
- Avoid introducing a second runtime path

---

## 9. Migration Steps (When Ready)

1. Freeze the minimum `bschema` JSON-schema shape
2. Define allowed `x-*` extensions
3. Stop expanding concrete `bschema/*_model.dart` as the forward truth
4. Add `bschema_spec.dart`
5. Add `bschema_codec.dart`
6. Add `bschema_compiled.dart`
7. Add `bschema_cache.dart`
8. Wire `AICodex` explorer/editor to those specs
9. Keep `uschema` spec-first and serializable
10. Keep `UxSpec` as the unified raw truth for `uschema`
11. Keep `core/gen/uschema_compiled.dart` + `core/gen/uschema_cache.dart` + `core/gen/uschema_codec.dart` as the speed layer
12. Use `core/gen/uschema_runtime.dart` as the practical runtime helper
13. Keep route-resolution refresh logic in the shared runtime helper, not duplicated in each app
14. Keep cache validity tied to `i + d`, not only `i`
15. Expand compiled rendering from the current `AIBook` / `AIWork` client path once the flow is stable

---

## 10. Short Summary

- Keep the core engine concrete
- Keep schema truth as specs
- Compile for speed
- Cache for runtime
- Do not use concrete schema model classes as the final long-term truth
- **Do not start this work before September 2026**

## uwfield_multimode_plan.md

# UwField — Multimode Input Widget Plan

> **Status:** Implemented. See the end-user Help Desk guide at `user_guides/common/understanding_input_fields.md`.

> **Goal:** Create a single configurable `UwField` widget that adapts its input behavior, chrome (left/right icon buttons), and value formatting based on `DataType` and an explicit `fieldMode`.

---

## 1. Concept

Today, GenRP forms use raw `TextField` widgets built inline by `GenUx._buildFormFields`. That works for plain text, but the moment a field needs to behave like a combobox, a date picker, a number stepper, or a boolean toggle, we need a smarter wrapper.

`UwField` is a **single widget** that wraps a `TextField` core and attaches configurable **left button** and **right button** behaviors depending on the field mode. It follows the same `Uwidget` mixin pattern as the other `Uw*` widgets.

```
┌─────────────────────────────────────────────────┐
│ [Left]  │  TextField / display area      │ [Right] │
│  Icon   │  (editable or read-only)       │  Icon   │
└─────────────────────────────────────────────────┘
```

---

## 2. Field Modes

| Mode | Left Button | Right Button | TextField | Value Type |
|---|---|---|---|---|
| `text` | — (none) | Clear (`×`) | Editable | `String` |
| `number` | — (none) | Clear (`×`) | Editable, numeric keyboard | `int` / `double` |
| `combo` | Refresh (↻) | Open suggestions (▼) | Editable with autocomplete | `String` / `int` |
| `select` | Refresh (↻) | Open suggestions (▼) | Read-only display | `String` / `int` |
| `date` | — (none) | Open date picker (📅) | Read-only display | `int` (epoch ms) |
| `datetime` | — (none) | Open date+time picker (📅) | Read-only display | `int` (epoch ms) |
| `bool` | — (none) | Toggle (☑/☐) | Read-only display ("Yes"/"No") | `bool` |
| `json` | — (none) | Expand editor (↗) | Editable, multiline hint | `String` (JSON) |
| `link` | Link/Unlink (🔗/⛓️‍💥) | Refresh/Push (↻/↑) | Editable when unlinked, read-only when linked | `dynamic` (from state) |
| `tag` | Toggle View↔Add (👁/＋) | View: Toggle normal↔delete (🗑) / Add: Add item (＋) | View: chips or delimited display / Add: editable input with suggestions | `List<dynamic>` |
| `filter` | Cycle operator: C → S → E → X | Apply (✓) or Clear (×) | Editable search text | `{op, value}` |

---

## 3. Widget API Design

Instead of passing dozens of mode-specific parameters directly into the `UwField` constructor, the design uses a single **`UwFieldSpec`** config object. The widget constructor stays lean — only the universal fields live on the widget itself. Everything mode-specific goes into the spec.

```dart
/// ── Config object: bundles mode, labels, value, callbacks, and
///    mode-specific settings into one immutable snapshot.
class UwFieldSpec {
  const UwFieldSpec({
    this.mode = UwFieldMode.text,
    this.dataTypeId,

    // Labels
    this.label,
    this.hint,
    this.width,

    // Value
    this.value,                 // current value (String, int, double, bool, List, Map)
    this.readOnly = false,

    // Suggestion items (combo / select / tag)
    this.items,                 // List<dynamic> of suggestion items
    this.itemLabelBuilder,      // dynamic → String

    // Tag specifics
    this.tags,                  // current tag list
    this.tagDelimiter,          // delimiter for non-chip display (default ', ')
    this.showChips = true,
    this.allowDuplicates = false,

    // Link specifics
    this.stateKey,
    this.stateSrc = 0,          // 0 = chrome, 1 = dataSet, 2 = scoped
    this.stateScope,

    // Filter specifics
    this.filterOp = FilterOp.contains,

    // Left / Right icon overrides
    this.leftIcon,
    this.leftTooltip,
    this.rightIcon,
    this.rightTooltip,
  });
}

/// ── Callback bundle: all events the caller can react to.
class UwFieldCallbacks {
  const UwFieldCallbacks({
    this.onChanged,             // value committed (typed per mode)
    this.onRefresh,             // left-button refresh (combo/select/tag)
    this.onTagAdded,            // tag added
    this.onTagRemoved,          // tag removed (index)
    this.onLink,                // link toggled (bool isLinked)
    this.onPush,                // value pushed to state (link mode)
    this.onFilterApplied,       // filter applied ({op, value})
    this.onFilterCleared,       // filter cleared
    this.onLeftPressed,         // left-button override action
    this.onRightPressed,        // right-button override action
  });
}

/// ── The widget itself: stays lean.
class UwField extends StatefulWidget with Uwidget {
  const UwField({
    required this.i,
    required this.autopilot,
    required this.spec,
    this.callbacks = const UwFieldCallbacks(),
    this.s = 0,
    super.key,
  });

  @override final int vid = 14;
  @override final int s;
  @override final int i;
  @override final String n = 'field';

  final Autopilot autopilot;
  final UwFieldSpec spec;
  final UwFieldCallbacks callbacks;
}

enum UwFieldMode { text, number, combo, select, date, datetime, bool_, json, link, tag, filter }

/// Filter match operators for `filter` mode.
enum FilterOp { contains, startsWith, endsWith, except }
```

### Key design points

- **`vid = 14`** — next available ID after `tab` (13) in `UxRegister.views`.
- **Spec + Callbacks split** — `UwFieldSpec` is pure config/data (immutable, safe to copy/serialize later). `UwFieldCallbacks` is pure event callbacks. This keeps the widget constructor to **4 required/optional params** regardless of how many modes exist.
- **`spec.mode`** is the primary driver. If `spec.dataTypeId` is provided but `mode` is not explicitly set, the widget auto-selects a reasonable default (e.g., `Int32` → `number`, `bool` → `bool_`).
- **Left/right icon overrides** in `spec` let any caller replace the default mode-based buttons.
- **`spec.items`** is `List<dynamic>` — `itemLabelBuilder` converts each to a display string.
- **`callbacks.onChanged`** returns the committed value in the correct Dart type for the mode.
- **Adding a new mode** only grows `UwFieldSpec` and `UwFieldCallbacks` — the `UwField` constructor never changes.

### Sub-widget file split

Several modes share the same behavioral patterns. Instead of putting all 11 mode implementations in one giant file, the build logic is split into focused sub-widget files that `UwField` delegates to:

| Sub-widget file | Shared pattern | Used by modes |
|---|---|---|
| `uwfield.dart` | Main widget, layout scaffold (`[left][body][right]`), mode dispatch, `UwFieldSpec`, `UwFieldCallbacks`, enums | all |
| `uwfield_overlay.dart` | Suggestion overlay (`OverlayEntry` + `CompositedTransformFollower`), item filtering, item selection | `combo`, `select`, `tag` (add sub-mode) |
| `uwfield_picker.dart` | Date/time picker integration (`showDatePicker`, `showTimePicker`), epoch ↔ display formatting | `date`, `datetime` |
| `uwfield_toggle.dart` | Two-state toggle rendering (icon swap, tint swap, value flip) | `bool_`, `link` (linked/unlinked toggle) |
| `uwfield_chips.dart` | Chip list rendering (`Wrap` + `Chip`/`InputChip`), delete state, delimiter fallback | `tag` (view sub-mode) |
| `uwfield_filter.dart` | Operator badge cycling, apply/clear state, color-coded badge | `filter` |

Each sub-widget file exports a focused `StatelessWidget` or helper build method. `UwField._buildBody()` dispatches to the right sub-widget based on `spec.mode`. A mode that only needs the base text field (e.g., `text`, `number`, `json`) stays inline in `uwfield.dart` — no separate file needed.

This split means:
1. **No file gets too large** — each sub-widget stays under ~150 LOC.
2. **Shared behavior is written once** — `uwfield_overlay.dart` serves combo, select, and tag without duplication.
3. **New modes are easy to add** — create a new `uwfield_*.dart` sub-widget, add a case to the dispatcher.
4. **All sub-widgets receive `UwFieldSpec` + `UwFieldCallbacks`** — the same two objects flow through, no parameter explosion at the delegation boundary.

---

## 4. Mode Behavior Details

### 4.1 `combo` mode

1. TextField is **editable** — the user can type freely.
2. As the user types, a filtered **overlay** of matching `items` appears below the field (like `Autocomplete`).
3. **Right button (▼)** opens/closes the full suggestion overlay (unfiltered).
4. **Left button (↻)** calls `onRefresh` — intended for reloading items from a data source.
5. Selecting an item from the overlay sets the TextField text and fires `onChanged` with the item value.

### 4.2 `select` mode

1. TextField is **read-only** — shows the currently selected item's label.
2. **Right button (▼)** opens the suggestion overlay (always unfiltered, since user cannot type).
3. **Left button (↻)** calls `onRefresh`.
4. Tapping the text area also opens the overlay (convenience).

### 4.3 `date` / `datetime` mode

1. TextField is **read-only** — displays the formatted date/datetime string.
2. **Right button (📅)** opens the Flutter `showDatePicker` (and `showTimePicker` for `datetime`).
3. Value is stored as `int` (epoch milliseconds) — consistent with the `d` field in all models.
4. Display format is configurable via an optional `dateFormat` string parameter.

### 4.4 `bool_` mode

1. TextField is **read-only** — displays `"Yes"` / `"No"` (or custom labels).
2. **Right button** is a toggle icon (checkbox outline).
3. Tapping the text area also toggles.

### 4.5 `number` mode

1. TextField is **editable** with `TextInputType.number` and input formatting.
2. Validation respects `DataType` range (e.g., `Int32` bounds vs `Int53` bounds).
3. Clear button on the right.

### 4.6 `link` mode

Link mode turns `UwField` into a **state-bound input** — the field can be linked to a key in `Autopilot`'s state layer (`StateSet` chrome, `DataSet`, or a scoped paper/template store), and the link can be toggled on and off.

**State sources** (driven by `stateSrc`):
- `0` — `stateSet` chrome layer (`autopilot.stateSet.chrome(stateKey)`)
- `1` — `dataSet` (`autopilot.data(stateKey)`)
- `2` — scoped paper/template state (`autopilot.paperState(stateScope, stateKey)` or `autopilot.templateState(stateScope, stateKey)`)

**When linked (🔗):**
1. TextField is **read-only** — displays the current value read from `Autopilot` at `stateKey`.
2. The field listens to `Autopilot` changes and refreshes its display automatically.
3. **Left button (🔗)** shows the linked icon. Pressing it **unlinks** — detaches from state, copies the current value into a local editable buffer, and calls `onLink(false)`.
4. **Right button (↻)** re-reads the value from `Autopilot` state (manual refresh), useful if the listener missed an update or the caller wants an explicit pull.

**When unlinked (⛓️‍💥):**
1. TextField is **editable** — the user can type freely to set a local value.
2. The field does **not** listen to `Autopilot` changes.
3. **Left button (⛓️‍💥)** shows the unlinked icon. Pressing it **relinks** — writes the current local value back to `Autopilot` state at `stateKey`, switches to read-only, resumes listening, and calls `onLink(true)`.
4. **Right button (↑)** pushes the current local value to `Autopilot` state at `stateKey` **without relinking** — a one-shot write. Calls `onPush(currentValue)` and fires `onChanged`.

**Visual indicator:** When linked, the field decoration shows a subtle tint or border accent (e.g., `UxTheme.colors(context).secondary` at low alpha) to make the bound state obvious at a glance.

**Use cases:**
- Binding a form field to a `DataSet` key so it reflects live transport data.
- Binding an editor field to paper/template scoped state for cross-widget sync.
- Temporarily unlinking to override a value locally, then relinking to push it back.
- Inspecting/debugging what value a state key holds without opening dev tools.

### 4.7 `tag` mode (experimental)

Tag mode turns `UwField` into a **list/array value editor** with two sub-modes: **view** and **add**.

```
View mode (normal):
┌──────────────────────────────────────────────────────┐
│ [👁]  │  [Tag1] [Tag2] [Tag3]                  │ [🗑]  │
│       │  (chips or "Tag1, Tag2, Tag3")        │      │
└──────────────────────────────────────────────────────┘

View mode (delete):
┌──────────────────────────────────────────────────────┐
│ [👁]  │  [Tag1 ×] [Tag2 ×] [Tag3 ×]          │ [✓]  │
│       │  (each chip shows delete button)      │      │
└──────────────────────────────────────────────────────┘

Add mode:
┌──────────────────────────────────────────────────────┐
│ [＋]  │  type new item...                     │ [＋]  │
│       │  ┌─────────────────────────┐          │      │
│       │  │ suggestion 1            │          │      │
│       │  │ suggestion 2            │          │      │
│       │  │ suggestion 3            │          │      │
│       │  └─────────────────────────┘          │      │
└──────────────────────────────────────────────────────┘
```

**View sub-mode (👁) — normal state:**
1. The text area displays current tags as **chips** (without delete buttons) or as **delimiter-separated text** (e.g., `"Tag1, Tag2, Tag3"`) — controlled by `showChips` flag.
2. **Left button (👁)** shows the view icon. Pressing it switches to **add** sub-mode.
3. **Right button (🗑)** switches to **delete state** — chips gain `×` delete buttons.
4. TextField is **not directly editable** — the display is driven by the `tags` list.

**View sub-mode (👁) — delete state:**
1. Chips now show **`×` delete buttons**. Tapping `×` removes that item from the list and fires `onTagRemoved(index)` and `onChanged(updatedList)`.
2. **Left button (👁)** still shows the view icon. Pressing it switches to **add** sub-mode (and exits delete state).
3. **Right button (✓)** confirms and switches back to **normal state** — `×` buttons disappear.
4. This two-step pattern prevents accidental deletions — the user must first enter delete state, then tap individual chips.

**Add sub-mode (＋):**
1. The current tags move into the **suggestion overlay** below the field (alongside any `items` suggestions), so the user can see what already exists.
2. The text area **clears** and becomes **editable** — ready for the user to type a new item.
3. As the user types, the suggestion overlay filters to show matching existing tags and available `items`.
4. **Right button (＋)** adds the current text as a new tag: appends to the list, fires `onTagAdded(value)` and `onChanged(updatedList)`, clears the text, and stays in add mode ready for the next item.
5. Selecting a suggestion from the overlay also adds it as a tag (same as pressing ＋).
6. **Left button (＋)** pressing it again switches back to **view** sub-mode.
7. Pressing Enter/submit on the keyboard is equivalent to pressing the right ＋ button.

**Duplicate handling:** By default, duplicates are rejected (the item is not added if it already exists in `tags`). Set `allowDuplicates: true` to permit them.

**Value flow:**
- The widget value is `List<dynamic>` — the full current tag list.
- `onChanged` fires with the updated list after every add or remove.
- `onTagAdded(dynamic)` fires with the individual added value.
- `onTagRemoved(int)` fires with the index of the removed value.

**Use cases:**
- Editing `tis` (table ID arrays) on `FunctionModel` / `EntityModel` — each table ID is a tag.
- Editing category/label lists on any model row.
- Managing permission or role lists.
- Any field that maps to a `List` or JSON array column.

### 4.8 `filter` mode (experimental)

Filter mode turns `UwField` into a **search/filter input** where the user types a search term and the left button cycles through match operators.

```
┌──────────────────────────────────────────────────────┐
│ [C]   │  search text...                      │ [✓]  │
└──────────────────────────────────────────────────────┘
  ↑ cycles: C → S → E → X → C ...
```

**Operators** (left button cycles in order):

| Badge | `FilterOp` value | Meaning | Tooltip |
|---|---|---|---|
| **C** | `contains` | Value contains the search text | "Contains" |
| **S** | `startsWith` | Value starts with the search text | "Starts with" |
| **E** | `endsWith` | Value ends with the search text | "Ends with" |
| **X** | `except` | Value does NOT contain the search text | "Except" |

**Behavior:**
1. TextField is **editable** — the user types the search/filter term.
2. **Left button** displays the current operator badge (**C** / **S** / **E** / **X**) as a compact label or icon. Each press advances to the next operator in the cycle: `contains → startsWith → endsWith → except → contains → ...`
3. **Right button** has two states:
   - When the filter is **not yet applied** (or text has changed since last apply): shows **✓** (apply). Pressing it fires `onFilterApplied({op: currentOp, value: currentText})` and `onChanged({op, value})`.
   - When the filter **is applied** and text hasn't changed: shows **×** (clear). Pressing it clears the text, resets to default operator, and fires `onFilterCleared`.
4. Changing the operator badge (left button) while a filter is active automatically re-applies with the new operator.
5. The left button badge uses a distinct background tint per operator (e.g., blue for C, green for S, orange for E, red for X) for at-a-glance identification.

**Value type:** `{op: FilterOp, value: String}` — a map containing the current operator and search text. `onChanged` fires with this map.

**Use cases:**
- Table column header filters in `_AdminModelTable`.
- Explorer node search/filtering.
- Any list or collection that needs inline text-based filtering.

---

## 5. Implementation Steps

### Step 1 — Scaffold `UwField` + `UwFieldMode` enum

**Files:** `lib/core/ux/uwidget/uwfield.dart`

- Create the `UwField` `StatefulWidget` with `Uwidget` mixin.
- Implement the outer `Row` layout: `[leftSlot] [Expanded TextField] [rightSlot]`.
- Register `vid = 14` as `'field'` in `UxRegister.views`.
- Export from `ux.dart`.
- Start with `text` mode only — plain editable `TextField` with optional clear button.

**Done when:** `flutter analyze` passes, `UwField(i: 0, autopilot: pilot)` renders a working text input.

### Step 2 — `number` mode

- Add `TextInputType.numberWithOptions` keyboard.
- Add input formatter to restrict non-numeric characters.
- Wire `onChanged` to parse and emit typed value (`int` or `double`).
- If `dataTypeId` is provided and maps to `Int32`/`Int53`/`Int64`/`Double`, auto-select `number` mode.

**Done when:** Number mode accepts only valid numeric input and fires `onChanged` with the correct Dart type.

### Step 3 — `bool_` mode

- Switch TextField to read-only display (`"Yes"` / `"No"`).
- Right button renders a toggle checkbox icon.
- Tapping either text or button toggles the value.

**Done when:** Bool mode displays and toggles correctly, fires `onChanged(bool)`.

### Step 4 — `date` / `datetime` modes

- Right button opens `showDatePicker` (and `showTimePicker` for `datetime`).
- Value stored as `int` epoch milliseconds.
- Display formatted via `DateFormat` or a simple `yyyy-MM-dd HH:mm` fallback.
- Clear button appears when value is set.

**Done when:** Picking a date sets the field display and fires `onChanged(int)` with epoch ms.

### Step 5 — `combo` mode (autocomplete)

- TextField stays editable.
- Add a `_SuggestionOverlay` using `OverlayEntry` or `CompositedTransformFollower` anchored below the field.
- Filter items as the user types.
- Right button (▼) toggles the full unfiltered overlay.
- Left button (↻) calls `onRefresh`.
- Selecting an item fills the text and fires `onChanged`.

**Done when:** Combo field shows filtered suggestions on typing, full list on ▼ press, and refresh works.

### Step 6 — `select` mode

- Same overlay as `combo`, but TextField is read-only.
- Tapping the text area or the ▼ button opens the overlay.
- Left button (↻) calls `onRefresh`.

**Done when:** Select mode opens the full suggestion list on tap or ▼, and refresh reloads items.

### Step 7 — `json` mode

- TextField is multiline with a monospace hint.
- Right button (↗) could expand to a dialog or full-screen editor (future).
- Value is plain `String` with optional JSON validation indicator.

**Done when:** JSON mode renders a multiline text field and fires `onChanged(String)`.

### Step 8 — `link` mode

- Add `stateKey`, `stateSrc`, `stateScope`, `onLink`, `onPush` parameters.
- Implement linked state: read value from `Autopilot` based on `stateSrc` and `stateKey`, display read-only, listen to `Autopilot` via `addListener`.
- Implement unlinked state: copy value to local `TextEditingController`, switch to editable.
- Left button toggles linked/unlinked icon and calls `onLink(bool)`.
- Right button: when linked → re-read from state (refresh); when unlinked → push local value to state via `autopilot.setData()` / `autopilot.setPaperState()` / `autopilot.stateSet.setChrome()`.
- Add visual linked-state indicator (secondary color border tint).

**Done when:** `UwField(fieldMode: UwFieldMode.link, stateKey: 'customer.name', stateSrc: 1)` reads from `DataSet`, toggles link/unlink, and pushes values back.

### Step 9 — `tag` mode (experimental)

- Add `tags`, `onTagAdded`, `onTagRemoved`, `tagDelimiter`, `showChips`, `allowDuplicates` parameters.
- Implement view sub-mode: render `tags` as `Chip` widgets (with delete) inside a `Wrap` that replaces the TextField, or as delimiter-separated read-only text.
- Implement add sub-mode: clear TextField, make editable, show suggestion overlay containing existing tags + `items`.
- Left button toggles view ↔ add sub-mode icon.
- Right button: in view → `onRefresh`; in add → append typed text to tags list, clear text, stay in add mode.
- Fire `onChanged(List)` after every add/remove.
- Reject duplicates by default unless `allowDuplicates` is true.

**Done when:** `UwField(fieldMode: UwFieldMode.tag, tags: ['a','b'])` shows chips in view mode, switches to add mode on left press, adds items on right press, and removes chips on ×.

### Step 10 — `filter` mode (experimental)

- Add `filterOp`, `onFilterApplied`, `onFilterCleared` parameters.
- Left button displays operator badge (C/S/E/X) with tinted background. Each press cycles to the next operator.
- TextField is editable for search text.
- Right button: apply (✓) when text is unapplied, clear (×) when filter is active.
- Fire `onChanged({op, value})` on apply.
- Re-apply automatically when operator changes while a filter is active.

**Done when:** `UwField(fieldMode: UwFieldMode.filter)` shows operator badge on left, cycles C→S→E→X on press, applies filter on right press, and clears on second right press.

### Step 11 — Auto-mode from `DataType`

- Add a static helper `UwFieldMode modeForDataType(int dataTypeId)` that maps:
  - `0` (bool) → `bool_`
  - `1–4` (Int32, Int53, Int64, Double) → `number`
  - `5` (Binary) → `text`
  - `6–7` (Json, Jsonb) → `json`
  - `9` (Guid), `10` (String), `11` (Base64) → `text`
  - `>99` (Numeric) → `number`
- `link`, `tag`, and `filter` modes are never auto-selected — they must be explicitly set because they require additional parameters or serve specialized purposes.
- When `fieldMode` is not explicitly set but `dataTypeId` is provided, auto-select mode.

**Done when:** `UwField(dataTypeId: 0)` auto-renders as bool toggle, `UwField(dataTypeId: 1)` auto-renders as number input.

### Step 12 — Wire into `GenUx._buildFormFields`

- Update `_buildFormFields` to produce `UwField` instances instead of raw `TextField`.
- `UxFieldSpec` already has `label`, `hint`, `width` — add optional `dataTypeId` and `fieldMode` if needed.
- Existing spec-driven apps (`AIWork`, `AIBook`) should render the upgraded fields without spec changes (text mode is the default).

**Done when:** `AIWork` / `AIBook` render `UwField` in their forms, and new modes can be activated by setting `dataTypeId` or `fieldMode` in the spec.

### Step 13 — Wire into `AdminHome` editor panels

- When `AdminHome` enters an edit/detail view for a selected row, use `UwField` with appropriate modes for each column type.
- e.g., `i` → `number`, `a` → `bool_`, `d` → `datetime`, `n`/`s` → `text`, `t` → `combo` (with type list items).
- For fields that should bind to `Autopilot` state (e.g., a live-synced editor field), use `link` mode with appropriate `stateKey` and `stateSrc`.
- For array fields like `tis` on `FunctionModel`/`EntityModel`, use `tag` mode.
- For table column header filters and explorer search, use `filter` mode.

**Done when:** `AICodex` detail panel shows correctly typed `UwField` widgets for each column of the selected model row, including tag chips for `tis`.

---

## 6. File Checklist

| File | Action |
|---|---|
| `lib/core/ux/uwidget/uwfield.dart` | **New** — main widget, `UwFieldSpec`, `UwFieldCallbacks`, enums, mode dispatch |
| `lib/core/ux/uwidget/uwfield_overlay.dart` | **New** — shared suggestion overlay (combo, select, tag add sub-mode) |
| `lib/core/ux/uwidget/uwfield_picker.dart` | **New** — date/time picker integration (date, datetime) |
| `lib/core/ux/uwidget/uwfield_toggle.dart` | **New** — two-state toggle rendering (bool, link) |
| `lib/core/ux/uwidget/uwfield_chips.dart` | **New** — chip list + delete state rendering (tag view sub-mode) |
| `lib/core/ux/uwidget/uwfield_filter.dart` | **New** — operator badge cycling + apply/clear (filter) |
| `lib/core/ux/ux.dart` | **Edit** — add `export 'uwidget/uwfield.dart';` |
| `lib/core/ux/mixins.dart` | **Edit** — add `14: 'field'` to `UxRegister.views` |
| `lib/core/gen/genux.dart` | **Edit** — update `_buildFormFields` to use `UwField` |
| `lib/core/model/uschema/ux_field_spec.dart` | **Edit** — add optional `dataTypeId` and `fieldMode` |
| `docs/project_deep_analysis.md` | **Edit** — update uwidget count (13 → 14+), update file reference |
| `README.md` | No change needed |

---

## 7. Design Constraints

1. **No new dependencies** — use Flutter built-in pickers and overlay API only.
2. **Follow existing pattern** — `Uwidget` mixin, `i/s/n/vid`, `Autopilot` reference, `UxTheme` styling.
3. **Spec + Callbacks pattern** — all mode config flows through `UwFieldSpec`; all events flow through `UwFieldCallbacks`. Sub-widgets receive the same two objects.
4. **Overlay for suggestions** — use `OverlayEntry` + `CompositedTransformTarget/Follower` so the dropdown floats above other content and respects scroll position.
5. **Icon button sizing** — match `AdminHome` compact chrome: `iconSize: 16`, `padding: EdgeInsets.zero`, `SizedBox(width: 32)`.
6. **Left/right slots are nullable** — if a mode doesn't use a slot, it collapses to zero width (no empty box).
7. **Value type safety** — `callbacks.onChanged` receives the correctly typed value for the mode, not always `String`.
8. **Sub-widget files** — extract shared behavior into `uwfield_*.dart` files. Simple modes (`text`, `number`, `json`) stay inline in `uwfield.dart`.
9. **Analyzer must stay green** after every step.


---

## Completed Handover Steps


### Completed from aibook_handover.md
## What is already done

- [x] App shell with single `Scaffold`, body swap, loading/error states
- [x] `AutopilotGo` with spec configuration and field bindings
- [x] `Autopilot` with dual binding (slot-first `X.v[index]` + path fallback)
- [x] `MockTransport` loads merged spec/registry from `assets/json`
- [x] `DynamicSpecBody` routes to `FormTemplate`, `CheckboxFormTemplate`, `CollectionTemplate`, `DetailTemplate`
- [x] `TemplateRuntime` renders `column`, `spacer`, `textField`, `button`, `text` nodes
- [x] `XButton`, `XTextBox`, `XCheckBox` with binding + debug selection highlight
- [x] `UxRegistry` maps numeric IDs → names for host/body/template/type/widget
- [x] `UxSpecMapper` converts JSON nodes → typed UX models
- [x] Spec validation for duplicate IDs and broken field/template/type references
- [x] Numeric-first body routing with string fallback
- [x] `SqliteStore` shared foundation (not wired to AIBook yet)
- [x] Shared DB scaffolding exists: `db_contract`, PG/SQLite admin+client builders, and `WebClient` envelope builder
- [x] Tests: slot binding, validation, mock transport, body routing, widget behavior

---

## [x] Step 1 — Numeric-only body routing

**Status:** Done in the current repo snapshot.

**Goal:** Remove string-driven body lookup from the runtime hot path. Numeric `bodyId` becomes the primary lookup; string name is fallback only.

**Files to change:**
- `lib/core/generator/boilerplate_generator.dart`
- `lib/core/model/uschema/ux_registry.dart` (if needed)

**What to do:**
1. In `DynamicSpecBody.build()`, resolve `currentBody` to an `int` first.
2. Search `bodies` map values by matching `bodyId` as the primary path.
3. Only fall back to string key lookup if no `bodyId` match is found.
4. Resolve `templateId` → template name via `UxRegistry` as primary; `template` string as fallback.
5. Add a test in `test/boilerplate_generator_test.dart` confirming numeric-only routing works.

**Done when:**
- Body routing works when `initialBody` and `currentBody` are integers.
- String body name still works as fallback.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIBook Step 1: Numeric-only body routing.

Current state:
- `DynamicSpecBody` in `lib/core/generator/boilerplate_generator.dart` already tries numeric bodyId lookup first, but the logic is mixed with string fallback in several places.
- `UxRegistry` already has `bodyName(int id)` and `templateName(int id)`.

Task:
- Clean up `DynamicSpecBody.build()` so numeric bodyId is the clear primary path.
- String name lookup should be explicit fallback only.
- Keep template resolution numeric-first via `templateId` → `UxRegistry.templateName()`.
- Add or update test in `test/boilerplate_generator_test.dart`.

Constraints:
- Do not change spec/registry JSON structure.
- Do not change Autopilot or action plumbing.
- Keep analyzer and tests green.
```

---

## [x] Step 2 — Validate binding references

**Status:** Done in the current repo snapshot.

**Goal:** Expand spec validation beyond duplicate IDs. Catch broken references before runtime render.

**Files to change:**
- `lib/app/aibook/autopilotgo.dart` (`_validateSpec`)

**What to do:**
1. Validate that every `fieldBinding` has both `src` and `fieldId`.
3. Validate that `templateId` in body specs matches a template in the `templates` list.
4. Validate that `typeId` in body node children matches a type in the `types` list.
5. Return the first validation error found (keep it simple).
6. Add tests in `test/validation_test.dart` for missing action ref, bad template ref, bad type ref.

**Done when:**
- `AutopilotGo` returns a clear `specError` for bad references.
- All new validation cases have tests.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIBook Step 2: Validate binding references.

Current state:
- Step 1 is done — numeric-first body routing is already in place in `DynamicSpecBody`.
- `_validateSpec` in `lib/app/aibook/autopilotgo.dart` currently checks duplicate IDs plus `fieldBindings`, `actionId`, `templateId`, and `typeId` references.
- The spec uses `actionId`, `templateId`, `typeId` in body definitions and child nodes.
- The registry has `actions`, `templates`, `types` lists.

Task:
- Expand `_validateSpec` to check cross-references:
  - `fieldBindings` must have `src` + `fieldId`.
  - `templateId` in body must match a `templates` entry.
  - `typeId` in body children must match a `types` entry.
- Return first error string found.
- Add test cases in `test/validation_test.dart`.

Constraints:
- Keep validation simple — first-error-wins, no error list.
- Do not change body routing or binding resolution.
- Keep analyzer and tests green.
```

---



### Completed from aistudio_handover.md
## What is already done

- [x] Shared `MaterialApp` flow with login -> loading -> ready stages
- [x] Direct-path support through `CopilotRoute`
- [x] App-owned hard-coded surface metadata inside `aistudio.dart` drives the live shell
- [x] `AppBar` surface switching replaces the older `NavigationRail` route switcher
- [x] The ready state is a dedicated hard-coded three-panel shell that still reuses shared UX widgets
- [x] Shared `UxTheme` owns theme data plus panel/chrome helpers
- [x] Current seeded AIStudio surface metadata lives in `aistudio.dart` and remains intentional for this snapshot
- [x] Shared DB scaffolding exists: `db_contract`, PG/SQLite admin+client builders, and system entrypoint seeds
- [x] `flutter analyze lib test` passes in the current snapshot
- [x] The older step history is preserved below as archival context for the pre-`core/ux` implementation path

## [x] UI convergence prerequisite — Hybrid shell

**Status:** Done in the current repo snapshot.

**Goal:** Replace the earlier fixed three-panel shell with the shared hybrid minor/major shell before continuing feature steps.

**What to do:**
1. Convert the current body layout into:
   - left minor panel
   - right major panel
2. Add **two tabs** to the minor panel.
3. Add **three tabs** to the major panel.
4. Implement the three major layout modes:
   - tab 1: single mid only
   - tab 2: larger mid + smaller right
   - tab 3: equal mid + right
5. Preserve current AIStudio selection behavior inside the new shell.
6. Keep the left explorer/list mechanism app-owned rather than moving it into the shell contract.

**Done when:**
- AIStudio uses the shared hybrid shell.
- The old fixed three-panel layout is gone.
- Current selection/header behavior still works inside the new shell.
- The shared shell remains a layout/tab mechanism only.

---

## [x] Step 1 — Add local selection state

**Status:** Done in the current repo snapshot.

**Goal:** Track what the user has selected so the middle and right panels can respond.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`

**What to do:**
1. Convert `AIStudioApp` to use a `StatefulWidget` for the home scaffold.
2. Add state fields:
   - `String? _selectedCatalog` (e.g., `'Host'`)
   - `int? _selectedRowId`
3. When a left-panel `ListTile` is tapped, set `_selectedCatalog` to that item's name.
4. Show the selected catalog name as a header in the middle panel (replace placeholder text).
5. Keep right panel as placeholder for now.

**Done when:**
- Tapping a left-panel item updates the middle panel header.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIStudio Step 1: Add local selection state.

Current state:
- `lib/app/aistudio/aistudio.dart` has a three-panel static layout.
- Left panel is intended to hold the UX/spec collection list.
- Middle and right panels are placeholder text.

Task:
- Make the home a StatefulWidget.
- Add state: _selectedCatalog, _selectedRowId.
- Wire ListTile taps to set _selectedCatalog.
- Show selected catalog name in middle panel header.
- Keep right panel placeholder.

Constraints:
- Do not touch AIBook or AICodex code.
- Do not add route navigation.
- Keep one Scaffold.
- Keep analyzer green.
```

---

## [x] Step 2 — Complete left-panel UX/spec catalog list

**Status:** Done in the current repo snapshot.

**Goal:** Finish the UX/spec explorer list and make the current selection visually obvious.

**Files to change:**
- `lib/app/aistudio/aistudio.dart`

**What to do:**
1. Add missing UX/spec entries:
   - `FieldBinding`
   - `Body Spec Node`
2. Add a visual indicator (e.g., background color or leading icon) for the currently selected catalog.
3. Keep AIStudio focused on UX/spec collection/explorer behavior; sensitive data-model catalogs belong to AICodex.

**Done when:**
- Left panel shows: Host, Body, Template, Type, Widget, FieldBinding, Body Spec Node.
- Selected catalog is visually highlighted.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIStudio Step 2: Complete left-panel UX/spec catalog list.

Current state:
- Step 1 is done — local selection state exists.
- AIStudio should focus on UX/spec.
- Current list has: Host, Body, Template, Type, Widget.

Task:
- Add UX/Spec entries: FieldBinding, Body Spec Node.
- Highlight the selected catalog visually (e.g., selected ListTile color).

Constraints:
- Do not move sensitive data-model browsing back into AIStudio.
- Keep analyzer green.
```

---



### Completed from aicodex_handover.md
## What is already done

- [x] Shared `MaterialApp` flow with login -> loading -> ready stages
- [x] Direct-path support through `CopilotRoute`
- [x] App-owned hard-coded surface metadata inside `aicodex.dart` drives the live shell
- [x] `AppBar` surface switching replaces the older `NavigationRail` route switcher
- [x] The ready state is a dedicated hard-coded three-panel shell that still reuses shared UX widgets
- [x] Shared `UxTheme` owns theme data plus panel/chrome helpers
- [x] Current seeded AICodex surface metadata lives in `aicodex.dart` and remains intentional for this snapshot
- [x] Shared DB scaffolding exists: `db_contract`, PG/SQLite admin+client builders, and system entrypoint seeds
- [x] Backend contract remains documented (single POST endpoint, JSON passthrough, PG router function)
- [x] `flutter analyze lib test` passes in the current snapshot
- [x] The older step history is preserved below as archival context for the pre-`core/ux` implementation path

## [x] UI convergence prerequisite — Hybrid shell

**Status:** Done in the current repo snapshot.

**Goal:** Replace the earlier fixed three-panel shell with the shared hybrid minor/major shell before continuing feature steps.

**What to do:**
1. Convert the current body layout into:
   - left minor panel
   - right major panel
2. Add **two tabs** to the minor panel.
3. Add **three tabs** to the major panel.
4. Implement the three major layout modes:
   - tab 1: single mid only
   - tab 2: larger mid + smaller right
   - tab 3: equal mid + right
5. Preserve current AICodex navigation/master-list behavior inside the new shell.
6. Keep the left explorer/navigation mechanism app-owned rather than moving it into the shell contract.

**Done when:**
- AICodex uses the shared hybrid shell.
- The old fixed three-panel layout is gone.
- Current navigation/master-list behavior still works inside the new shell.
- The shared shell remains a layout/tab mechanism only.

---

## [x] Step 1 — Navigation panel with model type list

**Status:** Done in the current repo snapshot.

**Goal:** Replace the left placeholder with a real model type list that tracks selection.

**Files to change:**
- `lib/app/aicodex/aicodex.dart`

**What to do:**
1. Convert `AICodexApp` home to a `StatefulWidget`.
2. Add state fields:
   - `String? _selectedModelType` (e.g., `'Entity'`, `'Table'`, `'Function'`)
   - `int? _selectedRowId`
3. Build the left panel as a `ListView` with these model types grouped into two sections:

   **Schema Source** (app-facing definitions):
   - `Entity`
   - `Field`
   - `Function`
   - `Parameter`

   **Schema Target** (physical structure):
   - `Table`
   - `Column`
   - `System`
   - `User`

4. Tapping a model type sets `_selectedModelType` and clears `_selectedRowId`.
5. Highlight the selected model type visually.
6. Show the selected model type name in the middle panel header.

**Done when:**
- Left panel shows all model types in two groups.
- Tapping one updates `_selectedModelType`.
- Middle panel header reflects the selection.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AICodex Step 1: Navigation panel with model type list.

Current state:
- `lib/app/aicodex/aicodex.dart` is a static three-panel layout. All panels are placeholders.
- Regular bschema models exist under `lib/core/model/bschema/`, and 2 special base models (`SystemModel`, `UsrModel`) live under `lib/core/model/base/`.

Task:
- Make home a StatefulWidget.
- Add state: _selectedModelType, _selectedRowId.
- Left panel: ListView with two sections:
  - Schema Source: Entity, Field, Function, Parameter
  - Schema Target: Table, Column, System, User
- Tap sets _selectedModelType, clears _selectedRowId.
- Highlight selected item.
- Show selected name in middle panel header.

Constraints:
- Do not touch AIBook or AIStudio.
- Do not add route navigation.
- Keep one Scaffold.
- Keep analyzer green.
```

---

## Autopilot Agent Architecture Refactoring (2026-03-24)

### Goal
Eliminate architectural drift by refactoring the `Autopilot` agent layer into a decoupled, thin coordinator. Restore the intended design where `Autopilot` acts as a central orchestrator, while specialized copilots own their respective store interactions and logic.

### Changes
- **Refactored `Autopilot`**: Converted into a thin coordinator. It now delegates specialized logic to `CopilotUx` and `CopilotData` while remaining the single source of `notifyListeners()` (via `publishChange()`).
- **Copilots as "Body Code"**: Both `CopilotUx` and `CopilotData` receive the `Autopilot` instance in their constructors. They are structurally part of the "body code" of Autopilot, separated into distinct files solely for cleaner code review and maintainability.
- **Introduced `CopilotUx`**: Specialized copilot for managing transient UI state (paper/template/uwidget).
    - Owns `paper` and `template` scope lifecycle (mounting, clearing).
    - Prevents state collisions by using hierarchical scope keys: `paper.{route}.{i}` and `template.{route}.{paperI}.{templateI}`.
    - No longer owns navigation or global chrome state; it reads route info from Autopilot.
- **Introduced `CopilotData`**: Specialized copilot for managing business data facades over the shared `DataSet`.
- **Extracted `MockAuth`**: Moved mock authentication logic to a standalone utility class to remove model dependencies from `Autopilot`.
- **Navigation & Routing Overhaul**:
    - **`RouteSpec`** renamed to **`UxRouteHeaderSpec`** (represents the parsed path/intent).
    - **`UxRouteSpec`** represents the fully resolved route (header + app + spec + meta).
    - **`Autopilot`** now holds the resolved `UxRouteSpec` as `currentRoute`.
    - **Resolution Flow**: `AppRuntimeFlow` handles the conversion from `UxRouteHeaderSpec` to `UxRouteSpec` and calls `autopilot.mountRoute(resolvedSpec)`.
- **App Entry Points**: Added dedicated entry points for each app: `main_aicodex.dart`, `main_aistudio.dart`, `main_aibook.dart`, and `main_aiwork.dart`.

### Files Modified
- `lib/core/agent/autopilot.dart`
- `lib/core/agent/copilot_ux.dart`
- `lib/core/agent/copilot_data.dart`
- `lib/core/agent/mockauth.dart`
- `lib/core/model/uschema/ux_route_header_spec.dart`
- `lib/core/gen/app_runtime_flow.dart`

### Status
✅ Architectural drift eliminated; thin coordinator pattern restored.
✅ All four apps verified functional with the new routing flow.
✅ `flutter analyze` passes with zero errors and zero warnings.

