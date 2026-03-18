# aibook_handover_prompt

Use the prompt below to hand off ongoing `AIBook` work to another coding agent.

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

Relevant files:
- `lib/app/aibook/aibook.dart`
- `lib/app/aibook/autopilotgo.dart`
- `lib/core/agent/autopilot.dart`
- `lib/core/agent/action_set.dart`
- `lib/core/agent/mock_transport.dart`
- `lib/core/db/sqlite_store.dart`
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
- `docs/aibook_beta_handover.md`
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
