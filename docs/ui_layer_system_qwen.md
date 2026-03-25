# UI Layer System — Page Removal & Template Reshape

**Status:** Proposed Architecture Change (Revised per Codex Analysis)
**Date:** 2026-03-25
**Author:** Qwen Code Analysis
**Impact:** High — affects all UX specs, templates, and rendering pipeline

---

## Executive Summary

**Recommendation:** Remove the **Page (Paper) layer** in a controlled, phased approach. Reshape **Templates** to own full-page experiences with an expanded zone system **as a separate follow-up phase**.

**Rationale:** The Page layer adds architectural complexity without meaningful functionality. However, Codex analysis correctly identifies that paper is not just a visual wrapper—it is a **state anchor**, **identity anchor**, and **cache anchor**. Removing it requires careful migration of route identity, state scoping, and compiled-cache behavior.

**Key Changes (Phase 1-4):**
1. Make root templates first-class runtime surfaces (without deleting paper yet)
2. Migrate AIWork/AIBook to direct root templates while preserving `pageSpecId`
3. Remove paper runtime ownership after migration complete
4. Clean registries and compatibility shims

**Key Changes (Phase 5+):**
5. Add new zone constants (menubar, panel, sidebar, etc.)
6. Reshape templates to own scroll/layout behavior and multi-panel content
7. Expand zone system for richer layouts

**Risk Level:** **High** if done as one big change (Codex warning). **Medium** if done in controlled phases (recommended).

**Critical Decisions:**
- ✅ **Yes** to removing `UxLayer.paper`
- ✅ **Yes** to flattening `route → template`
- ✅ **Yes** to keeping `pageSpecId` for route identity (do NOT change URLs)
- ✅ **Yes** to using route-owned root template IDs (not shared inner template IDs)
- ❌ **No** to coupling paper removal with full menubar/panel/sidebar redesign in one patch
- ❌ **No** to pushing layout keys into `UxWorkspaceMeta` (use separate `frame` metadata)
- ❌ **No** to treating `panel` as flat widget lists (needs explicit grouping)

---

## Current Architecture (Before)

### 3-Layer Stack

```
┌─────────────────────────────────────────┐
│ Route (UxRouteSpec)                     │
├─────────────────────────────────────────┤
│ Paper (UxLayer.paper = 2)               │ ← Remove this layer
│   - pzero, pone, ptwo, pthree, pfour    │
│   - Provides scroll hosts               │
│   - Manages paper-scoped state          │
│   - No business logic                   │
├─────────────────────────────────────────┤
│ Template (UxLayer.template = 3)         │ ← Expand this layer
│   - tworkspace, tsheet, treport, etc.   │
│   - Business logic & state management   │
│   - UI orchestration                    │
├─────────────────────────────────────────┤
│ UWidget (UxLayer.uwidget = 4)           │
│   - toolbar, form, collection, etc.     │
│   - Atomic UI components                │
└─────────────────────────────────────────┘
```

### Current Zone System

```dart
class UxZone {
  static const String app = 'app';
  static const String content = 'content';
  static const String header = 'header';
  static const String collection = 'collection';
  static const String detail = 'detail';
  static const String feedback = 'feedback';
  static const String footer = 'footer';
}
```

**Limitations:**
- Workspace-centric (designed for `tworkspace` only)
- No support for multi-panel layouts
- No menubar/tab navigation pattern
- No sidebar patterns

### Current Spec Structure

```dart
UxRouteSpec(
  app: appSpec,
  route: routeHeader,
  spec: UxSpec.paper(           // ← Paper wrapper
    i: 10001,
    n: 'paperzero',
    t: 0,
    uxzones: <String, List<UxSpec>>{
      UxZone.content: <UxSpec>[
        UxSpec.template(         // ← Actual content
          i: 20001,
          n: 'tworkspace',
          t: 1,
          uxzones: <String, List<UxSpec>>{
            UxZone.header: [...],
            UxZone.collection: [...],
            UxZone.detail: [...],
            UxZone.footer: [...],
          },
        ),
      ],
    },
  ),
)
```

**Problem:** Paper is a redundant wrapper. It adds:
- Extra nesting level
- Separate state scope (`UxPaperHost`)
- 5 additional files to maintain
- No unique functionality

---

## Proposed Architecture (After)

### 2-Layer Stack

```
┌─────────────────────────────────────────┐
│ Route (UxRouteSpec)                     │
├─────────────────────────────────────────┤
│ Template (UxLayer.template = 3)         │ ← Owns full-page experience
│   - tworkspace, tsheet, treport, etc.   │
│   - Scroll/layout behavior              │
│   - Business logic & state management   │
│   - Multi-panel content                 │
├─────────────────────────────────────────┤
│ UWidget (UxLayer.uwidget = 4)           │
│   - toolbar, form, collection, etc.     │
│   - Atomic UI components                │
└─────────────────────────────────────────┘
```

### Expanded Zone System

```dart
class UxZone {
  UxZone._();

  // Root zones
  static const String app = 'app';
  static const String content = 'content';

  // Navigation zones (NEW)
  static const String menubar = 'menubar';    // Tab-like menubar
  static const String sidebar = 'sidebar';    // Left navigation panel

  // Content panel zones (NEW)
  static const String panel = 'panel';        // Generic content panel (IndexedStack children)
  static const String workspace = 'workspace'; // Main work area
  static const String inspector = 'inspector'; // Right-side inspector panel

  // Existing zones (retained for backward compatibility)
  static const String header = 'header';
  static const String collection = 'collection';
  static const String detail = 'detail';
  static const String feedback = 'feedback';
  static const String footer = 'footer';
}
```

**New Patterns Enabled:**
1. **Menubar Tab Control** — menubar switches between panel children
2. **Sidebar Navigation** — persistent left nav with main content area
3. **Inspector Panel** — collapsible right-side detail view
4. **Multi-Panel Layouts** — `IndexedStack` of panels controlled by menubar

### New Spec Structure (Target After All Phases)

```dart
UxRouteSpec(
  app: appSpec,
  route: routeHeader,
  spec: UxSpec.template(      // ← Direct template (no paper wrapper)
    i: route.pageSpecId,      // ← CRITICAL: keep route-owned ID, not shared template ID
    n: 'tworkspace',
    t: 1,
    m: <String, dynamic>{
      // Frame metadata (NEW - separate from business meta)
      'frame': <String, dynamic>{
        'scroll': 'vertical',  // 'none' | 'vertical' | 'horizontal'
        'sidebarWidth': 280,
        'inspectorWidth': 320,
      },
      // Business metadata (existing UxWorkspaceMeta)
      'collectionTitle': 'Accounts',
      'collectionColumns': ['ID', 'Name', 'Status'],
      // ... other workspace meta
    },
    uxzones: <String, List<UxSpec>>{
      UxZone.menubar: <UxSpec>[
        UxSpec.uwidget(i: 1, n: 'toolbar', t: 4, m: {'style': 'menubar'}),
      ],
      UxZone.header: <UxSpec>[
        UxSpec.uwidget(i: 2, n: 'toolbar', t: 4),
      ],
      // Panel grouping: each panel is a nested node, not flat widget list
      UxZone.panel: <UxSpec>[
        // Panel 0: Collection view (single node)
        UxSpec.uwidget(i: 10, n: 'collection', t: 12),
        // Panel 1: Details view (nested container with multiple widgets)
        UxSpec.template(        // ← nested template as panel container
          i: 20010,
          n: 'tform',
          t: 6,
          uxzones: <String, List<UxSpec>>{
            UxZone.content: <UxSpec>[
              UxSpec.uwidget(i: 1, n: 'plist', t: 6),
              UxSpec.uwidget(i: 2, n: 'form', t: 5),
            ],
          },
        ),
      ],
      UxZone.footer: <UxSpec>[
        UxSpec.uwidget(i: 3, n: 'toolbar', t: 4),
      ],
    },
  ),
)
```

**Key Differences from Initial Proposal:**

1. **Root `i` = `route.pageSpecId`** — preserves route identity and cache key (not shared template ID like `20001`)
2. **Separate `frame` metadata** — layout concerns separate from business metadata (`UxWorkspaceMeta`)
3. **Panel grouping explicit** — each panel is a nested node, not flat widget list
4. **Menubar source of truth** — menubar items from zone specs, not duplicated in metadata

---

## Technical Design

### Critical Reality Check (from Codex Analysis)

**Paper is not just a visual wrapper.** It currently participates in:

1. **State scope mounting** — `UxPaperHost` manages paper-scoped state, `CopilotUx` mounts template scope through `currentPaperI`
2. **Route identity** — paths are `/<app>/<pageSpecId>/<optionalId?>`, scope keys are `<app>.<pageSpecId>.<optionalId?>`
3. **Compiled cache identity** — cache keyed by `spec.i`, root spec today is paper
4. **Render dispatch** — `GenUx.build()` dispatches to `_buildCompiledPaper()`
5. **Register/code lookups** — `UxLayer.paper` in enum, `UxRegister.papers` map

**Only `paperzero` and `paperone` are actually used** by AIWork and AIBook today. This makes migration practical.

**Cache collision risk:** If we flatten to root templates using shared inner template IDs (e.g., `20001`), multiple routes could share the same cache key. This breaks cache freshness checks.

**Solution:** Keep root spec `i = route.pageSpecId` (unique per route), not shared template IDs.

---

### Phase 1: Make Root Templates Legal (Without Deleting Paper)

**Goal:** Teach runtime to mount templates without `currentPaperI`, while keeping paper functional for existing specs.

#### 1.1 Update `CopilotUx` to Support Root Template Scope

**Current behavior:**
```dart
// CopilotUx.mountCurrentTemplate() requires currentPaperI
final paperI = state.currentPaperI;
if (paperI == null) throw StateError('No active paper');
```

**New behavior:**
```dart
// Support both paper-rooted and template-rooted mounting
String mountRootTemplate({
  required int templateI,
  required Autopilot autopilot,
  Map<String, dynamic> initialState = const <String, dynamic>{},
}) {
  // Route-rooted scope (no paper dependency)
  final route = autopilot.currentRoute;
  if (route == null) throw StateError('No active route');

  final scope = 'route.${route.scopeKey}.template.$templateI';
  autopilot.state.mountTemplateScope(scope, initialState: initialState);
  return scope;
}
```

#### 1.2 Update `GenUx.build()` to Handle Both Paper Roots and Template Roots

**New dispatch logic:**
```dart
static Widget build({
  required UschemaCompiled compiled,
  required Autopilot autopilot,
  String? optionalId,
}) {
  return switch (compiled.layer) {
    // Legacy: paper-rooted spec (still supported)
    UxLayer.paper =>
      _buildCompiledPaper(compiled: compiled, autopilot: autopilot, optionalId: optionalId),

    // New: template-rooted spec (direct route → template)
    UxLayer.template when compiled.isRoot => _buildCompiledRootTemplate(
      compiled: compiled,
      autopilot: autopilot,
      optionalId: optionalId,
    ),

    // Nested template inside paper or other container
    UxLayer.template => _buildCompiledTemplate(
      compiled: compiled,
      autopilot: autopilot,
      optionalId: optionalId,
    ),

    _ => const SizedBox.shrink(),
  };
}

static bool get isRoot => m['frame'] != null || s['isRoot'] == true;
```

#### 1.3 Add Frame Metadata Support

**New `UxFrameMeta` class** (separate from `UxWorkspaceMeta`):

```dart
class UxFrameMeta {
  const UxFrameMeta({
    this.scroll = 'none',
    this.sidebarWidth = 280,
    this.inspectorWidth = 320,
    this.inspectorCollapsed = false,
    this.menubarStyle = 'tabs',  // 'tabs' | 'dropdown' | 'none'
  });

  final String scroll;  // 'none' | 'vertical' | 'horizontal'
  final double sidebarWidth;
  final double inspectorWidth;
  final bool inspectorCollapsed;
  final String menubarStyle;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'scroll': scroll,
    'sidebarWidth': sidebarWidth,
    'inspectorWidth': inspectorWidth,
    'inspectorCollapsed': inspectorCollapsed,
    'menubarStyle': menubarStyle,
  };

  factory UxFrameMeta.fromJson(Map<String, dynamic> json) {
    return UxFrameMeta(
      scroll: json['scroll'] as String? ?? 'none',
      sidebarWidth: (json['sidebarWidth'] as num?)?.toDouble() ?? 280,
      inspectorWidth: (json['inspectorWidth'] as num?)?.toDouble() ?? 320,
      inspectorCollapsed: json['inspectorCollapsed'] as bool? ?? false,
      menubarStyle: json['menubarStyle'] as String? ?? 'tabs',
    );
  }
}
```

**Usage in spec:**
```dart
UxSpec.template(
  i: route.pageSpecId,  // ← Route-owned ID
  n: 'tworkspace',
  t: 1,
  m: <String, dynamic>{
    'frame': UxFrameMeta(scroll: 'vertical').toJson(),
    // ... UxWorkspaceMeta fields stay separate
  },
)
```

#### 1.4 Deliverable

- ✅ `CopilotUx` can mount template scope without paper
- ✅ `GenUx.build()` handles both paper-rooted and template-rooted specs
- ✅ `UxFrameMeta` class for layout metadata
- ✅ Paper layer still functional (not deleted yet)

---

### Phase 2: Migrate AIWork and AIBook to Direct Root Templates

**Goal:** Replace root `UxSpec.paper` with root `UxSpec.template` while preserving route identity.

#### 2.1 Migration Pattern

**Before (AIWork):**
```dart
spec: UxSpec.paper(
  i: route.pageSpecId,  // e.g., 10001
  n: pid == 0 ? 'paperzero' : 'paperone',
  t: pid,  // 0 or 1
  m: const <String, dynamic>{},
  s: const <String, dynamic>{},
  uxzones: <String, List<UxSpec>>{
    UxZone.content: <UxSpec>[
      UxSpec.template(
        i: 20001,  // ← Inner template ID (shared across routes!)
        n: 'tworkspace',
        t: 1,
        m: UxWorkspaceMeta(...).toJson(),
        uxzones: [...],
      ),
    ],
  },
),
```

**After (AIWork):**
```dart
spec: UxSpec.template(
  i: route.pageSpecId,  // ← Keep 10001 (route-owned, unique)
  n: 'tworkspace',
  t: 1,  // ← Template type
  m: <String, dynamic>{
    'frame': UxFrameMeta(
      scroll: pid == 0 ? 'none' : 'vertical',  // ← Inline paper's scroll behavior
    ).toJson(),
    // ... UxWorkspaceMeta fields
  }.addAll(UxWorkspaceMeta(...).toJson()),
  uxzones: <String, List<UxSpec>>{
    UxZone.header: [...],
    UxZone.collection: [...],
    UxZone.detail: [...],
    UxZone.feedback: [...],
    UxZone.footer: [...],
  },
),
```

**Key Points:**
- Root `i` stays `route.pageSpecId` (10001, 10002, etc.) — preserves cache identity
- Root `n` becomes template name (`tworkspace`)
- Root `t` becomes template type (1)
- Paper's scroll behavior moves to `frame.scroll`
- Inner template ID (`20001`) is NOT used as root ID (avoids cache collision)

#### 2.2 Route Identity Preserved

**Route paths stay unchanged:**
- `/aiwork/10001/42` — still works
- `/aiwork/10002/42` — still works
- `/aiwork/10002/84` — still works

**Route scope keys stay unchanged:**
- `aiwork.10001.42`
- `aiwork.10002.42`

#### 2.3 Deliverable

- ✅ AIWork specs migrated to root templates
- ✅ AIBook specs migrated to root templates
- ✅ Route paths and scope keys unchanged
- ✅ Cache identity preserved (no collision risk)
- ✅ Both apps tested manually

---

## Migration Plan (Revised per Codex Analysis)

### Phase 1: Make Root Templates Legal (2-3 days)

**Goal:** Runtime plumbing — support template-rooted specs without breaking paper-rooted specs.

**Tasks:**
1. ⬜ Add `UxFrameMeta` class to `lib/core/model/uschema/ux_spec.dart`
2. ⬜ Update `CopilotUx.mountCurrentTemplate()` to support root template mounting
3. ⬜ Add `mountRootTemplate()` method for route-rooted template scope
4. ⬜ Update `GenUx.build()` with `isRoot` check for dual dispatch
5. ⬜ Add `_buildCompiledRootTemplate()` method (inline paper's layout logic)
6. ⬜ Keep paper files functional (not deleted yet)

**Deliverable:** Runtime supports both paper-rooted and template-rooted specs

---

### Phase 2: Migrate AIBook to Root Templates (1-2 days)

**Goal:** Prove migration pattern on simpler app (AIBook has fewer routes).

**Tasks:**
1. ⬜ Update `aibook_specs.dart` — replace `UxSpec.paper` with `UxSpec.template`
2. ⬜ Keep `i = route.pageSpecId` (20001, 20002)
3. ⬜ Add `frame.scroll` metadata (migrate paper's scroll behavior)
4. ⬜ Keep `paperZeroSpecId` / `paperOneSpecId` constants (deprecated but functional)
5. ⬜ Test manually: `flutter run -t lib/main_aibook.dart`
6. ⬜ Verify routes: `/aibook/20001/42`, `/aibook/20002/42`

**Deliverable:** AIBook works with root templates, paper layer still functional for AIWork

---

### Phase 3: Migrate AIWork to Root Templates (1-2 days)

**Goal:** Complete spec migration.

**Tasks:**
1. ⬜ Update `aiwork_specs.dart` — replace `UxSpec.paper` with `UxSpec.template`
2. ⬜ Keep `i = route.pageSpecId` (10001, 10002)
3. ⬜ Add `frame.scroll` metadata
4. ⬜ Test manually: `flutter run -t lib/main_aiwork.dart`
5. ⬜ Verify routes: `/aiwork/10001/42`, `/aiwork/10002/42`, `/aiwork/10002/84`

**Deliverable:** Both apps work with root templates, no paper-rooted specs remain

---

### Phase 4: Remove Paper Runtime Ownership (1-2 days)

**Goal:** Clean up paper layer after all specs migrated.

**Tasks:**
1. ⬜ Delete paper files (`pzero.dart` → `pfour.dart`)
2. ⬜ Remove `UxPaperHost` class
3. ⬜ Remove `_buildCompiledPaper()` from `GenUx`
4. ⬜ Remove `currentPaperI` dependency from `CopilotUx`
5. ⬜ Deprecate `UwStateSource.paper` (keep for backward compatibility)
6. ⬜ Update `UxLayer` enum — keep `paper(2)` for historical parsing, mark deprecated
7. ⬜ Clear `UxRegister.papers` map (or mark deprecated)
8. ⬜ Run `flutter analyze lib`

**Deliverable:** Paper layer completely removed from runtime

---

### Phase 5: Add Zone Rendering Contract (2-3 days)

**Goal:** Enable richer zone-based layouts (menubar, panel, sidebar, etc.).

**Prerequisite:** This phase requires real child-zone rendering, not just zone constants.

**Tasks:**
1. ⬜ Add `renderZone(String zone)` callback to templates
2. ⬜ Or pass `Map<String, List<Widget>>` zone children to templates
3. ⬜ Update `Tworkspace` to use zone rendering instead of hardcoded slots
4. ⬜ Prototype menubar tab control in `Tworkspace` only
5. ⬜ Define panel grouping semantics (nested template containers)
6. ⬜ Test menubar switching between panels

**Deliverable:** Working menubar tab control pattern in `Tworkspace`

---

### Phase 6: Expand Zone System (future, after Phase 5 proven)

**Goal:** Add new zone constants and patterns.

**Tasks:**
1. ⬜ Add new zone constants to `UxZone` class
2. ⬜ Add `sidebar` zone support to `Tworkspace`
3. ⬜ Add `inspector` zone (collapsible right panel)
4. ⬜ Create `Tdashboard` template with multi-panel layout
5. ⬜ Document menubar/panel/sidebar patterns

**Deliverable:** Rich zone system with multiple layout patterns

---

## Impact Assessment (Revised)

### Files Affected

| Category | Count | Files |
|---|---|---|
| **Paper files to delete (Phase 4)** | 5 | `pzero.dart` → `pfour.dart` |
| **Templates to update (Phase 1, 5)** | 1 (initially) | `tworkspace.dart` only (prove pattern first) |
| **Specs to migrate (Phase 2-3)** | 2 | `aiwork_specs.dart`, `aibook_specs.dart` |
| **Renderer updates (Phase 1)** | 1 | `genux.dart` |
| **Mixins updates (Phase 1)** | 1 | `mixins.dart` (add `UxFrameMeta`) |
| **Copilot updates (Phase 1)** | 1 | `copilot_ux.dart` |
| **State set updates (Phase 4)** | 1 | `state_set.dart` (deprecate paper scope) |
| **Total** | 12 | |

### Code Changes

| Metric | Estimate |
|---|---|
| Lines to add (Phase 1: `UxFrameMeta`, dual dispatch) | ~150 LOC |
| Lines to add (Phase 5: zone rendering) | ~200 LOC |
| Lines to modify (Phase 2-3: specs) | ~100 LOC |
| Lines to remove (Phase 4: paper files) | ~300 LOC |
| **Net change** | **-50 LOC** (simpler codebase after all phases) |

### Risk Analysis (per Codex Warning)

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Cache collision (shared template IDs)** | High if using inner IDs | **Critical** | Use `route.pageSpecId` as root ID (unique per route) |
| **Route identity broken** | High if changing paths | **Critical** | Keep `pageSpecId`, preserve URLs like `/aiwork/10001/42` |
| **Template scope mounting fails** | Medium | High | Add `mountRootTemplate()` before deleting paper scope |
| **Breaking existing specs** | Medium | Medium | Dual dispatch supports both paper-rooted and template-rooted |
| **Zone rendering not flexible enough** | Medium | Medium | Prototype in `Tworkspace` only, prove pattern before expanding |
| **Panel grouping ambiguous** | Medium | Low | Use nested template containers, not flat widget lists |
| **Menubar metadata duplication** | Medium | Low | Choose one source of truth (zone specs, not metadata) |
| **`UxWorkspaceMeta` becomes dumping ground** | High | Low | Separate `UxFrameMeta` for layout concerns |
| **Template files become large** | Medium | Low | Extract helper methods, use sub-widgets |

### Benefits

| Benefit | Description |
|---|---|
| **Simpler architecture** | 2 layers instead of 3, clearer ownership |
| **Fewer files** | Remove 5 paper files after migration |
| **Richer layouts** | Zone rendering enables menubar, sidebar, inspector patterns |
| **Better performance** | One less state scope, one less widget layer |
| **Easier onboarding** | Fewer concepts to learn (no paper vs template confusion) |
| **Safer migration** | Phased approach with rollback path at each phase |

---

## Design Patterns (Target After Phase 5+)

### Pattern 1: Menubar Tab Control

**Use Case:** Desktop-style app with menubar switching content panels

**Spec Structure:**
```dart
UxSpec.template(
  i: 10001,  // ← Route-owned ID (unique per route)
  n: 'tworkspace',
  t: 1,
  m: <String, dynamic>{
    'frame': UxFrameMeta(scroll: 'none').toJson(),
    // ... business metadata
  },
  uxzones: <String, List<UxSpec>>{
    // Menubar defines tab items (source of truth)
    UxZone.menubar: <UxSpec>[
      UxSpec.uwidget(i: 1, n: 'toolbar', t: 4, m: {'label': 'Collection'}),
      UxSpec.uwidget(i: 2, n: 'toolbar', t: 4, m: {'label': 'Details'}),
      UxSpec.uwidget(i: 3, n: 'toolbar', t: 4, m: {'label': 'Settings'}),
    ],
    // Each panel is a nested node (not flat widget list)
    UxZone.panel: <UxSpec>[
      // Panel 0: Collection
      UxSpec.uwidget(i: 10, n: 'collection', t: 12),
      // Panel 1: Details (nested container with multiple widgets)
      UxSpec.template(
        i: 10010,  // ← Unique nested ID
        n: 'tform',
        t: 6,
        uxzones: <String, List<UxSpec>>{
          UxZone.content: <UxSpec>[
            UxSpec.uwidget(i: 1, n: 'plist', t: 6),
            UxSpec.uwidget(i: 2, n: 'form', t: 5),
          ],
        },
      ),
      // Panel 2: Settings
      UxSpec.uwidget(i: 14, n: 'form', t: 5),
    ],
  },
)
```

**Template State:**
- `activePanel: int` — controlled by menubar selection
- Menubar taps update `activePanel`
- `IndexedStack` renders only active panel

**Key Design Decisions:**
- ✅ Menubar items from zone specs (not duplicated in metadata)
- ✅ Panel grouping explicit (nested template containers)
- ✅ Each panel has unique ID (for state scoping if needed)

---

### Pattern 2: Sidebar Navigation

**Use Case:** Master-detail with persistent left nav

**Spec Structure:**
```dart
UxSpec.template(
  i: 10002,
  n: 'tworkspace',
  t: 1,
  m: <String, dynamic>{
    'frame': UxFrameMeta(
      scroll: 'none',
      sidebarWidth: 280,
    ).toJson(),
    // ... business metadata
  },
  uxzones: <String, List<UxSpec>>{
    UxZone.sidebar: <UxSpec>[
      UxSpec.uwidget(i: 1, n: 'list', t: 1),
    ],
    UxZone.workspace: <UxSpec>[
      UxSpec.uwidget(i: 10, n: 'collection', t: 12),
    ],
  },
)
```

**Template Layout:**
```dart
Row(
  children: <Widget>[
    SizedBox(
      width: frame.sidebarWidth,
      child: renderZone(UxZone.sidebar),
    ),
    Expanded(child: renderZone(UxZone.workspace)),
  ],
)
```

---

### Pattern 3: Inspector Panel

**Use Case:** Right-side property inspector (collapsible)

**Spec Structure:**
```dart
UxSpec.template(
  i: 10003,
  n: 'tworkspace',
  t: 1,
  m: <String, dynamic>{
    'frame': UxFrameMeta(
      scroll: 'none',
      inspectorWidth: 320,
      inspectorCollapsed: false,
    ).toJson(),
  },
  uxzones: <String, List<UxSpec>>{
    UxZone.workspace: <UxSpec>[
      UxSpec.uwidget(i: 10, n: 'collection', t: 12),
    ],
    UxZone.inspector: <UxSpec>[
      UxSpec.uwidget(i: 20, n: 'form', t: 5),
    ],
  },
)
```

**Template Layout:**
```dart
Row(
  children: <Widget>[
    Expanded(child: renderZone(UxZone.workspace)),
    AnimatedContainer(
      width: frame.inspectorCollapsed ? 48 : frame.inspectorWidth,
      child: renderZone(UxZone.inspector),
    ),
  ],
)
```

---

## Testing Strategy (Revised)

### Manual Testing Checklist

**Phase 1 (Runtime Plumbing):**
- [ ] Paper-rooted specs still render correctly (AIWork, AIBook)
- [ ] Template-rooted test spec renders correctly
- [ ] Route scope keys unchanged
- [ ] State persistence works in both modes

**Phase 2 (AIBook Migration):**
- [ ] Route `/aibook/20001/42` loads without errors
- [ ] Route `/aibook/20002/42` loads without errors
- [ ] Collection view displays correctly
- [ ] Detail view (plist/form) displays correctly
- [ ] Scroll behavior matches paper's old behavior
- [ ] State persistence works (selection, mode, etc.)

**Phase 3 (AIWork Migration):**
- [ ] Route `/aiwork/10001/42` loads without errors
- [ ] Route `/aiwork/10002/42` loads without errors
- [ ] Route `/aiwork/10002/84` loads without errors
- [ ] All view modes (list, grid, table) work
- [ ] CRUD actions (New, Inspect, Edit) work
- [ ] Layout matches paper's old behavior

**Phase 4 (Paper Removal):**
- [ ] Both apps work after paper files deleted
- [ ] No references to `UxPaperHost` remain
- [ ] No references to `currentPaperI` remain
- [ ] `flutter analyze lib` passes

**Phase 5 (Zone Rendering):**
- [ ] Menubar tab switching works in `Tworkspace`
- [ ] Panel content shows/hides correctly
- [ ] State persistence for `activePanel`
- [ ] Nested template containers render correctly

### Analyzer Check

```bash
flutter analyze lib
```

**Must pass with zero errors/warnings after each phase.**

---

## Rollback Plan (Revised)

**Per-Phase Rollback:**

### Phase 1 Rollback
- Revert `CopilotUx` changes (keep `currentPaperI` requirement)
- Revert `GenUx.build()` dual dispatch
- Remove `UxFrameMeta` class
- Paper-rooted specs continue working

### Phase 2-3 Rollback
- Revert spec changes in `aibook_specs.dart` / `aiwork_specs.dart`
- Restore `UxSpec.paper` wrappers
- Paper-rooted rendering still supported

### Phase 4 Rollback
- Restore paper files from git
- Restore `UxPaperHost` class
- Restore `_buildCompiledPaper()` method
- Revert `UxLayer` enum changes

**General Rollback Command:**
```bash
git revert HEAD~N..HEAD  # Revert last N commits (per-phase)
```

**Key Point:** Each phase is independently reversible. No point of no return until Phase 4 complete.

---

## Conclusion (Revised)

**Recommendation:** Proceed with **phased paper layer removal**, separating runtime migration from zone redesign.

**Timeline:** 7-12 days total (per Codex warning about single-patch risk)

**Next Step:** Begin Phase 1 — add `UxFrameMeta`, teach `CopilotUx` to mount root templates, update `GenUx.build()` for dual dispatch.

**Success Criteria:**
- ✅ Phase 1: Runtime supports both paper-rooted and template-rooted specs
- ✅ Phase 2: AIBook works with root templates (paper still functional)
- ✅ Phase 3: AIWork works with root templates (no paper-rooted specs remain)
- ✅ Phase 4: Paper layer removed, `flutter analyze lib` passes
- ✅ Phase 5: Menubar tab control works in `Tworkspace`
- ✅ Phase 6: Rich zone system with multiple patterns documented

**Critical Rules (from Codex Analysis):**
1. Keep `pageSpecId` for route identity (do NOT change URLs)
2. Use route-owned root template IDs (not shared inner template IDs like `20001`)
3. Separate `UxFrameMeta` from `UxWorkspaceMeta` (layout vs business metadata)
4. Panel grouping must be explicit (nested containers, not flat widget lists)
5. Menubar source of truth = zone specs (not duplicated metadata)
6. Prove zone rendering in `Tworkspace` before expanding to other templates
7. Paper removal and zone reshape are **adjacent projects, not one patch**

---

**Document Version:** 2.0 (Revised per Codex Analysis)
**Last Updated:** 2026-03-25
**Status:** Proposed — awaiting implementation

**Related Documents:**
- `docs/ui_layer_system_codex.md` — Implementation-oriented analysis with critical reality checks
- `docs/project_deep_analysis.md` — Full architecture analysis
- `docs/lib_app_readme.md` — App roles and transport contracts
