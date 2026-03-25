# Autopilot Refactoring Plan — Fix the Drift

## The Problem

Autopilot was designed as a **thin coordinator** that delegates to specialized copilots.
Instead, it absorbed all the logic (~339 lines) while the copilots shrank to passthrough wrappers.

### Drift Summary

| File | Lines Now | Intended Role | Actual Role |
|---|---|---|---|
| `autopilot.dart` | **339** | Thin entry point / coordinator | Does everything |
| `copilot_data.dart` | **25** | Owns all data mutations | Redundant passthrough |
| `copilot_state.dart` | **80** | Owns all UI state + scoping | Redundant passthrough |
| `copilot_route.dart` | **58** | Should own navigation lifecycle | Dumb model class |

---

## The Fix — Three Moves

### Move 1: `CopilotData` owns `DataSet`

**Move FROM `Autopilot`:**
- `DataSet dataSet` field → lives inside `CopilotData`
- `data(key)`, `setData()`, `patchData()` → become methods on `CopilotData`

**`CopilotData` after refactor:**
```dart
class CopilotData {
  CopilotData(this._onChanged);

  final VoidCallback _onChanged;
  final DataSet _dataSet = DataSet();

  dynamic operator [](String key) => _dataSet[key];
  T? get<T>(String key) => _dataSet.get<T>(key);

  void set(String key, dynamic value, {bool notify = true}) {
    _dataSet[key] = value;
    if (notify) _onChanged();
  }

  void patch(Map<String, dynamic> values, {bool notify = true}) {
    _dataSet.patch(values);
    if (notify) _onChanged();
  }

  Map<String, dynamic> snapshot() => _dataSet.snapshot();

  void clear({bool notify = true}) {
    _dataSet.clear();
    if (notify) _onChanged();
  }
}
```

**Access pattern:** `autopilot.data['key']` or `autopilot.data.set('key', value)`

---

### Move 2: `CopilotState` owns `StateSet` + all scoping logic

**Move FROM `Autopilot`:**
- `StateSet stateSet` field → lives inside `CopilotState`
- `_currentPaperScope`, `_currentPaperI`, `_templateScopes` → live in `CopilotState`
- `mountPaper()`, `mountTemplate()`, `mountCurrentTemplate()` → methods on `CopilotState`
- `paperScopeFor()`, `templateScopeFor()` → methods on `CopilotState`
- `setChromeState()`, `patchChromeState()` → methods on `CopilotState`
- `paperState()`, `setPaperState()`, `patchPaperState()` → methods on `CopilotState`
- `templateState()`, `setTemplateState()`, `patchTemplateState()` → methods on `CopilotState`
- `clearTemplateScope()`, `clearPaperScope()` → methods on `CopilotState`

**`CopilotState` after refactor owns:**
- The `StateSet` instance
- All 3-tier scoped state (chrome / paper / template)
- Paper and template mount/clear lifecycle
- Scope key generation

**It receives the current route scope from Autopilot** (or from CopilotRoute) to build scope keys.

---

### Move 3: `CopilotRoute` owns navigation lifecycle

**Rename concept:** The current `CopilotRoute` class becomes `RouteSpec` (or `RouteModel`) — it stays as the data model.

**New `CopilotRoute` becomes the navigator copilot:**

**Move FROM `Autopilot`:**
- `_currentRoute` field → lives inside `CopilotRoute`
- `navigate()`, `mountRoute()`, `clearRoute()` → methods on `CopilotRoute`
- Route-related chrome state syncing (`route.path`, `route.scope`, etc.)

**`CopilotRoute` after refactor:**
```dart
class CopilotRoute {
  CopilotRoute({required this.state, required this.onChanged});

  final CopilotState state;       // to sync route info into chrome state
  final VoidCallback onChanged;

  RouteSpec? _current;
  RouteSpec? get current => _current;

  void navigate(String rawRoute, {bool notify = true}) {
    mount(RouteSpec.parse(rawRoute), notify: notify);
  }

  void mount(RouteSpec route, {bool notify = true}) {
    clear(notify: false);
    _current = route;
    state.patchChrome({
      'route.path': route.path,
      'route.scope': route.scopeKey,
      'route.app': route.appName,
      'route.pageSpecId': route.pageSpecId,
      'route.optionalId': route.optionalId,
    });
    if (notify) onChanged();
  }

  void clear({bool notify = true}) {
    _current = null;
    state.patchChrome({
      'route.path': null,
      'route.scope': null,
      'route.app': null,
      'route.pageSpecId': null,
      'route.optionalId': null,
    });
    if (notify) onChanged();
  }

  String get currentScopeKey => _current?.scopeKey ?? 'default';
}
```

**The current `CopilotRoute` model class** gets renamed to `RouteSpec`:
```dart
class RouteSpec {
  const RouteSpec({required this.appName, required this.pageSpecId, this.optionalId});
  // ... existing parse/toJson/path/scopeKey logic stays identical
}
```

---

## Autopilot After Refactor

```dart
class Autopilot extends ChangeNotifier {
  Autopilot({this.v, this.f, this.c, this.usr, this.user}) {
    data  = CopilotData(notifyListeners);
    state = CopilotState(notifyListeners);
    route = CopilotRoute(state: state, onChanged: notifyListeners);
  }

  // --- Global readonly context ---
  String? v;
  String? f;
  String? c;
  Object? usr;
  Object? user;

  // --- Copilots ---
  late final CopilotData  data;
  late final CopilotState state;
  late final CopilotRoute route;

  // --- Auth (stays here — it's a cross-cutting concern) ---
  static const String mockUsername = 'admin';
  static const String mockPassword = 'admin';
  // ... mock constants + applyMockAuth + validateMockCredentials ...

  // --- Context setter ---
  void setContext({String? v, String? f, String? c, Object? usr, Object? user, bool notify = true}) {
    this.v = v ?? this.v;
    this.f = f ?? this.f;
    this.c = c ?? this.c;
    this.usr = usr ?? this.usr;
    this.user = user ?? this.user;
    if (notify) notifyListeners();
  }

  // --- Lifecycle ---
  void clearAll({bool notify = true}) {
    route.clear(notify: false);
    state.clearAll(notify: false);
    data.clear(notify: false);
    if (notify) notifyListeners();
  }

  void publishChange() => notifyListeners();
}
```

### Estimated line counts after:

| File | Before | After | Change |
|---|---|---|---|
| `autopilot.dart` | 339 | ~80 | **−259** |
| `copilot_data.dart` | 25 | ~35 | +10 |
| `copilot_state.dart` | 80 | ~160 | +80 |
| `copilot_route.dart` | 58 | ~55 | ~same (rename to `route_spec.dart`) |
| `copilot_route.dart` (new navigator) | — | ~50 | new |

---

## Execution Order

1. **Rename** current `CopilotRoute` → `RouteSpec` (file: `route_spec.dart`)
2. **Fatten `CopilotState`** — move all state/scoping logic from Autopilot into it
3. **Fatten `CopilotData`** — move DataSet ownership from Autopilot into it
4. **Create new `CopilotRoute`** — move navigation lifecycle from Autopilot into it
5. **Slim Autopilot** — remove moved code, hold copilots as `late final` fields
6. **Update call sites** — `autopilot.mountPaper(...)` → `autopilot.state.mountPaper(...)`
7. **Run tests** to confirm nothing broke

---

## Rules Going Forward

> [!IMPORTANT]
> - **Autopilot never directly touches `DataSet` or `StateSet`** — always goes through a copilot.
> - **New runtime concerns get a new copilot** — don't add methods to Autopilot.
> - **Copilots receive `VoidCallback onChanged`** — they don't hold an `Autopilot` reference (avoids circular dependency).
