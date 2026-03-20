# New Experiment

## Purpose

This note freezes the **data-layer architecture** for the next experiment.

The UX/navigation philosophy may change, but the data layer should stay aligned
with the current repo shape:

- current `X` variants stay
- current typed model families stay
- numeric id rules stay
- current datatype mapping stays

So the experiment is **not** a data-layer rewrite. It is a UX/runtime
restructure on top of the existing data foundation.

## Current Status

This experiment is no longer a side branch or planning-only direction.

It has already been merged into the active codebase.

Current merged status:

- the active runtime now spans `lib/core/agent`, `lib/core/gen`, and `lib/core/ux`
- the active UX contracts live under `lib/core/ux`
- spec rendering lives under `lib/core/gen`
- persisted `uschema` UX-spec ids stay `int32/int4`; draft rows use `i = 0` and first persistence uses `max(i) + 1`
- `MainApp` now boots directly into `AIWorkApp`
- dedicated login and loading screens are already part of the app flow
- `AIWork` and `AIBook` still use local preset specs in this snapshot, but the final client direction remains server-spec-driven UI
- `AIStudio` and `AICodex` are currently in the hard-coded/demo authoring-shell stage
- the current merged runtime has already been manually tested
- `flutter analyze lib test` currently passes

So this note should now be read as:

- merged architecture record
- current-direction guardrail
- cleanup/hardening note for the next steps

## App Structure

The active app surfaces are:

- `AIWork`
- `AIBook`
- `AICodex`
- `AIStudio`

Purpose guardrails:

- `AIWork` remains a desktop/tablet-centric client app.
- `AIBook` remains a mobile-centric client app.
- `AIWork` and `AIBook` are client CRUD apps only.
- `AIWork` and `AIBook` do not include data designer or UX designer scope.
- `AICodex` and `AIStudio` keep their original purpose unchanged.

The runtime should be shaped around:

- `MainApp` -> direct `AIWorkApp` boot
- app entry -> `<AppName>App`
- app shell -> `<AppName>Home`
- dedicated app-owned login screen
- dedicated loading screen
- ready route rendered from `UxRouteSpec` through `GenUx`

`Autopilot` remains the shared base runtime/controller contract.

There is no `UxAppSession` in the forward direction anymore.
Do not introduce `GenrpApp`, `GenrpHome`, or `UxAppSession` as new mandatory
runtime layers unless a later code need clearly proves they are necessary.

Startup orchestration should stay small and practical:

- auth/login is a dedicated screen, not a session object
- loading is a dedicated temporary screen
- app bootstrap is owned directly by the app home flow plus `Autopilot`
- route rendering begins only after bootstrap is ready
- local preset specs are an intentional temporary stand-in; the final client target is server-spec-driven UI

## Main Migration Decision

The experiment has already become the **main forward direction** for
UX/runtime work and is already merged into the active repo.

That means:

- the experiment is a subset under the original implementation
- the final merge target is responsibility-based under `core/*`
- `AIWork`, `AIBook`, `AICodex`, and `AIStudio` share the canonical
  implementation path
- route/runtime agent logic should merge under `core/agent`
- schema/spec models should merge under `core/model/uschema`
- spec rendering currently lives under `core/gen`
- shared UX contracts and primitives currently live under `core/ux`
- do not create new wrapper/session layers just to rename what already works
- the old runtime is treated as legacy and migration source only

This remains a **forward-only** decision.

Do not plan around backward compatibility.
Do not add compatibility shims just to preserve the old runtime shape.
Do not keep dual architectures alive longer than necessary.

Rules:

- new architecture work should be designed for eventual merge into:
  - `core/agent`
  - `core/gen`
  - `core/model/uschema`
  - `core/ux`
  - `core/theme`
- old runtime paths get fixes only if needed to keep the repo buildable during
  migration
- migration should prefer rewrite/replacement over wrapping/adapting old paths
- once a slice is migrated and verified, the old slice should become a delete
  candidate

## Active Core Structure

The active architecture now lives directly under `lib/core`.

- `lib/core`
  - is now the active core architecture
  - currently contains `agent`, `base`, `db`, `gen`, `model`, `theme`, and `ux`
  - keeps spec rendering under `core/gen`
  - keeps the active paper/template/Uwidget contracts under `core/ux`
  - keeps route/session state under `core/agent`
  - keeps shared app theme/chrome rules under `core/theme`
  - keeps spec models under `core/model/uschema`

Working rule:

- treat legacy shapes as input-only when a migration bridge is still needed
- put new architecture work directly into `core/*`
- do not reintroduce archived architecture boundaries into the active tree

Current runtime note:

- `MainApp` boots directly into `AIWork`
- each app currently owns its own dedicated login screen
- each app currently owns its own loading screen
- scoped runtime state is owned by the runtime path under `core/agent`
- `Paper -> Template -> Uwidget` is the active UI composition model
- `AIStudio` and `AICodex` currently use app-owned hard-coded/demo shells rather than SQLite-backed row editing
- the merged app flows have already been manually tested
- the active implementation should stay small and practical, not carry extra
  staging layers

Historical wording note:

- older `View` references below should be read as today's `Uwidget` / `Uw*` layer unless the text is explicitly discussing an archived design

For future discussion in this experiment:

- **our app** means one of the four active app shells
- shared runtime work should stay app-agnostic unless a specific app earns a
  specialized branch

## App Startup Flow

After successful login, an app should not jump directly into a partially
loaded shell.

Instead, the flow should be:

1. login succeeds
2. show a dedicated loading page
3. in background, the app bootstrap flow loads:
   - current `usr`
   - current `user`
   - route presets for the current app
   - dynamic UX schema/spec for the startup route
4. when bootstrap is ready, replace the loading page with the resolved route

This gives us a cleaner startup contract:

- authentication first
- bootstrap second
- route render last

### Why This Matters

This avoids:

- showing incomplete navigation
- rendering a route before its UX contract is loaded
- mixing login flow with route/bootstrap flow
- leaking stale startup state across users

### Bootstrap Ownership

This bootstrap sequence should be owned directly by the app home flow plus
`Autopilot`.

That means:

- login success updates `autopilot.usr` and `autopilot.user`
- loading page becomes the temporary active screen
- route presets and startup context are resolved
- route-specific UX schema/spec is fetched
- only then does route rendering begin

### Dedicated Login Rule

Login should stay explicit and dedicated.

That means:

- do not hide login flow inside a session helper
- do not make login another template/view concern
- keep login as a dedicated screen or dedicated auth widget owned by the app
- if login is shared later, extract it as a normal widget/module, not as
  `UxAppSession`

### Loading Page Rule

The loading page is not the final route.  
It is a temporary bootstrap state while background work completes.

Recommended loading tasks:

- user profile resolution
- permission / navigation map resolution
- startup route resolution
- route-specific UX schema/spec fetch for that route

## Core Rule

Keep these parts stable:

1. `X` remains the dense runtime row/value carrier.
2. typed schema models remain the authoring and metadata layer.
3. ids remain numeric and stable.
4. datatype mapping remains numeric-first.
5. persistence stays catalog-row oriented with JSON payload extension.

### UX Spec Id Rule

For `uschema` UX-spec rows:

- persisted `i` and `e` stay `int32/int4`
- new drafts use `i = 0`
- first save allocates `max(i) + 1`
- later saves update in place when `i > 0`
- do not switch persisted UX-spec ids to epoch-based or runtime-generated ids

## Autopilot-Owned Context

Some values are global readonly context and should live on `Autopilot`
directly, not inside `StateSet`.

These are:

- `autopilot.v`
  - application/runtime version
- `autopilot.f`
  - framework version
- `autopilot.c`
  - contract version
- `autopilot.usr`
  - `UsrModel`
- `autopilot.user`
  - `UserModel`

Rules:

- readable from anywhere
- written only by `Autopilot`
- not part of normal mutable UX state
- not cleared by body/route/template resets
- not writable by action todos or ordinary UX patch operations

So the data/runtime split becomes:

- `Autopilot`
  - readonly global context
- `StateSet`
  - mutable UX/runtime state
- `DataSet`
  - mutable business/runtime data

## Layered Design

The data layer should be understood as 4 layers.

### 1. Runtime Dense Row Layer

Use the current `X` family from `lib/core/base/x.dart`:

- `X`
  - payload only
  - `v`
- `Xi`
  - `i + v`
- `Xia`
  - `i + a + v`
- `Xiad`
  - `i + a + d + v`
- `Xiade`
  - `i + a + d + e + v`

This stays the fast/runtime-friendly row format.

`v` is the hot-path ordered value array.  
The header fields are promoted only when needed.

### 2. Typed Model / DSchema Layer

The next experiment should keep the same typed-schema idea as the current
`lib/core/model/bschema` family.

Current model groups:

- schema source side
  - `Entity`
  - `Field`
  - `Relation`
  - `Function`
  - `Parameter`
- schema target side
  - `Table`
  - `Column`
  - `System`
  - `User`

For the experiment, if we rename or regroup this as `dschema`, the shape should
still follow the same rule:

- schema models are typed metadata objects
- runtime transport can still be projected to `X`
- persistence can still use compact row catalogs plus JSON payload

So `dschema` should be treated as an evolution of the current typed schema
layer, not a separate competing design.

### 3. Runtime Dataset Layer

`DataSet` stays the in-memory working set.

It is key/value oriented and currently supports:

- normal keyed values
- `x_row`
- slot addressing through `x_row.v.<index>`

That means the runtime can keep both:

- readable keyed access
- compact slot-based row updates

### 4. Persistence Layer

The current SQLite catalog row pattern remains valid:

- `catalog`
- `i`
- `a`
- `d`
- `e`
- `t`
- `n`
- `s`
- `payload`
- `updated_at`

This is the persisted authoring/storage envelope.

The compact fields stay first-class.  
Anything model-specific or still-evolving goes into `payload`.

## Shared Row Shape

The common metadata row shape remains:

- `i`
  - stable numeric id
- `a`
  - active flag
- `d`
  - datetime/version timestamp
- `e`
  - editor/user id
- `t`
  - numeric type code
- `n`
  - readable name
- `s`
  - system name

Extended reference fields remain allowed where they are already clearer than
overloading `t`:

- `fi`
  - function id
- `ci`
  - column id
- `ei`
  - entity id
- `tis`
  - related table ids

Rule: use dedicated reference fields when the meaning is relational.  
Use `t` only for actual type/category codes.

## ID Rule

The experiment should keep the current numeric id policy.

### Primary Ids

- all persisted primary ids are `int`
- ids must be stable once assigned
- no UUID/epoch/runtime-generated ids for persisted schema rows by default

### Draft Rule

- `i = 0` means draft / unsaved / transient authoring row
- on save, allocate the real id
- current SQLite behavior uses `nextRowId(catalog)` per catalog

### Reference Rule

- references are also numeric
- use dedicated fields such as `fi`, `ci`, `ei`, `tis`
- do not use Flutter widget keys or runtime instance keys as data ids

### Scope Rule

- persisted ids identify durable data/schema objects
- runtime scope ids are separate concerns
- UX instance identity must never replace durable data identity

## Data Type Rule

Keep the current datatype registry pattern from `lib/core/base/data_type.dart`.

Datatype ids are numeric-first.

### Base Types

- `0` = `bool`
- `1` = `Int32`
- `2` = `Int53`
- `3` = `Int64`
- `4` = `Double`
- `5` = `Binary`
- `6` = `Json`
- `7` = `Jsonb`
- `9` = `Guid`
- `10` = `String`
- `11` = `Base64`

### Numeric Expansion

Ids greater than `99` are interpreted as generated numeric precision/scale
types.

Current rule:

- `id ~/ 100` = whole digits
- `id % 100` = scale
- generated database type = `numeric(precision, scale)`

For now this rule should stay unchanged.

### Cross-Layer Meaning

Each datatype carries mappings for:

- Dart type
- PostgreSQL type
- SQLite type
- JSON transport shape

So datatype ids remain the canonical bridge between:

- typed schema
- DB schema
- runtime data
- transport encoding

## Recommended Boundaries

### What Should Stay Typed

- schema definitions
- entity/field/function metadata
- table/column/system/user metadata
- validation and authoring contracts

### What Should Stay Dense

- hot-path runtime rows
- compact transport payloads
- slot-based editing data

### What Should Stay in Payload JSON

- catalog-specific extension data
- incomplete experimental metadata
- low-frequency authoring extras

## What This Experiment Should Not Change

- `X` is still valid
- typed schema models are still valid
- catalog-row persistence is still valid
- numeric id policy is still valid
- datatype id mapping is still valid

## Working Direction

For the next UX experiment:

- keep the data layer conservative
- keep ids numeric
- keep typed metadata models
- keep `X` for runtime row transport
- let UX/navigation/runtime evolve on top of this

This gives us one stable baseline:

**data architecture stays familiar, UX architecture is where the experiment happens**

## AIWork UX Philosophy

The current `AIWork` UX direction is:

- route resolves to a `Paper` variant
- `Paper` is the largest UX host
- every `Template` must be hosted inside `Paper`
- `Template` composes `View` variants plus normal Flutter primitives
- `View` variants are the reusable primitive UX widgets

So the intended hierarchy is:

- Route
- `Paper`
- `Template`
- `View`

Important rules:

- no `Template` may exist above `Paper`
- no `View` should be route-root or page-root
- `i` on `Paper`, `Template`, and `View` is the spec id anchor
- `n` is the stable name
- `s` is style/layout selection, not mutable runtime state
- `Paper` owns the paper host lifecycle in `paper.dart`
- `Template` owns the template host lifecycle in `template.dart`
- `View` does not get an equivalent shared host unless a future view becomes a
  true scoped runtime owner

### Layout Rule

Layout should not become another visible lifecycle layer.

Current direction:

- layout is a logic engine/helper
- split behavior is the only custom layout logic worth abstracting right now
- normal `Row`, `Column`, `Container`, `Stack`, and tabs should use Flutter
  directly unless a real reusable logic rule appears

So the likely end direction is:

- keep `Paper`
- keep `Template`
- keep `View`
- reduce layout abstraction to split logic only, such as `Lsplit`

### Experimental Contract Rule

In the current experiment, `Paper`, `Template`, and `View` remain separate
contracts so we can discover which variables are truly common.

Likely final shared strategic variables:

- `i`
- `n`
- `s`

Possibly later:

- one common mixin/base contract for all UX layers
- optional metadata extension bag when the stable common fields are proven

Current experimental implementation direction:

- shared base contract is still useful, but its final home should follow
  responsibility:
  - model/schema pieces -> `core/model/uschema`
  - runtime/agent pieces -> `core/agent`
  - generator helpers -> `core/generator`
  - template implementations -> `core/template`
- the common node identity currently owns:
  - `i`
  - `n`
  - `s`
  - `m`
- structural registration currently builds ids such as:
  - paper id -> `pid`
  - template id -> `pid.tid`
  - view id -> `pid.tid.vid`
- structural registration also builds packed numeric structural codes using 3
  digits per
  tier:
  - paper code -> `pid * 1,000,000`
  - template code -> `pid * 1,000,000 + tid * 1,000`
  - view code -> `pid * 1,000,000 + tid * 1,000 + vid`

## UX Models And Specs

The UX side should stay formal and typed, but lighter than the old low-level
widget-model direction.

### Authoring Models

Recommended top-level authoring models:

- `UxPaperModel`
- `UxTemplateModel`
- `UxActionModel`

Optional:

- `UxRouteModel` only if routes themselves must be authored as durable catalog
  rows

`View` variants should not become heavy first-class authoring models unless we
later prove that need. In the current direction, views are better treated as
primitive nodes/configuration inside paper/template specs.

### Top-Level Specs

Recommended top-level specs:

- `UxPaperSpec`
- `UxTemplateSpec`
- `UxActionSpec`

Optional:

- `UxRouteSpec` or `UxNavSpec` if route contracts need their own formal schema

### UxPaperSpec Direction

`UxPaperSpec` should describe the route-root paper contract.

Recommended concerns:

- `pid`
- `i`
- `n`
- `s`
- hosted template references or inline template specs
- route/bootstrap hints if needed

Important rule:

- `Paper` hosts `Template`
- `Paper` is the route/root UX host

### UxTemplateSpec Direction

`UxTemplateSpec` should describe business workflow structure.

Recommended concerns:

- `tid`
- `i`
- `n`
- `s`
- toolbar regions
- collection/detail regions
- view node definitions
- action references
- binding references
- state defaults when needed

### UxActionSpec Direction

`UxActionSpec` stays the executable behavior contract:

- numeric id
- readable name
- todo/action steps
- optional guards/conditions later

### View Spec Direction

Views should stay lightweight.

Recommended direction:

- use a small inline view node shape inside paper/template specs
- identify view kind by `vid`
- keep `i`, `n`, `s`
- allow a compact configuration payload for view-specific details

This keeps `View` primitive without exploding the authoring catalog count.

## Runtime State Direction

The previous dark-hole problem was mostly a scope and lifecycle problem.

The current direction to avoid that problem is:

- `Autopilot` owns readonly global context directly
- `StateSet` stores mutable runtime UX state
- template/page runtime state must be stored by scope
- scope must be cleared as a whole on dispose/replacement

### State Ownership

- `Autopilot`
  - readonly global context such as `v`, `f`, `c`, `usr`, `user`
- `StateSet`
  - mutable route/page/template runtime state
- `DataSet`
  - mutable business data

### Template Scope Rule

Template runtime state should not be scattered into many unrelated top-level
keys.

Instead, keep one scoped object per template instance, conceptually like:

- `template.<paper_spec_id>.<template_spec_id>`

and store a `Map<String, dynamic>` inside that scope.

This is preferred over `List<Map<String, dynamic>>` for runtime state because:

- lookup is direct
- duplicates are avoided
- patching is simpler
- clearing on dispose is simpler

Complex values such as lists may still live inside the scoped map where needed.

### Dispose Rule

Destroy runtime state by clearing the whole scope, not field-by-field.

So on `Paper` or `Template` dispose/replacement:

- identify scope from `i`
- clear the entire scoped map in `StateSet`

This is the main protection against stale state leakage across screens or
template instances.

## Route Management Direction

Route management may be reshaped if that gives a safer and faster runtime.

Current direction:

- app home flow plus `Autopilot` owns route management
- route changes replace the active route
- there is no user-facing back stack requirement
- browser/history behavior is not a design target
- direct route entry is still useful for launcher shortcuts or incoming paths
- route is an address and lifecycle boundary, not another UX layer

### Route Shape

Recommended route shape:

- `/<appname>/<page_spec_id>/<optional_id>`

Examples:

- `aiwork/10001`
- `aiwork/10001/345`
- `aibook/20001`
- `aibook/20001/99`

Where:

- `appname` selects the app root such as `aiwork` or `aibook`
- `page_spec_id` selects the `UxPaperSpec.i`
- `optional_id` identifies the business working context when needed

This route shape should support direct app entry and internal route resolution.
It is not intended to model browser history or a retained navigation stack.

### Route Resolution Rule

On route resolution:

1. resolve the route request
2. resolve/fetch the target `UxPaperSpec`
3. resolve hosted `UxTemplateSpec` values
4. mount paper/template scopes in runtime state
5. render the `Paper`

On route replacement/dispose:

1. clear the current paper scope
2. clear all child template scopes
3. mount the next route scope

### Navigation Rule

- normal route changes replace the active route
- startup loading is temporary and is replaced by the resolved route
- there is no retained user-facing back stack to preserve
- direct route input is supported only as an entry path
- if a `Back` button appears inside a template, it is a local workflow control
  only
- local `Back` means return from inspect/edit/create to browse mode inside the
  same route
- local `Back` does not mean pop navigation history
- if richer history is needed later, that should be owned by the future Angular
  shell, not by the current Flutter runtime

### Why Route Is Not Another UX Layer

Route should stay outside the visual UX hierarchy.

So:

- route chooses the `Paper`
- `Paper` hosts `Template`
- `Template` hosts `View`

This prevents route concerns from leaking into template/view design and keeps
the lifecycle boundary explicit.

## Tcrud Analysis

`Tcrud` should be the focused CRUD aiwork template.

It is not just a form and not just a collection browser. It should keep the
common business CRUD workflow in one place:

- browse
- inspect
- create
- edit
- save/cancel/delete
- search/filter
- selection and bulk operations
- collection summary/footer information

### Tcrud Main Structure

Recommended structure:

1. primary toolbar
2. main body
3. footer info bar

Beta note:

- secondary toolbar is deferred
- if it exists later, it is optional and caller-driven
- beta keeps the primary toolbar and footer only

Recommended body:

- browse mode shows the collection only
- inspect/edit/create replace the collection body with the relevant view
- desktop split, if wanted, should come from `Ptwo` or `Pthree`, not from
  `Tcrud`

Recommended detail-region switching:

- browse with no selection -> stay in `collectionview`
- inspect -> `plistview`
- create/edit -> `fromview`
- error/conflict -> `alertview`

### Tcrud Toolbars

Recommended toolbar responsibilities:

- primary toolbar
  - CRUD actions
  - collection view switch
  - selection-aware actions
  - bulk edit when multi-selection is active
- secondary toolbar
  - search
  - filter
  - sort
  - optional later, not required for beta
- footer info bar
  - total result count
  - selected count
  - summary values and totals

There should not be a separate dedicated bulk toolbar in the first design.
Bulk actions should appear in the primary toolbar when selection state allows
them.

### Collection View Modes

`Tcrud` should support collection views through `collectionview`.

Current collection mode direction:

- list
- grid
- table

But `Tcrud` should not force all three for every case.

The API/developer may decide which modes are enabled for a screen.

### Selection Direction

Selection should be configurable:

- none
- single
- multi

Recommended default:

- single selection unless bulk actions are truly needed

Behavior direction:

- click selects and opens/refreshes `plistview`
- edit/new switches detail region to `fromview`
- long click may enter selection context on touch screens if needed

### PList And Edit View Rule

`plistview` should stay a text-only Microsoft-style property list / property
editor look, not a full inline editor.

`fromview` is the edit shell.

Important rule:

- form column count is a developer/API-user decision
- grid column count is a developer/API-user decision
- `Tcrud` should not impose those counts by ideology

### Tcrud State Needs

Recommended runtime state groups:

- workflow
  - browse/create/edit
  - collection view mode
  - selection mode
- selection
  - active id
  - selected ids
- query
  - search text
  - filters
  - sort
  - paging
- status
  - loading
  - saving
  - dirty
  - error
- summary
  - total count
  - selected count
  - totals/aggregates

These should live inside a scoped runtime map owned by `Autopilot`, not as
free-floating global UX keys.

## Implementation Plan

### Phase 1: Freeze The UX Rules

1. keep `Paper` as the required host for every `Template`
2. keep `Template` as business workflow layer
3. keep `View` as primitive reusable widget layer
4. keep layout abstraction limited to split logic only
5. treat `i` as the spec id anchor for scope and identity

### Phase 2: Add Scoped StateSet Helpers

Implement scoped runtime helpers in `Autopilot` / `StateSet` such as:

- set template scope
- read template scope
- patch template scope
- clear template scope

Target behavior:

- one scoped runtime map per `Paper`/`Template`
- clear the whole scope on dispose or route replacement

### Phase 3: Stabilize The CRUD Views

Before `Tcrud`, keep these primitive views stable:

- `toolbarview`
- `collectionview`
- `plistview`
- `fromview`
- `emptyview`
- `alertview`

This means:

- toolbar modes are documented and bounded
- collection view switching is bounded
- plist remains text-only
- form/grid column count remains caller-driven

### Phase 4: Implement Minimal Tcrud

Build the first real `Tcrud` with:

1. primary toolbar
2. single active body region
3. footer info bar

Recommended first detail switching:

- browse collection
- plist
- form
- alert

No advanced nested subflows in the first version.

Current beta slice:

- collection row/item click selects one record
- selection moves the template into local `inspect` mode
- selection updates scoped template state
- inspect derives its property list from the active row
- `New`, `Inspect`, `Edit`, and `Clear` are driven from the primary toolbar
- the left primary button cycles view modes in browse and becomes `Back` in
  inspect/edit/create
- footer shows result count plus active/selected summary

### Phase 5: Connect Runtime State

Wire `Tcrud` to scoped runtime state for:

- mode
- selection
- collection view mode
- search/filter state
- summary values

Do not store this as one blind global blob.
Store it in a template scope derived from the hosting `Paper` and `Template`
spec ids.

### Phase 6: Paper Integration

Integrate `Tcrud` only through `Paper` variants.

That means:

- route resolves a `Paper`
- `Paper` hosts the `Tcrud`
- no direct route-to-template shortcut

### Phase 7: Refine After First Working Slice

After the first working CRUD slice:

- refine `plistview` appearance
- refine summary/footer behavior
- decide whether search/filter state belongs in one toolbar or collapses on
  narrow layouts
- decide whether long-click behavior is worth standardizing

The goal is to prove one clean CRUD flow first, then generalize carefully.

## Current Status

The repo is already operating on the new-experiment direction:

- `AIWork`, `AIBook`, `AICodex`, and `AIStudio` are active app surfaces
- `MainApp` launches those app shells from one chooser
- the old document-driven runtime path is removed
- `Paper -> Template -> View` is the live composition rule
- route/runtime state lives under `core/agent`
- schema/spec state for this flow lives under `core/model/uschema`
- template implementation lives under `core/template`

What that means in practice:

- a small multi-app launcher is back
- no `AutopilotGo` path
- no old body-switch runtime kept alive beside the current app-shell flow

## Remaining Cleanup

The architecture is now in the consolidation phase, not the migration phase.

Main cleanup targets:

1. normalize active naming inside `core/agent` and `core/model/uschema`
2. remove any leftover parallel files that are no longer read by the active
   app shells
3. keep tests focused on the active app runtime and the stable data
   layer
4. only add new features through the route-first app-shell path
5. avoid rebuilding generic staging layers unless the active app truly needs
   them

## Migration Guardrails

To keep the migration clean:

- no backward compatibility shims
- no dual-write state logic
- no reintroduction of removed runtime paths
- no route/body hybrid model
- no preserving old abstractions only because they already exist
- no “temporary” adapter layers unless they unblock a specific short migration
  step

## Definition Of Current Success

The current direction is healthy when:

1. new UX/runtime work happens only in the corrected original structure under
   `core/*`
2. `AIWork` proves the main route/paper/template/view flow
3. scoped paper/template lifecycle fully replaces old body-switch state logic
4. the active app path stays small enough to understand and extend
5. new templates and views can be added without reviving removed legacy layers

Current snapshot note:

- the merge is already done
- the active runtime has already been manually tested
- the current phase is cleanup, hardening, and data hookup
- seeded/demo `*_specs.dart` data is still acceptable until ID-key rules are discussed
- checked-in Dart test files are deleted in this snapshot, so analyzer plus manual app testing are the active checks
- the next work is not "should we merge?" but "how do we simplify and extend the merged runtime safely?"

## Beta Test Plan

The first merge checkpoint has already happened.

This section now serves as a continuing hardening/validation checklist for the
merged runtime rather than a go/no-go pre-merge beta gate.

### Validation Goal

Prove these things together:

- `Paper -> Template -> View` hierarchy is stable
- route replacement is predictable
- scoped runtime state is cleaned correctly on dispose
- packed structural UX codes are practical and safe
- the first `Tcrud` slice is usable for real CRUD workflows

### Current Entry Status

The merged snapshot already has the minimum shape needed to keep validating the
runtime. Continue using these as health checks:

1. `Paper`, `Template`, and `View` contracts are stable enough for internal use
2. route resolution works with `/<appname>/<page_spec_id>/<optional_id>`
3. `Autopilot` can mount and clear scoped runtime state
4. packed structural code helpers exist and are tested
5. one working `Tcrud` slice exists
6. `toolbarview`, `collectionview`, `plistview`, `fromview`, `tabview`, and
   `emptyview` are stable enough to demo without obvious breakage

### Validation Areas

#### 1. Route And Lifecycle

Test:

- route replacement
- direct entry to route
- loading page replacement
- page switch from menu
- page switch while current page has selection or dirty runtime state

Expected result:

- old route scopes are fully cleared
- new route scopes are mounted correctly
- no stale toolbar/selection/query state leaks into the next route

#### 2. Packed UX Code

Test:

- `paperCode`
- `templateCode`
- `viewCode`
- `decodeCode`
- invalid tier values

Expected result:

- no collision within allowed ranges
- encode/decode stays reversible
- values stay safe for Flutter Web integer handling

#### 3. Scoped StateSet Cleanup

Test:

- create route scope
- create template scope
- patch state values
- replace route
- clear paper scope
- clear template scope only

Expected result:

- scope clear removes the full map
- unrelated scopes survive
- repeated open/close cycles do not accumulate stale state

#### 4. Toolbar Behavior

Test current toolbar modes:

- default justify
- left / right
- scroll left / scroll right
- 2-group outer
- 2-group center-facing
- 3-group

Expected result:

- no overflow surprises in common widths
- grouping logic stays predictable
- scroll modes remain usable on narrow screens

#### 5. Collection Behavior

Test:

- list mode
- grid mode
- table mode
- switching among modes
- empty collection
- developer-driven grid column count

Expected result:

- mode switching is clean
- caller-owned layout settings remain respected
- no template-level hardcoded opinion overrides caller choice

#### 6. Tcrud Workflow

Test:

- browse with no selection -> `collectionview`
- single selection -> local `inspect` -> `plistview`
- edit/new -> `fromview`
- error state -> `alertview`
- primary toolbar actions
- primary view-switch/back behavior
- footer summary updates
- single-select and multi-select cases
- bulk edit appearance in primary toolbar

Expected result:

- detail region switches correctly
- selection state is reflected correctly in toolbars and footer
- CRUD flow feels coherent in one aiwork

### Validation Style

Use a small internal beta first:

- developer self-test
- one or two internal users who understand the old system
- one CRUD-heavy workflow only at first

Do not spread beta across many templates immediately.
Start with the strongest single slice and learn from it.

### Validation Metrics

Track at least:

- route replacement failures
- stale state leakage cases
- wrong selection state cases
- wrong active-body switching cases
- packed-code collision or decode failures
- toolbar mode layout regressions
- CRUD completion success for the chosen beta workflow

### Validation Exit Criteria

This merged checkpoint can be considered healthy when:

1. no critical stale-state bug remains open
2. no packed-code collision issue is found in real usage
3. route replacement works reliably
4. one `Tcrud` workflow can be completed end-to-end by internal users
5. toolbar, collection, plist, and form interaction feel stable enough to
   continue building on

### Beta Non-Goals

Beta does not need to prove everything at once.

Not required for first beta:

- all template families
- full deep-link productization
- final visual polish
- every responsive edge case
- perfect metadata/schema generalization

The first beta should prove that the architecture is sound, not that the whole
product is finished.
