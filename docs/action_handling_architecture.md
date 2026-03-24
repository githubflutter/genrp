# Action Handling Architecture

## Overview

GenRP action handling is built on a **command-pattern registry** where actions are:
- **Declared** in `ActionModel` (metadata, todos, icon, title)
- **Registered** with handlers (`ActionHandler` functions)
- **Triggered** from UI (buttons, gestures, keyboard)
- **Executed** through `Autopilot` (state, context, chrome updates)

## Core Principles

### 1. Single Orchestrator
All actions flow through `Autopilot.actions.run()`:
```dart
await autopilot.actions.run(actionId, autopilot, context: {...});
```

### 2. Handler Signature
```dart
typedef ActionHandler = FutureOr<void> Function(
  Autopilot autopilot, {
  Map<String, dynamic> context,
});
```

### 3. Context Contract
Every action receives a standard context envelope:
```dart
{
  'actionId': int,           // Which action
  'actionName': String,      // Action code name
  'actionLabel': String,     // Display label
  'payload': Map,            // Action-specific data
  'templateI': int,          // Template instance
  'routePath': String?,      // Current route
  'routeApp': String?,       // Current app
  'routeSpecId': int?,       // Current spec
  'optionalId': String?,     // Optional instance ID
  'paperI': int?,            // Current paper
}
```

### 4. State Patching
Actions communicate state changes through `Autopilot`:
```dart
autopilot.patchChromeState({'key': value});      // UI chrome
autopilot.dataSet.patchState({'key': value});    // Business state
autopilot.stateSet.patchState({'key': value});   // Session state
```

---

## Action Categories

### System Actions (1-99)
Core framework actions available in all apps.

| ID | Action | Purpose |
|----|--------|---------|
| 1 | `commit` | Persist changes, validate, complete flow |
| 2 | `refetch` | Reload data from source |
| 3 | `cancel` | Abort current interaction, return to safe state |
| 4 | `share` | Export context to another surface |
| 5 | `rebuild` | Trigger UI rebuild/notifyChanges |
| 6 | `get_data` | Retrieve data into context |
| 7 | `set_data` | Write data from context |
| 8 | `set_state` | Update session/app state |
| 9 | `get_state` | Read state into context |
| 10 | `open_bottom_sheet` | Show bottom sheet modal |
| 11 | `close_bottom_sheet` | Dismiss bottom sheet |
| 12 | `show_dialog` | Show modal dialog |
| 13 | `dismiss_dialog` | Close active dialog |
| 14 | `set_data_to_ux` | Push data layer → UX layer |
| 15 | `set_ux_to_data` | Push UX layer → data layer |

### Business Actions (100-999)
App-specific CRUD, workflows, domain operations.

### Composite Actions (1000+)
Multi-step orchestrations (wizard flows, batch operations).

---

## Handler Implementation Patterns

### Pattern 1: Simple State Update
```dart
Future<void> handleSetState(
  Autopilot autopilot, {
  Map<String, dynamic> context = const {},
}) async {
  final payload = context['payload'] as Map<String, dynamic>?;
  if (payload == null) return;
  
  autopilot.stateSet.patchState(payload);
  autopilot.notifyListeners();
}
```

### Pattern 2: Data Fetch with Loading
```dart
Future<void> handleRefetch(
  Autopilot autopilot, {
  Map<String, dynamic> context = const {},
}) async {
  // Set loading state
  autopilot.patchChromeState({'loading': true});
  autopilot.notifyListeners();
  
  try {
    // Fetch data
    final data = await _fetchData(context);
    
    // Update data set
    autopilot.dataSet.setData(data);
    
    // Sync to UX
    await handleSetDataToUx(autopilot, context: context);
  } finally {
    // Clear loading
    autopilot.patchChromeState({'loading': false});
    autopilot.notifyListeners();
  }
}
```

### Pattern 3: Validation + Commit
```dart
Future<void> handleCommit(
  Autopilot autopilot, {
  Map<String, dynamic> context = const {},
}) async {
  // Step 1: Validate
  final errors = await _validate(autopilot, context);
  if (errors.isNotEmpty) {
    autopilot.patchChromeState({
      'errors': errors,
      'validationFailed': true,
    });
    autopilot.notifyListeners();
    return;
  }
  
  // Step 2: Persist
  await _persist(autopilot, context);
  
  // Step 3: Refresh
  await handleRefetch(autopilot, context: context);
  
  // Step 4: Navigate/Complete
  autopilot.patchChromeState({'commitSuccess': true});
  autopilot.notifyListeners();
}
```

### Pattern 4: Modal Dialog
```dart
Future<void> handleShowDialog(
  Autopilot autopilot, {
  Map<String, dynamic> context = const {},
}) async {
  final payload = context['payload'] as Map<String, dynamic>?;
  if (payload == null) return;
  
  final title = payload['title'] as String?;
  final content = payload['content'] as String?;
  final actions = payload['actions'] as List?;
  
  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title ?? ''),
        content: Text(content ?? ''),
        actions: actions?.map<Widget>((a) => TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(a),
          child: Text(a['label']),
        )).toList() ?? [],
      );
    },
  );
}
```

---

## Data ↔ UX Sync

### `set_data_to_ux` (Action 14)
Pushes data layer values into UX state for rendering:
```dart
Future<void> handleSetDataToUx(
  Autopilot autopilot, {
  Map<String, dynamic> context = const {},
}) async {
  final data = autopilot.dataSet.getData();
  final mapping = context['payload'] as Map<String, dynamic>?;
  
  if (mapping != null) {
    // Map data fields to UX slots
    for (final entry in mapping.entries) {
      final uxKey = entry.key;
      final dataKey = entry.value as String;
      final value = data[dataKey];
      autopilot.stateSet.patchState({uxKey: value});
    }
  } else {
    // Default: merge all data into state
    autopilot.stateSet.patchState(data);
  }
  
  autopilot.notifyListeners();
}
```

### `set_ux_to_data` (Action 15)
Pushes UX state changes back to data layer:
```dart
Future<void> handleSetUxToData(
  Autopilot autopilot, {
  Map<String, dynamic> context = const {},
}) async {
  final state = autopilot.stateSet.getState();
  final mapping = context['payload'] as Map<String, dynamic>?;
  
  if (mapping != null) {
    // Map UX slots to data fields
    final data = <String, dynamic>{};
    for (final entry in mapping.entries) {
      final dataKey = entry.key;
      final uxKey = entry.value as String;
      data[dataKey] = state[uxKey];
    }
    autopilot.dataSet.setData(data);
  } else {
    // Default: merge all state into data
    autopilot.dataSet.setData(state);
  }
}
```

---

## Registration Strategy

### Phase 1: Framework Handlers (Now)
Register in `main.dart` before app launch:
```dart
void main() {
  final pilot = Autopilot();
  
  // Register system actions
  pilot.actions.register(SystemAction.commit, handleCommit);
  pilot.actions.register(SystemAction.refetch, handleRefetch);
  pilot.actions.register(SystemAction.cancel, handleCancel);
  pilot.actions.register(SystemAction.share, handleShare);
  pilot.actions.register(SystemAction.rebuild, handleRebuild);
  pilot.actions.register(SystemAction.getData, handleGetData);
  pilot.actions.register(SystemAction.setData, handleSetData);
  pilot.actions.register(SystemAction.setState, handleSetState);
  pilot.actions.register(SystemAction.getState, handleGetState);
  pilot.actions.register(SystemAction.openBottomSheet, handleOpenBottomSheet);
  pilot.actions.register(SystemAction.closeBottomSheet, handleCloseBottomSheet);
  pilot.actions.register(SystemAction.showDialog, handleShowDialog);
  pilot.actions.register(SystemAction.dismissDialog, handleDismissDialog);
  pilot.actions.register(SystemAction.setDataToUx, handleSetDataToUx);
  pilot.actions.register(SystemAction.setUxToData, handleSetUxToData);
  
  runApp(MainApp(autopilot: pilot));
}
```

### Phase 2: App-Specific Handlers
Each app registers business actions in `initState()`:
```dart
@override
void initState() {
  super.initState();
  _pilot.actions.register(101, _handleSaveEntity);
  _pilot.actions.register(102, _handleDeleteEntity);
  _pilot.actions.register(103, _handleExportReport);
}
```

### Phase 3: Spec-Driven Handlers (Future)
Actions in specs reference handlers by name:
```dart
ActionModel(
  i: 201,
  n: 'approveWorkflow',
  handlerName: 'workflow_approve',
)
```

---

## Error Handling

All handlers should follow this pattern:
```dart
Future<void> handleXxx(
  Autopilot autopilot, {
  Map<String, dynamic> context = const {},
}) async {
  try {
    // Action logic
    await _doWork(autopilot, context);
  } catch (e, st) {
    // Set error state
    autopilot.patchChromeState({
      'error': true,
      'errorMessage': e.toString(),
      'errorStack': st.toString(),
    });
    autopilot.notifyListeners();
    
    // Optionally rethrow for critical errors
    rethrow;
  }
}
```

---

## Testing Strategy

### Unit Test Handlers
```dart
test('handleCommit validates before persisting', () async {
  final autopilot = Autopilot();
  final context = {'payload': {'field': 'value'}};
  
  await handleCommit(autopilot, context: context);
  
  expect(autopilot.chromeState['validationFailed'], isFalse);
  expect(autopilot.chromeState['commitSuccess'], isTrue);
});
```

### Integration Test Action Flow
```dart
testWidgets('action button triggers handler', (tester) async {
  await tester.pumpWidget(MaterialApp(home: AIWorkApp()));
  
  // Tap commit button
  await tester.tap(find.byIcon(Icons.check));
  await tester.pumpAndSettle();
  
  // Verify state change
  expect(find.text('Changes saved'), findsOneWidget);
});
```

---

## Performance Considerations

1. **Debounce rapid actions** — Use `Timer` for actions like `setState`
2. **Batch state updates** — Collect changes, single `notifyListeners()`
3. **Async isolation** — Long-running actions don't block UI
4. **Context size** — Keep payload minimal, pass references not copies

---

## Security Considerations

1. **Auth check** — Verify `autopilot.user` before sensitive actions
2. **Input validation** — Sanitize all `context['payload']` values
3. **Action permissions** — Some actions restricted by role
4. **Audit logging** — Record action execution for compliance

---

## Migration Path

### Current State (2026-03)
- ✅ Action infrastructure exists
- ❌ No handlers registered
- ❌ Actions do nothing when triggered

### Immediate (This Session)
- ✅ Register system action handlers
- ✅ Implement 15 core handlers
- ✅ Test with AIWork/AIBook

### Short Term (Next Sprint)
- Add app-specific business actions
- Wire data persistence layer
- Add error handling + user feedback

### Long Term (Q2 2026)
- Server-side action execution
- Spec-driven handler registration
- Composite action orchestrations
