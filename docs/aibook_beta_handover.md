# aibook_beta_handover

Current AIBook status and ordered handover plan for reaching a constrained beta.

Current status
- Roughly `70%` of a constrained `AIBook` beta.
- Current status is beyond placeholder/demo level and is now an internal vertical slice.
- The app shell is stable with a single `Scaffold` and body swap only.
- The runtime is partly numeric already, but still hybrid in a few important places.
- UX/UI composition and registry loading are working from `assets/json`.
- Preview selection/highlighting infrastructure exists, but there is not yet a producer flow that sets selection during runtime use.
- Last known verification before this docs-only update: `flutter analyze` passed and `flutter test` passed.

Implemented now
- `lib/app/aibook.dart`
  Loads `aibook_spec.json` and `aibook_registry.json`, merges them, and runs the app with one `Scaffold`.
- `lib/app/autopilotgo.dart`
  Configures field bindings, initial state, initial data, and action registration from spec data.
- `lib/core/agent/autopilot.dart`
  Owns binding resolution, binding updates, action dispatch, and selected preview identity using `hostId + bodyId + widgetId`.
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
  Holds hosts, bodies, templates, types, widgets, fieldBindings, and actions.

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
- Binding resolution is still path-first, not `X.v[index]`-first.
- There is no real transport/load/save loop for business data yet.
- There is no spec/registry validation pass yet.
- There is no runtime producer flow for preview selection yet.
- Failure states are still minimal for bad JSON, bad registry data, load errors, and save errors.

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
2. Change field binding registry to index-first.
   Add `slot` or `index` metadata in `assets/json/aibook_registry.json` for business-bound sources.
3. Upgrade `Autopilot` binding resolution.
   Extend `lib/core/agent/autopilot.dart` so `resolveFieldBinding()` and `updateFieldBinding()` prefer `X.v[index]` and fall back to path lookup only when needed.
4. Add base `X` row storage on the data side.
   Decide where the current business row lives and let `Autopilot` read and write it by slot.
5. Finish numeric-only body routing.
   Remove runtime dependence on body string names in `lib/core/generator/boilerplate_generator.dart` except for migration fallback.
6. Add spec and registry validation.
   Validate duplicate ids, missing ids, bad binding references, and bad action/template/type/widget references before runtime render.
7. Wire preview selection producer flow.
   Choose the preview interaction that sets `hostId + bodyId + widgetId` and keep it off by default for normal production flow.
8. Add real transport for business data.
   Load composition JSON from web, load base `X` business data, save edited base `X` business data, and patch returned results into runtime state.
9. Harden failure states.
   Add clear views for malformed spec, malformed registry, transport failure, load failure, save failure, and empty data.
10. Expand tests only around the beta path.
   Add focused tests for index-based binding, validation, one full editor to preview flow, and one transport failure case.

Immediate next recommended step
- Implement `X`-backed slot/index binding in `Autopilot` and registry first.
- Do not start transport work before that, because the runtime contract should be correct before wiring remote data.

Files expected to change next
- `assets/json/aibook_registry.json`
- `lib/core/agent/autopilot.dart`
- `lib/app/autopilotgo.dart`
- `lib/core/agent/copilot_data.dart`
- tests for binding and runtime behavior

Handover cautions
- Do not redesign architecture.
- Do not add route navigation.
- Do not merge `CopilotData` and `CopilotUX`.
- Keep the implementation incremental and backward-compatible while migration fallback still exists.
- Prefer numeric identity and flat transport over human-readable runtime keys.
