# aibook_handover

Current AIBook status and ordered handover plan for reaching a constrained beta.

Current status
- Roughly `80%` of a constrained `AIBook` beta.
- Current status is beyond placeholder/demo level and is now an internal vertical slice.
- The app shell is stable with a single `Scaffold` and body swap only.
- The runtime is mostly numeric already, but still hybrid in a few important places.
- UX/UI composition and registry loading are working from `assets/json`.
- Preview selection/highlighting infrastructure exists and the wrapped controls can set selected identity in debug mode via long-press.
- Current verification status: `flutter analyze` passed and `flutter test` passed.

Implemented now
- `lib/app/aibook/aibook.dart`
  Loads spec through `MockTransport`, shows loading and error states, and shows validation errors returned by `AutopilotGo`.
- `lib/app/aibook/autopilotgo.dart`
  Configures field bindings, initial state, initial data, action registration, basic spec validation, and mock save behavior.
- `lib/core/agent/autopilot.dart`
  Owns binding resolution, binding updates, action dispatch, selected preview identity, and slot-first `X.v[index]` binding for business-bound data.
- `lib/core/agent/mock_transport.dart`
  Provides the current mock fetch/save loop for spec loading and row saving.
- `lib/core/db/sqlite_store.dart`
  Provides the current local SQLite foundation for catalog rows and JSON key/value storage.
  This is currently shared infrastructure; future `AIBook`-specific db code should live under `lib/core/db/aibook/`.
- `lib/core/generator/boilerplate_generator.dart`
  Chooses the current body template and routes to predefined templates.
- `lib/core/runtime/template_runtime.dart`
  Renders the current small runtime set for predefined UX node types.
- `lib/core/widgets/x_button.dart`
  Wrapped button implementation with action dispatch and optional selected highlight.
- `lib/core/widgets/x_text_box.dart`
  Wrapped text input implementation with binding and optional selected highlight.
- `lib/core/widgets/x_checkbox.dart`
  Wrapped checkbox implementation with binding and optional selected highlight.
- `assets/json/aibook_spec.json`
  Focused on body composition.
- `assets/json/aibook_registry.json`
  Holds hosts, bodies, templates, types, widgets, fieldBindings, and actions, including slot metadata for business-bound bindings.
- `test/autopilot_slot_test.dart`
  Covers slot-first read and write behavior for base `X`.
- `test/validation_test.dart`
  Covers current basic duplicate-id validation behavior.
- `test/mock_transport_test.dart`
  Covers current mock transport save behavior.

Architecture direction now locked in
- `Autopilot` remains the only orchestrator.
- `CopilotData` and `CopilotUX` remain separate.
- `body` means only the swapped `Scaffold.body` content region.
- `Ux*Model` means definition-side UI/UX data.
- `X*` under `lib/core/widgets` means wrapped implementation controls.
- Base `X` / `Xi` / `Xia` / `Xiad` / `Xiade` in `lib/core/base/x.dart` means business-bound transport/data shape.
- UX/UI composition data can come from the web as normal JSON.
- Business-bound runtime data should prefer base `X` transport.
- Binding direction should prefer slot/index access into `X.v`, with path lookup kept only as migration fallback.
- Under `lib/core/db`, app-facing db code should move toward app-specific directories such as `lib/core/db/aibook/`.

What is still not beta-ready
- Body routing is still partly string-driven at runtime.
- There is still a compatibility mix of slot binding and path binding at runtime.
- The transport/load/save loop is still mock-only, not a real web/API path yet.
- Local SQLite support exists, but it is not yet wired into the `AIBook` runtime path for cache or offline behavior.
- Spec/registry validation exists only in a basic form and is not yet comprehensive.
- Preview selection is available mainly as a debug-time inspection path, not yet as a full production preview workflow.
- Failure states are better than before, but still minimal for malformed registry references, action mismatches, and transport failures beyond the mock layer.

Beta target for this handover
- One real `AIBook` editor and preview flow.
- UX/UI composition loaded from web JSON.
- Business-bound data loaded and saved as base `X` transport.
- Numeric runtime path finished for body/template/type/widget/action/binding identity.
- Startup validation for malformed spec/registry data.
- Optional preview selection usable when enabled.
- `flutter analyze` and `flutter test` staying green.

Ordered handover plan
1. Freeze the runtime contract.
   Keep normal JSON for UX/UI composition and base `X` transport for business-bound data.
2. Finish the migration from hybrid binding to slot-first binding.
   Keep current path lookup only as fallback while validating all active business-bound bindings against `slot` metadata.
3. Keep base `X` row storage stable on the data side.
   Continue using the current `x_row` runtime shape and remove accidental drift back toward human-readable runtime keys.
4. Finish numeric-only body routing.
   Remove runtime dependence on body string names in `lib/core/generator/boilerplate_generator.dart` except for migration fallback.
5. Expand spec and registry validation.
   Validate duplicate ids, missing ids, bad binding references, bad action/template/type/widget references, and body/template mismatches before runtime render.
6. Replace mock transport with real transport for business data.
   Load composition JSON from web, load base `X` business data, save edited base `X` business data, and patch returned results into runtime state.
7. Decide whether local SQLite cache is needed in the `AIBook` runtime path.
   If needed, use `SqliteStore` for spec cache or local base `X` cache without changing the transport contract.
8. Decide whether preview selection stays debug-only or becomes an explicit preview mode feature.
   If kept for production use, give it a clear trigger and clear exit path.
9. Harden failure states.
   Add clear views for malformed spec, malformed registry, transport failure, load failure, save failure, and empty data.
10. Expand tests only around the beta path.
   Add focused tests for index-based binding, validation, one full editor to preview flow, and one transport failure case.

Immediate next recommended step
- Finish numeric-only body routing first.
- After that, replace `MockTransport` with a real transport boundary.

Files expected to change next
- `lib/core/generator/boilerplate_generator.dart`
- `lib/core/model/ux/ux_registry.dart`
- `lib/app/aibook/aibook.dart`
- `lib/core/agent/mock_transport.dart`
- `lib/core/db/aibook/` once `AIBook` gets app-specific db wiring
- optionally `lib/core/db/sqlite_store.dart` while shared foundation is still being used
- integration tests for body routing and real transport behavior

Handover cautions
- Do not redesign architecture.
- Do not add route navigation.
- Do not merge `CopilotData` and `CopilotUX`.
- Keep the implementation incremental and backward-compatible while migration fallback still exists.
- Prefer numeric identity and flat transport over human-readable runtime keys.

Copy-paste prompt

```text
Continue in `/Users/Shared/dev/git/genrp`.

You are working on `AIBook`.

Current architecture state:
- Flutter app with single `Scaffold`, no route stack, body swap only.
- `Autopilot` is the orchestrator.
- `CopilotData` and `CopilotUX` remain separate.
- Runtime is moving incrementally from string-driven spec to numeric registry-driven identity.
- Performance and efficiency come first. Prefer flat JSON, low-overhead lookups, and minimal abstraction.

Important naming decisions:
- `body` means only the swapped `Scaffold.body` content region.
- `Ux*Model` = definition/model side for UI/UX data.
- `X*` under `lib/core/widgets` = wrapped implementation controls.
- Base `X` / `Xi` / `Xia` / `Xiad` / `Xiade` under `lib/core/base/x.dart` = business-bound transport/data shape.
- Do not use `widget` or `row` loosely in architecture language.

Current transport direction:
- UX/UI composition data can come from the web as normal JSON.
- Business-bound runtime data should prefer base `X` transport.
- Binding direction should prefer slot/index access into `X.v`.
- Human-readable path binding is migration fallback only.

Current implemented state:
- `assets/json/aibook_spec.json` focuses on UI composition.
- `assets/json/aibook_registry.json` contains:
  - `hosts`
  - `bodies`
  - `templates`
  - `types`
  - `widgets`
  - `fieldBindings`
  - `actions`
- `fieldBindings` now support `slot` metadata for business-bound bindings.
- `AIBook` currently loads spec through `MockTransport` and shows load/validation errors in `lib/app/aibook/aibook.dart`.
- `AutopilotGo` loads `fieldBindings` from merged spec data, converts initial `x_row` JSON into base `X`, performs basic validation, and handles current mock save behavior.
- Numeric support exists with string fallback for:
  - `actionId`
  - `src + fieldId`
  - `templateId`
  - `typeId`
  - `bodyId`
  - `widgetId`
  - `hostId`
- `UxRegistry` resolves host/body/template/type/widget names.
- `UxSpecMapper` maps node JSON into `UxButtonModel`, `UxTextBoxModel`, and `UxCheckBoxModel`.
- `TemplateRuntime` uses `XButton` and `XTextBox`.
- `CheckboxFormTemplate` uses `XCheckBox`.
- `X*` controls use stable keys scoped by `hostId + bodyId + widgetId`.
- Optional preview selection/highlighting infrastructure exists using `hostId + bodyId + widgetId`.
- Wrapped controls can set selection in debug mode via long-press.
- `Autopilot` now resolves and updates business-bound values by `X.v[index]` first when slot metadata exists.
- Current mock transport can fetch merged spec and clone-save a base `X` row.
- A generic local SQLite foundation now exists in `lib/core/db/sqlite_store.dart`.
- Under `lib/core/db`, future app-facing db code should live under `lib/core/db/aibook/` for `AIBook`.

Relevant files:
- `lib/app/aibook/aibook.dart`
- `lib/app/aibook/autopilotgo.dart`
- `lib/core/agent/autopilot.dart`
- `lib/core/agent/action_set.dart`
- `lib/core/agent/mock_transport.dart`
- `lib/core/db/sqlite_store.dart`
- future `AIBook`-specific db files under `lib/core/db/aibook/`
- `lib/core/generator/boilerplate_generator.dart`
- `lib/core/runtime/template_runtime.dart`
- `lib/core/model/ux/ux_registry.dart`
- `lib/core/model/ux/ux_spec_mapper.dart`
- `lib/core/model/ux/ux_button_model.dart`
- `lib/core/model/ux/ux_text_box_model.dart`
- `lib/core/model/ux/ux_checkbox_model.dart`
- `lib/core/widgets/x_button.dart`
- `lib/core/widgets/x_text_box.dart`
- `lib/core/widgets/x_checkbox.dart`
- `lib/core/base/x.dart`
- `assets/json/aibook_spec.json`
- `assets/json/aibook_registry.json`
- `docs/aibook_handover.md`
- `docs/lib_app_readme.md`
- `test/autopilot_slot_test.dart`
- `test/validation_test.dart`
- `test/mock_transport_test.dart`

Current quality status:
- `flutter analyze` passes.
- `flutter test` passes.

Current gap to beta:
- Body routing is still partly string-driven at runtime.
- Binding now supports slot-first `X.v[index]`, but the runtime is still hybrid because path fallback remains active.
- Transport/load/save is still mock-only, not a real web/API path yet.
- SQLite support exists, but it is not yet wired into the `AIBook` runtime path for cache or offline behavior.
- Validation exists, but only in a basic form.
- Selection highlight exists and can be triggered in debug mode, but it is not yet a polished production preview flow.

Immediate next recommended step:
- Finish numeric-only body routing in `lib/core/generator/boilerplate_generator.dart`.

Ordered next steps:
1. Finish numeric-only body routing and reduce string body lookup to fallback only.
2. Expand validation beyond duplicate ids into reference validation and body/template consistency checks.
3. Replace `MockTransport` with the real transport/load/save loop for composition JSON and base `X` business data.
4. Decide whether local SQLite cache should be wired into `AIBook` for spec or base `X` cache behavior.
5. Decide whether preview selection remains debug-only or becomes a real preview feature.
6. Harden failure states and focused beta-path tests.

Constraints:
- Do not redesign architecture.
- Do not add route navigation.
- Do not merge `CopilotData` and `CopilotUX`.
- Keep analyzer clean after each step.
- If adding more registry/support JSON, put it under `assets/json`.
- Prefer incremental compatibility paths over sudden rewrites.
```
