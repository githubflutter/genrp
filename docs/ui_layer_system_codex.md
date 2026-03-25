# UI Layer System — Codex Follow-Up

**Status:** Review of the revised Qwen proposal  
**Date:** 2026-03-25  
**Scope:** Validate the updated phased plan for paper removal and clarify the remaining implementation decisions before code changes begin.

---

## Executive Verdict

The revised Qwen proposal is now aligned with the direction I would recommend.

The biggest issues from the earlier version have been addressed:

- paper removal is now separated from the richer zone redesign
- `pageSpecId` is preserved for route identity
- root template IDs are route-owned instead of reusing shared inner template IDs
- frame/layout metadata is separated from `UxWorkspaceMeta`
- panel grouping is modeled as explicit nested nodes instead of flat widget lists
- menubar ownership is moved to zone specs instead of duplicated metadata

**Recommendation:** proceed with the revised phased plan, starting with runtime plumbing only.

That said, a few implementation details still need to be locked down before Phase 1 code work starts.

---

## What The Revised Qwen Proposal Gets Right

The updated document in [`docs/ui_layer_system_qwen.md`](/Users/Shared/dev/git/genrp/docs/ui_layer_system_qwen.md) now reflects the main runtime constraints correctly.

### 1. It no longer treats paper as "just a wrapper"

This was the most important correction.

The revised proposal now explicitly recognizes that paper currently participates in:

- state scope mounting
- route/root identity
- compiled-cache identity
- render dispatch
- register/code lookups

That matches the actual runtime behavior in:

- [`lib/core/agent/copilot_ux.dart`](/Users/Shared/dev/git/genrp/lib/core/agent/copilot_ux.dart)
- [`lib/core/gen/genux.dart`](/Users/Shared/dev/git/genrp/lib/core/gen/genux.dart)
- [`lib/core/gen/uschema_cache.dart`](/Users/Shared/dev/git/genrp/lib/core/gen/uschema_cache.dart)
- [`lib/core/model/uschema/ux_route_header_spec.dart`](/Users/Shared/dev/git/genrp/lib/core/model/uschema/ux_route_header_spec.dart)

### 2. It preserves route identity

Keeping `pageSpecId` stable is the correct call.

Paper can disappear as a runtime layer without changing:

- route paths
- route scope keys
- route-owned root IDs

That makes the migration much safer and avoids turning a runtime cleanup into a routing contract rewrite.

### 3. It fixes the cache-key problem

The updated proposal now keeps the root template `i` equal to `route.pageSpecId`.

That avoids the earlier collision risk where several routes could have been flattened onto the same shared inner template ID.

This is the right move given the current cache contract in [`lib/core/gen/uschema_cache.dart`](/Users/Shared/dev/git/genrp/lib/core/gen/uschema_cache.dart).

### 4. It splits layout metadata from business metadata

Moving frame/layout behavior into a separate `UxFrameMeta` is better than extending `UxWorkspaceMeta` indefinitely.

That keeps:

- business/workspace configuration in one place
- outer frame/layout concerns in another

This is a cleaner long-term schema direction.

### 5. It defers the zone redesign until after runtime migration

This is the other major correction.

The current runtime is not ready for a rich zone system yet, because templates still render from fixed slot extraction rather than true zoned child composition.

The revised phase split now reflects that correctly:

- first make root templates legal
- then migrate specs
- then remove paper
- only after that add a real zone rendering contract

That sequencing is strong.

---

## Remaining Decisions Before Phase 1

The revised Qwen proposal is now directionally correct. The remaining work is mostly about tightening the implementation contract.

### 1. Root template detection should not rely on `frame` metadata alone

The Qwen proposal uses pseudocode similar to:

- root template if `m['frame'] != null`
- or root template if `s['isRoot'] == true`

That is acceptable as a sketch, but I would not make that the final runtime rule.

Why:

- a nested template may also want frame metadata later
- rootness is a structural property, not a styling hint
- `s['isRoot']` is mutable/live state and should not define structural identity

**Recommended resolution:**

- make root-vs-nested explicit in the render call path, or
- store a compiled structural flag such as `compiled.isRouteRoot`, or
- pass root-template rendering through a dedicated entrypoint

Any of those is safer than inferring rootness from optional metadata.

### 2. `CopilotUx` needs one clear template-scope model

The revised proposal correctly introduces route-rooted template scope, but the exact API shape still needs one deliberate decision.

Right now the runtime has paper-rooted template scope:

- `mountPaper(...)`
- `mountTemplate(paperI: ..., templateI: ...)`
- `mountCurrentTemplate(...)`

If root templates are added, avoid ending up with a confusing long-term mix of:

- paper-rooted template mounting
- root-template mounting
- direct scope mounting by raw string

**Recommended resolution:**

- define one stable scope format for root templates
- define one stable scope format for nested templates
- make `clearRoute()` and nested cleanup rules explicit from day one

I would prefer a model where route-owned root template scope is first-class and paper-rooted scope is only temporary compatibility behavior.

### 3. Decide how legacy paper specs are normalized after Phase 4

The revised proposal keeps `UxLayer.paper` as deprecated for historical parsing, which is sensible. But the runtime contract after Phase 4 should be explicit.

There are two valid options:

**Option A**

- legacy paper specs are still accepted
- they are normalized to root templates during compile/load

**Option B**

- legacy paper specs are no longer accepted at runtime
- they must be migrated before use

Either is fine, but the code should not end up in a middle state where:

- `UxLayer.paper` still parses
- paper rendering is gone
- old persisted specs fail in unpredictable ways

### 4. Panel grouping is fixed conceptually, but the container type is still open

The revised proposal correctly changes panel grouping from "flat widget list" to "explicit nested node". That solves the original ambiguity.

The remaining question is what that nested node should be.

The current Qwen examples use nested templates such as `tform` as containers. That is workable as pseudocode, but I would treat it as a placeholder, not the final semantic model.

Why:

- `tform` is a real template name with its own intended meaning
- using business templates as neutral containers can blur schema intent
- the other template types are still mostly placeholders today

**Recommended resolution:**

- either introduce a small neutral container template later
- or define that any nested template in `UxZone.panel` is a legitimate grouped panel surface with its own semantics

The key point is to make the grouping model intentional, not accidental.

### 5. The zone rendering contract still needs one concrete design choice

The revised proposal now correctly states that richer zones require real zone rendering, not just new constants.

Before Phase 5 implementation begins, choose one of these paths:

1. pass `UschemaCompiled` directly into templates
2. pass a `renderZone(String zone)` callback
3. pass prepared zoned child collections into templates

Any of these can work. The important part is to pick one early and use it consistently.

My bias is toward a small `renderZone(...)` contract because it keeps templates focused on layout while leaving tree traversal in the renderer.

### 6. Frame metadata should get typed accessors immediately

If `UxFrameMeta` is added, the runtime should not spend long reading raw `m['frame']` maps everywhere.

Add typed accessors early, for example through:

- `UxSpec.frame`
- `UschemaCompiled.frame`
- `UxSpec.hasFrame`

That will keep the migration tidy and reduce "stringly typed" frame logic spreading across the codebase.

### 7. The merged metadata pattern should be implemented carefully

The revised Qwen proposal is correct to keep frame metadata separate conceptually, but the code implementation should avoid ad hoc map assembly.

When a root template stores both:

- `frame`
- workspace/business metadata

use one clean merge path rather than repeated inline map manipulation.

That can be as simple as a helper constructor or a small builder utility, but it should be deliberate.

---

## Implementation Notes I Would Carry Forward

These are the practical guardrails I would use while implementing the revised plan.

### Phase 1 guardrails

- keep paper-rooted rendering fully functional
- add root-template scope without breaking current paper scope
- do not remove `UxPaperHost` yet
- do not redesign template zones yet
- add tests for root-template mounting and cache identity before migrating app specs

### Phase 2-3 guardrails

- migrate AIBook first
- keep `route.pageSpecId` unchanged
- keep route URLs unchanged
- keep root template `i` equal to `route.pageSpecId`
- only map `paperzero` and `paperone` behavior at this stage, since those are the only live variants in current app specs

### Phase 4 guardrails

- remove paper runtime only after no live specs depend on it
- decide normalization vs rejection for legacy paper specs before deleting dispatch code
- keep the cleanup mechanical and small once migration is proven

### Phase 5+ guardrails

- prove richer zone rendering in `Tworkspace` only
- do not spread the new contract across all template stubs at once
- lock panel grouping semantics before building menubar logic on top of it

---

## Recommended Test Coverage

The revised Qwen proposal already calls for manual testing. I would add a few targeted runtime tests as non-negotiable coverage.

### Must-have automated checks

- root-template route mounts without an active paper
- paper-rooted route still mounts during compatibility phase
- route scope keys remain unchanged after spec migration
- cache entries stay unique across different root-template routes
- `clearRoute()` clears all root and nested template scopes correctly
- migrated AIWork and AIBook routes still resolve the same paths as before

### Nice-to-have follow-up checks

- compiled root-template render path and nested-template render path both work
- `UxFrameMeta` parsing defaults behave correctly
- future zone-rendering contract handles empty zones cleanly

---

## Final Position

My earlier concerns were mainly about the original Qwen proposal trying to do too much in one step.

That concern is now resolved.

The revised Qwen plan is strong enough to use as the working architecture proposal, with these remaining cautions:

- make root-template detection structural, not metadata-inferred
- define one clear `CopilotUx` scope model for the migration
- decide legacy paper normalization explicitly
- keep grouped panel containers intentional
- choose one concrete zone-rendering contract before Phase 5

With those decisions in place, I would treat the revised Qwen document as the main migration plan and this Codex note as the implementation guardrail companion.

---

## Suggested Immediate Next Step

Begin Phase 1 with a small runtime-only patch set:

1. add `UxFrameMeta`
2. add root-template scope support in `CopilotUx`
3. teach `GenUx` to render both paper-rooted and root-template specs
4. add tests for cache identity and route-rooted template mounting

That is the cleanest way to validate the architecture before touching AIWork and AIBook spec trees.
