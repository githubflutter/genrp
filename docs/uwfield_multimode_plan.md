# UwField — Multimode Input Widget Plan

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
