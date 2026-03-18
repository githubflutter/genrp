# aibook_beta_handover

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
- optionally `lib/core/db/sqlite_store.dart` if local cache is wired in
- integration tests for body routing and real transport behavior

Handover cautions
- Do not redesign architecture.
- Do not add route navigation.
- Do not merge `CopilotData` and `CopilotUX`.
- Keep the implementation incremental and backward-compatible while migration fallback still exists.
- Prefer numeric identity and flat transport over human-readable runtime keys.
