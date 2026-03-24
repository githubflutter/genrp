# AIBook Handover

Progressive step-by-step plan to reach constrained AIBook beta.

**Current status:** Ready-to-run spec-driven client surface in the live snapshot. Typed route/paper/template specs are active through `AIBookSpecs` + `GenUx`, shared DB/request scaffolding already exists, and the active AIBook app has also been manually tested in this snapshot.

> [!NOTE]
> This handover was written for a pre-`core/ux` refactor snapshot. The current runtime entry points are `lib/app/aibook/aibook.dart`, `lib/app/aibook/aibook_specs.dart`, `lib/core/gen/genux.dart`, `lib/core/ux/ux.dart`, and `lib/core/model/uschema/ux_specs.dart`. References below to `autopilotgo.dart`, `MockTransport`, `boilerplate_generator.dart`, or wrapped `X*` widgets should be treated as historical guidance unless those files return in a later snapshot.

> [!IMPORTANT]
> The historical checklist below comes from the older JSON/registry runtime path. The live AIBook app in this snapshot is the seeded `UxRouteSpec` + `GenUx` path, not the old `MockTransport` path.

**Current next step:** Keep the spec-driven runtime stable as the active path. Archived Step 3 remains the next historical hardening step if deeper AIBook runtime work resumes.

**Role:** AIBook is a mobile-centric client app. It owns client/runtime CRUD and business-data consumption only.

**Scope rule:** AIBook is not a data designer and not a UX designer. Sensitive data-model CRUD belongs to `AICodex`. UX/spec CRUD belongs to `AIStudio`. AIBook should stay focused on client runtime flows and business-data consumption.

---

## How to use this document

1. Find your current step (the first `[ ] Step` heading).
2. Read only that step's section.
3. Complete the step, run the quality gate, check the box.
4. Move to the next step.

**Quality gate** (run after every step):
```bash
flutter analyze lib test
```

Current snapshot note: checked-in Dart test files have been deleted in this working tree, so `flutter analyze lib test` is currently the analyzer-only quality gate.
Manual app testing has already been completed for the active snapshot.

---

## [ ] Step 3 — Clean slot-first binding path

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
- Keep analyzer and tests green.
```

---

## [ ] Step 4 — Real transport boundary

**Goal:** Replace `MockTransport` with a real HTTP transport boundary for loading composition JSON.

**Files to change:**
- `lib/core/agent/mock_transport.dart` → rename/refactor to `lib/core/agent/transport.dart`
- `lib/app/aibook/aibook.dart`
- `lib/app/aibook/autopilotgo.dart`

**What to do:**
1. Create a `Transport` class with `fetchSpec(String url)`.
2. Use `dart:io` `HttpClient` for POST requests.
3. Keep `MockTransport` available as a static fallback for local/offline development.
4. Update `AIBook` to accept a configurable base URL (can default to mock).
5. Follow the backend contract for spec fetching.
7. Add a test for transport failure handling (simulated network error).

**Done when:**
- AIBook can switch between mock and real transport.
- The real transport follows the planned function-driven backend contract.
- A transport failure shows a clear error state.
- `flutter analyze` passes.
- `flutter test` passes.

**Copy-paste prompt:**
```text
Continue in `/Users/Shared/dev/git/genrp`.
You are working on AIBook Step 4: Real transport boundary.

Current state:
- `MockTransport` in `lib/core/agent/mock_transport.dart` loads spec from `assets/json` and simulates save.
- `lib/core/db/webclient.dart` already builds the generic remote action envelope, but there is no real runtime HTTP transport yet.
- The planned backend is a C# ASP.NET Core Minimal API.
- PostgreSQL returns JSON directly via C# passthrough.

Task:
- Create `Transport` class alongside `MockTransport`.
- Implement `fetchSpec(url)` with HTTP POST.
- Update `AIBook` to use transport (default to mock for now).
- Add transport failure test.

Constraints:
- Do not break the current mock-only path — it must remain usable.
- Follow the existing backend contract from `docs/lib_app_readme.md`.
- Keep analyzer and tests green.
```

---

## [ ] Step 5 — Local SQLite cache for AIBook

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

## [ ] Step 6 — Harden failure states

**Goal:** Replace basic error text with clear, user-friendly failure views.

**Files to change:**
- `lib/app/aibook/aibook.dart`

**What to do:**
1. Create distinct error views for: malformed spec, malformed registry, transport failure, empty data.
2. Each error view should show the error type, a short description, and a retry action.
3. Ensure extra chrome and the bottom bar are hidden during error states.

**Done when:**
- Each failure type has a recognizable error view with retry.
- `flutter analyze` passes.
- `flutter test` passes.

---

## [ ] Step 7 — Preview mode decision

**Goal:** Decide whether debug-only selection highlighting becomes a production feature or stays debug-only.

**What to do:**
1. If **keeping debug-only**: no code change needed, just document it clearly in comments.
2. If **promoting to production**: 
   - Add a toggle button in the toolbar.
   - Show a clear visual indicator when preview mode is active.
   - Add an exit path (tap outside, or a clear "Exit Preview" button).
   - Add a test for the toggle behavior.

**Done when:**
- Decision is documented.
- If promoted: toggle, indicator, and exit are implemented and tested.

---

## [ ] Step 8 — Beta-path test expansion

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
- Business-table CRUD should stay separate from spec transport.
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
| `i/a/d/e/t/n/s` | id, active, last date, editor, type, readable name, system name |
