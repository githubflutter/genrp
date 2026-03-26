# StateSet Runtime Handover For Jules (2026-03-26)

This document records the approved direction for replacing the current scope/zone-style UI runtime state with a centralized `StateSet` runtime tree.

The goal is to give Jules a concrete implementation plan without re-opening the architectural debate.

---

## 1. Approved Direction

### 1.1 Core StateSet Shape

The approved target shape is:

```dart
final Map<String, dynamic> _app = <String, dynamic>{};
final Map<int, Map<String, dynamic>> _rstate = <int, Map<String, dynamic>>{};
final Map<int, NodeMeta> _rtindex = <int, NodeMeta>{};
final Map<int, List<int>> _rtchildren = <int, List<int>>{};
```

Meaning:

- `_app` stores durable app-level state only.
- `_rstate` stores transient live runtime-node state keyed by `runtimeid`.
- `_rtindex` stores metadata for each live runtime node.
- `_rtchildren` stores explicit parent/child runtime ownership for recursive cleanup.

### 1.2 Naming Rules

- All state keys are lowercase.
- `_app` keys are lowercase strings.
- `_rstate[runtimeid]` inner keys are lowercase strings.
- `runtimeid` is a live mounted-node identity only.
- `specid` remains authored identity only.

Examples:

- `user`
- `mode`
- `viewmode`
- `activeid`
- `activeindex`
- `selectedids`
- `error`

### 1.3 Runtime Tree Rule

`uwidget` is a child of template.

The runtime tree should behave like:

```text
route
  template
    uwidget
    uwidget
    uwidget
```

There should no longer be a separate `uwidget` state bucket or ownership rule derived from encoded IDs.

### 1.4 No Longer Approved

The following older direction is no longer the target:

- encoded `templateCode()` / `uwidgetCode()`
- cleanup by arithmetic ownership inference
- `scopeKey`-driven runtime ownership
- zone-driven runtime lifecycle
- separate template/uwidget state buckets in `StateSet`

---

## 2. NodeMeta

Jules is allowed to introduce a `NodeMeta` class.

Recommended shape:

```dart
class NodeMeta {
  const NodeMeta({
    this.parentruntimeid,
    this.parentspecid,
    this.parentspectype,
    required this.routeid,
    required this.routetitle,
    required this.specid,
    required this.spectype,
  });

  final int? parentruntimeid;
  final int? parentspecid;
  final int? parentspectype;

  final int routeid;
  final String routetitle;

  final int specid;
  final int spectype;
}
```

Notes:

- `routetitle` is for human inspection and WYSIWYG-style debug views.
- `parentruntimeid` is still needed even if `parentspecid` exists.
- `_rtindex` should be `Map<int, NodeMeta>`, not `dynamic`.
- If desired, `runtimeid` itself does not need to be stored inside `NodeMeta`, because it is already the map key.

---

## 3. Runtime ID Strategy

`runtimeid` should look time-based, but still be monotonic and collision-safe inside one `StateSet`.

Recommended implementation:

```dart
int _lastruntimeid = 0;

int newid() {
  final now = DateTime.now().microsecondsSinceEpoch;
  if (now > _lastruntimeid) {
    _lastruntimeid = now;
  } else {
    _lastruntimeid++;
  }
  return _lastruntimeid;
}
```

Rules:

- Do not allocate `runtimeid` inside `build()`.
- Allocate once per mounted runtime node.
- Clear that runtime node on dispose.
- `runtimeid` is not persisted business identity.

---

## 4. StateSet Responsibilities

The new `StateSet` should own all of the following:

1. Durable app state via `_app`.
2. Live runtime-node state via `_rstate`.
3. Runtime registration metadata via `_rtindex`.
4. Runtime ownership graph via `_rtchildren`.
5. Recursive teardown of runtime descendants.

Recommended method surface:

```dart
T? app<T>(String key);
void setapp(String key, dynamic value);
void patchapp(Map<String, dynamic> values);

int newid();
int registerrt({
  int? parentruntimeid,
  required NodeMeta meta,
  Map<String, dynamic> initial = const <String, dynamic>{},
});

T? rt<T>(int runtimeid, String key);
void setrt(int runtimeid, String key, dynamic value);
void patchrt(int runtimeid, Map<String, dynamic> values);

void clearrt(int runtimeid);
void clearallrt();
void clearall();

Map<String, dynamic> snapshot();
```

Behavior rules:

- `setapp(key, null)` removes the app key.
- `setrt(runtimeid, key, null)` removes the runtime field.
- `clearrt(runtimeid)` recursively clears all child runtime nodes first.
- `clearallrt()` clears `_rstate`, `_rtindex`, `_rtchildren`, but does not clear `_app`.
- `clearall()` clears both `_app` and all runtime state.

---

## 5. Migration Constraints

These are part of the handover contract.

### 5.1 Must Stay Centralized

Transient runtime state must remain centralized in `StateSet`.

Do not move runtime state into:

- widget-local state as the long-term architecture
- separate controller registries
- detached helper maps outside `StateSet`

### 5.2 App State Must Stay Small and Durable

`_app` is only for long-lived app state.

Allowed examples:

- `user`
- `mode`
- `tenantid`
- `companyid`
- `preferences`

Not allowed in `_app`:

- per-template `viewmode`
- per-uwidget selection
- route-local temporary values
- disposable runtime draft state

### 5.3 WYSIWYG/Inspector Support

The design should remain inspectable by humans.

That is why `NodeMeta.routetitle` and `NodeMeta` generally exist.

Jules may later derive a visual inspector tree from:

- `_rtindex`
- `_rtchildren`
- `_rstate`

without depending on encoded runtime math.

---

## 6. File-Level Implementation Plan

### Phase 1: StateSet Core

Primary files:

- `lib/core/agent/state_set.dart`
- optionally `lib/core/agent/node_meta.dart`

Tasks:

1. Replace the current `_app`, `_node`, `_child` bucket design.
2. Introduce `_app`, `_rstate`, `_rtindex`, `_rtchildren`.
3. Implement `newid()`.
4. Implement `registerrt()`.
5. Implement recursive `clearrt()`.
6. Keep `snapshot()` useful for debugging during migration.

Acceptance:

- No encoded ownership arithmetic remains in `StateSet`.
- Recursive child cleanup works from `_rtchildren`.
- `flutter analyze` passes.

### Phase 2: Runtime Registration In Hosts

Primary files:

- `lib/core/ux/mixins.dart`
- `lib/core/agent/copilot_ux.dart`

Tasks:

1. Stop relying on `scopeKey`, `templateCode()`, and `uwidgetCode()` for runtime ownership.
2. Root/template host states should request a `runtimeid` once in `initState()`.
3. Host dispose should call `clearrt(runtimeid)`.
4. Parent runtime linkage should be explicit.

Acceptance:

- `runtimeid` is created once per mounted host.
- No runtime allocation happens in `build()`.
- route/template disposal removes descendant runtime state.

### Phase 3: Replace Current Template Runtime Access

Primary files:

- `lib/core/ux/template/tworkspace.dart`
- `lib/core/ux/template/tform.dart`
- `lib/core/ux/template/tsheet.dart`
- `lib/core/ux/template/treport.dart`
- `lib/core/ux/template/tdboard.dart`
- `lib/core/ux/template/twizard.dart`
- `lib/core/ux/mixins.dart`

Tasks:

1. Replace `templateState(scope, ...)` usage with `rt(runtimeid, key)`.
2. Replace `setTemplateState()` / `patchTemplateState()` with `setrt()` / `patchrt()`.
3. Replace any remaining scope-string flow with explicit `runtimeid`.

Important current hotspot:

- `lib/core/ux/template/tworkspace.dart` currently reads and writes:
  - `mode`
  - `viewmode`
  - `activeid`
  - `activeindex`
  - `selectedids`
  - `totalcount`
  - `error`

Acceptance:

- `tworkspace` no longer depends on scope strings.
- runtime state lookup is centralized through `StateSet`.
- all runtime keys are lowercase.

### Phase 4: Uwidget As Child Of Template

Primary files:

- `lib/core/gen/genux.dart`
- `lib/core/gen/uschema_codec.dart`
- `lib/core/gen/uschema_compiled.dart`
- `lib/core/model/uschema/ux_spec.dart`
- `lib/app/aiwork/aiwork_specs.dart`
- `lib/app/aibook/aibook_specs.dart`

Tasks:

1. Remove the idea that uwidget has a separate runtime bucket.
2. Make `uwidget` a real child in the render tree.
3. Move away from `uxzones`/slot-discovery for runtime ownership.
4. Make rendered child composition line up with `_rtchildren`.

Acceptance:

- runtime ownership mirrors the rendered UI tree.
- clearing a template recursively clears its uwidget descendants.
- no special uwidget ownership math remains.

### Phase 5: Delete Dead Architecture

Primary files:

- `lib/core/ux/mixins.dart`
- `lib/core/model/uschema/ux_spec.dart`
- `lib/core/agent/copilot_ux.dart`
- `lib/core/agent/state_set.dart`
- docs

Tasks:

1. Remove old scope/zone lifecycle helpers no longer used.
2. Remove encoded code helpers that are no longer needed for runtime state.
3. Update docs after the new runtime path is stable.

Acceptance:

- no live code path depends on old scope/zone runtime semantics
- analyzer remains clean

---

## 7. Current Code Hotspots Jules Must Understand

### 7.1 Current StateSet Is Still Scope/Zone-Style

Current file:

- `lib/core/agent/state_set.dart`

Current issues:

- app/node/child buckets
- string-key scoped maps
- cleanup by derived ownership
- route/template/uwidget treated as separate state layers

### 7.2 CopilotUx Still Computes Encoded IDs

Current file:

- `lib/core/agent/copilot_ux.dart`

Current issues:

- computes template codes and uwidget codes
- clears runtime state by encoded address
- still assumes template and uwidget are separate runtime concepts

### 7.3 Mixins Still Carry Scope Runtime Semantics

Current file:

- `lib/core/ux/mixins.dart`

Current issues:

- `UxZone`
- `scopeKey`
- route-scope comparison in host lifecycle
- state binding path still assumes string-key runtime state

### 7.4 Workspace Is The Primary Migration Proving Ground

Current file:

- `lib/core/ux/template/tworkspace.dart`

Current issues:

- most visible usage of transient template runtime state
- easiest place to prove the new `_rstate` shape

---

## 8. Guardrails

Jules should follow these guardrails strictly.

1. Do not reintroduce arithmetic ownership inference.
2. Do not allocate runtime IDs from `build()`.
3. Do not use `NodeMeta` as a replacement logic key system.
4. Do not let `_app` become a dumping ground for temporary UI state.
5. Keep lowercase keys consistent across `_app` and `_rstate`.
6. Keep analyzer green after each phase.
7. Prefer small migration steps that leave the apps runnable.

---

## 9. Suggested Execution Order

Recommended order:

1. Implement `NodeMeta` and the new `StateSet`.
2. Migrate host lifecycle registration/disposal.
3. Migrate `tworkspace`.
4. Migrate field binding helpers.
5. Migrate recursive child rendering/ownership.
6. Delete old runtime mechanics.

This order keeps the refactor testable and reduces the chance of half-migrated ownership bugs.

---

## 10. Minimum Verification For Each Phase

After every phase:

```bash
flutter analyze
```

Manual checks:

1. Launch AIWork.
2. Launch AIBook.
3. Navigate across routes.
4. Confirm runtime state is created for mounted nodes.
5. Confirm runtime state is removed when the owning node is disposed.
6. Confirm `_app` values survive runtime teardown.

---

## 11. Final Expected Result

At the end of this work:

- `StateSet` is the single centralized home for app and runtime UI state.
- runtime ownership is explicit and tree-based.
- `uwidget` is a child of template, not a separate state class.
- runtime state is inspectable and WYSIWYG-friendly through `_rtindex`.
- old scope/zone runtime mechanics are gone.
