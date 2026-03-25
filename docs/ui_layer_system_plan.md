# UI Layer System — Small-Model Execution Plan

**Goal:** remove paper from the live route -> render path in small, deterministic steps.

This version is intentionally written for a lower-capability model. It removes optional implementation branches, names the exact files to touch, and adds stop conditions so the model does not invent architecture while coding.

## Executor Rules

1. Execute one numbered task at a time. Do not combine phases.
2. After each numbered task, run `flutter analyze lib`. If it fails, fix only errors introduced by that task.
3. Do not change route paths, `pageSpecId`, zone names, cache keys, or widget ids unless a step explicitly says to.
4. Do not redesign templates or add new zones in this plan.
5. Do not delete paper runtime code before Phase 4.
6. Prefer adding small helpers over changing many call sites.
7. If a required change is not described here, stop and ask instead of inventing behavior.

## Current Code Facts

- Runtime compile entrypoint is `lib/core/gen/uschema_runtime.dart` -> `lib/core/gen/uschema_codec.dart`.
- Templates currently mount state through `UxTemplateHost`.
- Paper currently mounts state through `UxPaperHost`.
- Live app specs only use `paperzero` and `paperone`.
- The `test/` directory is empty, so verification is `flutter analyze lib` plus manual app runs.
- Current live route root ids:
  - AIWork: `10001`, `10002`
  - AIBook: `20001`, `20002`

## Non-Goals

- No zone expansion
- No menubar/panel/sidebar redesign
- No cache redesign
- No removal of `UxLayer.paper`, `UxSpec.paper`, or `UwStateSource.paper` in this migration

## Phase Order

1. Runtime plumbing only
2. Migrate AIBook
3. Migrate AIWork
4. Remove paper from the live runtime

## Phase 1 — Runtime Plumbing Only

**Goal:** root templates become legal runtime roots, but all existing paper-rooted routes must keep working unchanged.

### 1.1 Add Typed Frame Metadata

Files:
- `lib/core/model/uschema/ux_spec.dart`

Do exactly this:
- Add `UxFrameMeta` in this file. Do not create a separate file.
- Keep it minimal for now:

```dart
class UxFrameMeta {
  const UxFrameMeta({this.scroll = 'none'});

  final String scroll;

  Map<String, dynamic> toJson() => <String, dynamic>{'scroll': scroll};

  factory UxFrameMeta.fromJson(Map<String, dynamic> json) {
    return UxFrameMeta(scroll: json['scroll'] as String? ?? 'none');
  }
}
```

- Add `UxSpec.hasFrame`
- Add `UxSpec.frame`
- Add `UxSpec.rootTemplate(...)` factory with this exact behavior:
  - layer is `UxLayer.template`
  - metadata is `<String, dynamic>{...m, 'frame': frame.toJson()}`
  - all other fields match `UxSpec.template(...)`

Do not:
- change `UxWorkspaceMeta`
- add sidebar or panel widths
- change existing `UxSpec.paper`, `UxSpec.template`, or `UxSpec.uwidget`

Done when:
- `UxFrameMeta`, `UxSpec.hasFrame`, `UxSpec.frame`, and `UxSpec.rootTemplate(...)` exist
- `flutter analyze lib` passes

### 1.2 Add Compiled Root-Template Flag

Files:
- `lib/core/gen/uschema_compiled.dart`
- `lib/core/gen/uschema_codec.dart`

Do exactly this:
- In `UschemaCompiled`, add:
  - `final bool isRouteRoot;`
  - `UxFrameMeta? get frame => spec.hasFrame ? spec.frame : null;`
- Update the constructor to accept `isRouteRoot`
- In `UschemaCodec`, keep the public method name `compile(UxSpec spec)`
- Implement a private recursive helper so only the top-level compiled template is marked as a route root:

```dart
UschemaCompiled compile(UxSpec spec) {
  final rootLayer = UxLayer.fromCode(spec.l);
  return _compile(spec, isRouteRoot: rootLayer == UxLayer.template);
}
```

- Recursive child compiles must pass `isRouteRoot: false`
- Do not change cache keys or `UschemaRuntime`

Do not:
- infer rootness from `frame`
- mark nested templates as route roots

Done when:
- `compiled.isRouteRoot` is available everywhere
- top-level paper specs compile exactly as before
- top-level template specs compile with `isRouteRoot == true`
- `flutter analyze lib` passes

### 1.3 Add Route-Root Template Scope Support

Files:
- `lib/core/agent/copilot_ux.dart`

Do exactly this:
- Keep paper behavior working
- Add:
  - `_currentRootTemplateScope`
  - `_currentRootTemplateI`
  - getter(s) for the current root template
- Keep `_templateScopes` as the single set for all template scopes
- Add `rootTemplateScopeFor(int templateI)` with format:
  - `template.route.<routeScopeKey>.<templateI>`
- Add `routeNestedTemplateScopeFor({required int rootTemplateI, required int templateI})` with format:
  - `template.route.<routeScopeKey>.<rootTemplateI>.<templateI>`
- Add `mountRootTemplate({required int templateI, Map<String, dynamic> initialState = const <String, dynamic>{}, bool notify = true})`
- Add `clearRootTemplate(String scope, {bool notify = true})`

Update `mountCurrentTemplate(...)` with this exact order:
1. If there is an active paper, keep existing paper-scoped behavior
2. Else if there is an active root template and `templateI == _currentRootTemplateI`, return the active root scope and patch `initialState` into that scope
3. Else if there is an active root template, create a nested route-rooted template scope using `routeNestedTemplateScopeFor(...)`
4. Else throw `StateError('Cannot mount template $templateI without an active paper or route root template')`

Update `clearRoute()` so it:
- clears the current paper scope if present
- clears every scope in `_templateScopes`
- clears `_currentRootTemplateScope`
- clears `_currentRootTemplateI`
- still clears the existing paper chrome keys

Do not:
- add new chrome keys for root template scope
- remove paper methods yet

Done when:
- paper routes still work
- root template scope can exist without an active paper
- `mountCurrentTemplate()` works for both compatibility mode and root-template mode
- `flutter analyze lib` passes

### 1.4 Add A Root-Template Lifecycle Host

Files:
- `lib/core/ux/mixins.dart`

Do exactly this:
- Add `UxRootTemplateHost` beside `UxPaperHost`
- Make its lifecycle match `UxPaperHost`, but call:
  - `mountRootTemplate(templateI: widget.i, ...)`
  - `clearRootTemplate(...)`
- Track `_routeScope` exactly like `UxPaperHost`
- Keep `UxPaperHost` unchanged
- Keep `UxTemplateHost` unchanged in behavior

Important note:
- `UxTemplateHost` may stay unchanged only because `mountCurrentTemplate()` now knows how to reuse the active root template scope

Do not:
- change `UxZone`
- change `UxRegister`
- remove `UxPaperHost`

Done when:
- a root template can be mounted before the child template widget builds
- `flutter analyze lib` passes

### 1.5 Teach The Renderer About Route-Rooted Templates

Files:
- `lib/core/gen/genux.dart`

Do exactly this:
- Keep the existing paper path working
- Update `build()`:
  - `UxLayer.paper` -> existing paper builder
  - `UxLayer.template && compiled.isRouteRoot` -> new root-template builder
  - `UxLayer.template` -> existing template builder
- Add `_buildCompiledRootTemplate(...)`
- `_buildCompiledRootTemplate(...)` must:
  - build the same template widget that `_buildCompiledTemplate(...)` would build
  - wrap it in `UxRootTemplateHost`
  - apply outer scroll behavior from `compiled.frame?.scroll ?? 'none'`

Map scroll like this:
- `'none'` -> plain `Container(child: template)`
- `'vertical'` -> `SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(children: <Widget>[template]))`
- `'horizontal'` -> `SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: <Widget>[template]))`

Do not:
- edit paper widget files in Phase 1
- redesign `Tworkspace`

Done when:
- existing paper-rooted routes still render
- top-level template specs can render without paper
- `flutter analyze lib` passes

### Phase 1 Manual Check

1. Run `flutter run -t lib/main_aiwork.dart`
2. Run `flutter run -t lib/main_aibook.dart`
3. Confirm current paper-rooted routes still render exactly as before

## Phase 2 — Migrate AIBook

**Goal:** AIBook becomes the first app to use a root template directly.

Prerequisite:
- Phase 1 is complete and analyzed cleanly

Files:
- `lib/app/aibook/aibook_specs.dart`

Do exactly this:
- Rename:
  - `paperZeroSpecId` -> `routeZeroSpecId`
  - `paperOneSpecId` -> `routeOneSpecId`
- Keep the numeric values `20001` and `20002`
- Keep route paths unchanged
- Replace the outer `UxSpec.paper(...)` with `UxSpec.rootTemplate(...)`
- Root template values:
  - `i: route.pageSpecId`
  - `n: 'tworkspace'`
  - `t: 1`
- Frame mapping:
  - route zero -> `const UxFrameMeta(scroll: 'none')`
  - route one -> `const UxFrameMeta(scroll: 'vertical')`
- Move the inner template metadata and zones up to the new root template
- Delete the old `UxZone.content` wrapper
- Remove the old inner template id `21001`
- Keep all child widget ids unchanged
- Remove paper wording from route titles and subtitles

Preferred title and subtitle change:
- Title: `Workspace / ${route.optionalId ?? '-'}`
- Subtitle for route zero: `Root template host for AIBook`
- Subtitle for route one: `Scrollable root template host for AIBook`

Do not:
- change `optionalId` behavior
- change collection or detail widget ids
- add new zones

Done when:
- `aibook_specs.dart` has no `UxSpec.paper(`
- AIBook route roots are direct templates
- `flutter analyze lib` passes

### Phase 2 Manual Check

1. Run `flutter run -t lib/main_aibook.dart`
2. Visit `/aibook/20001/42`
3. Visit `/aibook/20002/42`
4. Confirm scroll behavior matches old `paperzero` and `paperone`
5. Confirm workspace state still works

## Phase 3 — Migrate AIWork

**Goal:** AIWork follows the same root-template pattern after AIBook is proven.

Prerequisite:
- Phase 2 is complete and analyzed cleanly

Files:
- `lib/app/aiwork/aiwork_specs.dart`

Do exactly this:
- Rename:
  - `paperZeroSpecId` -> `routeZeroSpecId`
  - `paperOneSpecId` -> `routeOneSpecId`
- Keep the numeric values `10001` and `10002`
- Keep route paths unchanged
- Replace the outer `UxSpec.paper(...)` with `UxSpec.rootTemplate(...)`
- Root template values:
  - `i: route.pageSpecId`
  - `n: 'tworkspace'`
  - `t: 1`
- Frame mapping:
  - route zero -> `const UxFrameMeta(scroll: 'none')`
  - route one -> `const UxFrameMeta(scroll: 'vertical')`
- Move the inner template metadata and zones up to the new root template
- Delete the old `UxZone.content` wrapper
- Remove the old inner template id `20001`
- Keep all child widget ids unchanged
- Remove paper wording from route titles and subtitles, but preserve the special-case subtitle logic for optional id `84`

Preferred subtitle logic:
- route zero -> `Root template host for AIWork`
- route one + optional id `84` -> `Replace-only route change for AIWork`
- route one otherwise -> `Scrollable root template with the same AIWork flow`

Do not:
- change the three preset routes
- change collection view modes
- add new zones

Done when:
- `aiwork_specs.dart` has no `UxSpec.paper(`
- AIWork route roots are direct templates
- `flutter analyze lib` passes

### Phase 3 Manual Check

1. Run `flutter run -t lib/main_aiwork.dart`
2. Visit `/aiwork/10001/42`
3. Visit `/aiwork/10002/42`
4. Visit `/aiwork/10002/84`
5. Confirm list, grid, table, create, edit, inspect, and route-replace behavior still work

## Phase 4 — Remove Paper From The Live Runtime

**Goal:** no live route uses paper rendering. Legacy paper specs may still parse, but they must normalize to a root template before render.

Prerequisites:
- Phase 3 is complete and analyzed cleanly
- `rg -n "UxSpec\\.paper\\(" lib/app` returns no results

### 4.1 Normalize Legacy Top-Level Paper Specs During Compile

Files:
- `lib/core/gen/uschema_codec.dart`

Do exactly this:
- If the top-level input spec has `l == UxLayer.paper.code`, normalize it before compiling
- Only support current live paper shapes:
  - `t == 0` -> `scroll: 'none'`
  - `t == 1` and `spec.style == 1` -> `scroll: 'horizontal'`
  - `t == 1` otherwise -> `scroll: 'vertical'`
- Read the first template child from `UxZone.content`
- Convert that child into a new `UxSpec.rootTemplate(...)` with:
  - `i: spec.i`
  - `n: templateChild.n`
  - `t: templateChild.t`
  - `m: templateChild.m`
  - `s: templateChild.s`
  - `uxzones: templateChild.uxzones`
  - `frame: UxFrameMeta(...)` from the mapping above
- If there is no template child in `UxZone.content`, throw `StateError`
- If `spec.t` is `2`, `3`, or `4`, throw `UnsupportedError`
- After normalization, compile the normalized root template, not the original paper node

Do not:
- invent a conversion for `ptwo`, `pthree`, or `pfour`
- change cache behavior

Done when:
- any top-level paper spec is compiled as a root template before render
- `flutter analyze lib` passes

### 4.2 Remove Paper Render Dispatch

Files:
- `lib/core/gen/genux.dart`

Do exactly this:
- Remove the `UxLayer.paper` branch from `build()`
- Remove `_buildCompiledPaper(...)`
- Keep root-template and nested-template rendering

Done when:
- `GenUx` no longer renders paper widgets directly
- `flutter analyze lib` passes

### 4.3 Remove Paper Widget Files And Exports

Files:
- `lib/core/ux/paper/pzero.dart`
- `lib/core/ux/paper/pone.dart`
- `lib/core/ux/paper/ptwo.dart`
- `lib/core/ux/paper/pthree.dart`
- `lib/core/ux/paper/pfour.dart`
- `lib/core/ux/ux.dart`

Do exactly this:
- Delete the five paper widget files
- Remove their exports from `lib/core/ux/ux.dart`

Do not:
- remove `UxLayer.paper`
- remove `UxSpec.paper`
- remove `UxRegister.papers`
- remove `UwStateSource.paper`

Done when:
- no live render code imports paper widgets
- `flutter analyze lib` passes

### 4.4 Deprecate Leftover Paper-Only Helpers Instead Of Deleting Them

Files:
- `lib/core/agent/copilot_ux.dart`
- `lib/core/ux/mixins.dart`

Do exactly this:
- Add `@Deprecated(...)` annotations to:
  - `mountPaper(...)`
  - `paperScopeFor(...)`
  - `clearPaperScope(...)`
  - `paperState(...)`
  - `setPaperState(...)`
  - `patchPaperState(...)`
  - `UxPaperHost`
- Keep `mountCurrentTemplate(...)`
- Keep current paper fields and implementations for compatibility
- Do not change `UxTemplateHost` in this phase unless analyzer requires a small mechanical fix

Done when:
- paper-only helpers are marked as compatibility APIs
- `flutter analyze lib` passes

## Verification Commands

Run after each numbered task:

```bash
flutter analyze lib
```

Useful greps:

```bash
rg -n "UxSpec\\.paper\\(" lib/app
rg -n "UxLayer\\.paper|_buildCompiledPaper|UxPaperHost|mountPaper\\(" lib/core
rg -n "UxRootTemplateHost|mountRootTemplate|isRouteRoot|UxFrameMeta" lib
```

## Final Acceptance Checklist

- Phase 1: existing paper-rooted apps still run
- Phase 2: AIBook renders from a root template with unchanged routes
- Phase 3: AIWork renders from a root template with unchanged routes
- Phase 4: paper widgets are no longer in the live render path
- `flutter analyze lib` passes at the end of every phase

## Important Stop Conditions

- If `flutter analyze lib` fails and the error is not caused by the current task
- If a top-level template needs a new layout behavior other than `none`, `vertical`, or `horizontal`
- If a route root needs new zones
- If any current app still depends on `ptwo`, `pthree`, or `pfour`
