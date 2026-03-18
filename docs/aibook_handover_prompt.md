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
- `AIBook` loads both JSON files and merges them in `lib/app/aibook.dart`.
- `AutopilotGo` loads `fieldBindings` from merged spec data instead of hardcoding them.
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

Relevant files:
- `lib/app/aibook.dart`
- `lib/app/autopilotgo.dart`
- `lib/core/agent/autopilot.dart`
- `lib/core/agent/action_set.dart`
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

Current quality status:
- Last known `flutter analyze` passed.
- Last known `flutter test` passed.

Current gap to beta:
- Body routing is still partly string-driven at runtime.
- Binding resolution is still path-first, not `X.v[index]`-first.
- No real web transport/load/save loop for business data yet.
- No full spec/registry validation layer yet.
- Selection highlight exists, but no main producer flow sets it in real use.

Immediate next recommended step:
- Implement `X`-backed slot/index binding in `Autopilot` and registry first.

Ordered next steps:
1. Add `slot` or `index` metadata to `fieldBindings` in `assets/json/aibook_registry.json`.
2. Extend `Autopilot` so `resolveFieldBinding()` and `updateFieldBinding()` prefer `X.v[index]` and fall back to path lookup only when needed.
3. Add base `X` row storage on the data side.
4. Finish numeric-only body routing and reduce string body lookup to fallback only.
5. Add spec and registry validation before runtime render.
6. Add the real transport/load/save loop for composition JSON and base `X` business data.
7. Harden failure states and focused beta-path tests.

Constraints:
- Do not redesign architecture.
- Do not add route navigation.
- Do not merge `CopilotData` and `CopilotUX`.
- Keep analyzer clean after each step.
- If adding more registry/support JSON, put it under `assets/json`.
- Prefer incremental compatibility paths over sudden rewrites.
```
