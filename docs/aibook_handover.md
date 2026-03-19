# AIBook Handover

Progressive step-by-step plan to reach constrained AIBook beta.

**Current status:** ~80% beta — internal vertical slice, working editor/preview flow, hybrid runtime.

---

## How to use this document

1. Find your current step (the first unchecked `[ ]` box).
2. Read only that step's section.
3. Complete the step, run the quality gate, check the box.
4. Move to the next step.

**Quality gate** (run after every step):
```bash
flutter analyze
flutter test
```

---

## What is already done

- [x] App shell with single `Scaffold`, body swap, loading/error states
- [x] `AutopilotGo` with spec configuration, field bindings, action registration
- [x] `Autopilot` with dual binding (slot-first `X.v[index]` + path fallback)
- [x] `MockTransport` loads merged spec/registry from `assets/json`
- [x] `DynamicSpecBody` routes to `FormTemplate`, `CheckboxFormTemplate`, `CollectionTemplate`, `DetailTemplate`
- [x] `TemplateRuntime` renders `column`, `spacer`, `textField`, `button`, `text` nodes
- [x] `XButton`, `XTextBox`, `XCheckBox` with binding + debug selection highlight
- [x] `UxRegistry` maps numeric IDs → names for host/body/template/type/widget
- [x] `UxSpecMapper` converts JSON nodes → typed UX models
- [x] Basic spec validation (duplicate IDs in bodies and widgets)
- [x] `SqliteStore` shared foundation (not wired to AIBook yet)
- [x] Tests: slot binding, validation, mock transport, body routing, widget behavior

---

## Step 1 — Numeric-only body routing

**Goal:** Remove string-driven body lookup from the runtime hot path. Numeric `bodyId` becomes the primary lookup; string name is fallback only.

**Files to change:**
- `lib/core/generator/boilerplate_generator.dart`
- `lib/core/model/ux/ux_registry.dart` (if needed)

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

## Step 2 — Validate binding references

**Goal:** Expand spec validation beyond duplicate IDs. Catch broken references before runtime render.

**Files to change:**
- `lib/app/aibook/autopilotgo.dart` (`_validateSpec`)

**What to do:**
1. Validate that every `fieldBinding` has both `src` and `fieldId`.
2. Validate that `actionId` references in body widgets match an action in the `actions` list.
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
- `_validateSpec` in `lib/app/aibook/autopilotgo.dart` currently only checks duplicate IDs in `bodiesRegistry` and `widgets`.
- The spec uses `actionId`, `templateId`, `typeId` in body definitions and child nodes.
- The registry has `actions`, `templates`, `types` lists.

Task:
- Expand `_validateSpec` to check cross-references:
  - `fieldBindings` must have `src` + `fieldId`.
  - `actionId` in body children must match an `actions` entry.
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

## Step 3 — Clean slot-first binding path

**Goal:** Ensure all business-bound runtime reads and writes go through slot-first resolution. Path binding should only activate when slot metadata is missing.

**Files to change:**
- `lib/core/agent/autopilot.dart` (review `resolveFieldBinding` / `updateFieldBinding`)
- `lib/app/aibook/autopilotgo.dart` (review `_configureFieldBindings`)

**What to do:**
1. Verify `_configureFieldBindings` registers slot for every business-bound binding entry that has one.
2. In `resolveFieldBinding`, confirm slot resolution is attempted before path resolution.
3. In `updateFieldBinding`, confirm slot write is attempted before path write.
4. Add a test that confirms: when slot is registered, path is NOT used even if present.
5. Add a test that confirms: when slot is NOT registered, path IS used as fallback.

**Done when:**
- Slot-first resolution is verified by tests.
- No regressions in existing binding behavior.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIBook Step 3: Clean slot-first binding path.

Current state:
- `Autopilot.resolveFieldBinding` and `updateFieldBinding` in `lib/core/agent/autopilot.dart` already try slot first, then fall back to path.
- `_configureFieldBindings` in `autopilotgo.dart` registers both slot and path from `fieldBindings` array.
- `test/autopilot_slot_test.dart` tests basic slot read/write.

Task:
- Verify the slot-first logic is clean and correct.
- Add a test that confirms path is NOT used when slot exists.
- Add a test that confirms path IS used when slot is missing.

Constraints:
- Do not remove path fallback — it is needed for migration.
- Do not change the Action/Todo system.
- Keep analyzer and tests green.
```

---

## Step 4 — Real transport boundary

**Goal:** Replace `MockTransport` with a real HTTP transport boundary for loading composition JSON and saving base `X` business data.

**Files to change:**
- `lib/core/agent/mock_transport.dart` → rename/refactor to `lib/core/agent/transport.dart`
- `lib/app/aibook/aibook.dart`
- `lib/app/aibook/autopilotgo.dart`

**What to do:**
1. Create a `Transport` class with `fetchSpec(String url)` and `saveRow(String url, X row)`.
2. Use `dart:io` `HttpClient` or add `http` package for POST requests.
3. Keep `MockTransport` available as a static fallback for local/offline development.
4. Update `AIBook` to accept a configurable base URL (can default to mock).
5. Follow the backend contract: POST body = `{"a": <actionId>, "u": "...", "p": "...", "data": {...}}`.
6. Add a test for transport failure handling (simulated network error).

**Done when:**
- AIBook can switch between mock and real transport.
- The real transport follows the planned backend contract.
- A transport failure shows a clear error state.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIBook Step 4: Real transport boundary.

Current state:
- `MockTransport` in `lib/core/agent/mock_transport.dart` loads spec from `assets/json` and simulates save.
- The planned backend is a C# ASP.NET Core Minimal API.
- POST body: `{"a": <actionId>, "u": "...", "p": "...", "data": {...}}`.
- PostgreSQL returns JSON directly via C# passthrough.

Task:
- Create `Transport` class alongside `MockTransport`.
- Implement `fetchSpec(url)` and `saveRow(url, X row)` with HTTP POST.
- Update `AIBook` to use transport (default to mock for now).
- Add transport failure test.

Constraints:
- Do not break the current mock-only path — it must remain usable.
- Follow the existing backend contract from `docs/lib_app_readme.md`.
- Keep analyzer and tests green.
```

---

## Step 5 — Local SQLite cache for AIBook

**Goal:** Wire `SqliteStore` into the AIBook runtime path so specs and/or `X` row data can be cached locally.

**Files to change:**
- `lib/core/db/aibook/` (new directory)
- `lib/app/aibook/autopilotgo.dart`
- `lib/app/aibook/aibook.dart`

**What to do:**
1. Create `lib/core/db/aibook/aibook_cache.dart` wrapping `SqliteStore` for AIBook concerns.
2. Cache the last-fetched spec JSON via `putJsonValue` / `getJsonValue`.
3. If transport fetch fails, try loading from cache before showing an error.
4. Optionally cache the last-saved `X` row for offline resilience.
5. Add a test for cache-hit-on-failure scenario.

**Done when:**
- AIBook loads from cache when transport is unavailable.
- Fresh transport data overwrites cached data.
- `flutter analyze` passes.
- `flutter test` passes.

---

## Step 6 — Harden failure states

**Goal:** Replace basic error text with clear, user-friendly failure views.

**Files to change:**
- `lib/app/aibook/aibook.dart`

**What to do:**
1. Create distinct error views for: malformed spec, malformed registry, transport failure, empty data.
2. Each error view should show the error type, a short description, and a retry action.
3. Ensure the FAB and bottom bar are hidden during error states.

**Done when:**
- Each failure type has a recognizable error view with retry.
- `flutter analyze` passes.
- `flutter test` passes.

---

## Step 7 — Preview mode decision

**Goal:** Decide whether debug-only selection highlighting becomes a production feature or stays debug-only.

**What to do:**
1. If **keeping debug-only**: no code change needed, just document it clearly in comments.
2. If **promoting to production**: 
   - Add a toggle button in the toolbar or FAB menu.
   - Show a clear visual indicator when preview mode is active.
   - Add an exit path (tap outside, or a clear "Exit Preview" button).
   - Add a test for the toggle behavior.

**Done when:**
- Decision is documented.
- If promoted: toggle, indicator, and exit are implemented and tested.

---

## Step 8 — Beta-path test expansion

**Goal:** Add focused tests that cover the full beta editor-to-preview flow.

**Files to change:**
- `test/` (new and existing test files)

**What to do:**
1. Integration test: load spec → render editor → type in text field → press save → switch to preview → verify title shows.
2. Test: transport failure shows error state and retry works.
3. Test: malformed spec validation catches bad references.
4. Test: slot-first binding round-trip (edit → save → reload → verify slot value).

**Done when:**
- All four test scenarios pass.
- `flutter analyze` passes.
- `flutter test` passes.

---

## Architecture constraints (apply to all steps)

- Do not redesign the architecture.
- Do not add route navigation.
- Do not merge `CopilotData` and `CopilotUX`.
- Keep implementation incremental and backward-compatible.
- Prefer numeric identity over human-readable runtime keys.
- Keep analyzer and tests green after every step.
- If adding registry/support JSON, put it under `assets/json`.

## Vocabulary quick reference

| Term | Meaning |
|---|---|
| `body` | Swapped `Scaffold.body` content region |
| `Ux*Model` | Definition-side UX/UI data |
| `X*` (widgets/) | Wrapped implementation controls |
| `X` / `Xi` / `Xia` / `Xiad` / `Xiade` (base/) | Business-bound transport shape |
| `slot` | Direct index into `X.v[]` |
| `src` | Binding source: 0=state, 1=dataSource, 2=dataSet |
| `i/a/d/e/t/n/s` | id, active, date, entity, type, name, secondary |
