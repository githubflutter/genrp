# Action Handling Usage Guide

## Quick Start

### 1. Register Handlers (Already done in main.dart)

```dart
void main() {
  final autopilot = Autopilot();
  SystemActionHandlers.registerAll(autopilot);
  
  runApp(
    ChangeNotifierProvider<Autopilot>.value(
      value: autopilot,
      child: const MainApp(),
    ),
  );
}
```

### 2. Trigger Actions from UI

```dart
// In your widget
final autopilot = context.watch<Autopilot>();

// Commit action
await autopilot.actions.run(
  SystemAction.commit,
  autopilot,
  context: {
    'payload': {
      'validator': _validateForm,
      'persister': _saveToDatabase,
    },
  },
);

// Refetch action
await autopilot.actions.run(
  SystemAction.refetch,
  autopilot,
  context: {
    'payload': {
      'fetcher': _fetchData,
      'loading': true,
    },
  },
);
```

---

## Action Reference

### Core Lifecycle Actions

#### Commit (ID: 1)
Persist changes and complete the current flow.

```dart
await autopilot.actions.run(
  SystemAction.commit,
  autopilot,
  context: {
    'payload': {
      // Optional validation function
      'validator': (Autopilot p, Map<String, dynamic> ctx) async {
        final errors = <String>[];
        if (p.dataSet['name'] == null) {
          errors.add('Name is required');
        }
        return errors;
      },
      // Optional persistence function
      'persister': (Autopilot p, Map<String, dynamic> ctx) async {
        await database.insert('table', p.dataSet.snapshot());
      },
      // Optional success callback
      'onSuccess': () {
        print('Commit successful!');
      },
    },
  },
);
```

**Chrome state updates:**
- `committing`: bool (true while committing)
- `validationFailed`: bool
- `errors`: List<String>
- `commitSuccess`: bool
- `lastCommitTime`: String (ISO8601)

---

#### Refetch (ID: 2)
Reload the current working data from source.

```dart
await autopilot.actions.run(
  SystemAction.refetch,
  autopilot,
  context: {
    'payload': {
      // Fetch function
      'fetcher': (Autopilot p, Map<String, dynamic> ctx) async {
        final response = await http.get('/api/data');
        return jsonDecode(response.body);
      },
      // Show loading indicator
      'loading': true,
    },
  },
);
```

**Chrome state updates:**
- `loading`: bool
- `lastFetchTime`: String (ISO8601)
- `fetchCount`: int

---

#### Cancel (ID: 3)
Abort the current interaction and return to safe state.

```dart
await autopilot.actions.run(
  SystemAction.cancel,
  autopilot,
  context: {
    'payload': {
      // Clear all state
      'clearState': false,
      // Navigate to route after cancel
      'navigateTo': '/home',
      // Callback
      'onCancel': () {
        print('Cancelled!');
      },
    },
  },
);
```

**Chrome state updates:**
- Clears: `errors`, `validationFailed`, `commitError`, `fetchError`

---

#### Share (ID: 4)
Export current context to another surface.

```dart
await autopilot.actions.run(
  SystemAction.share,
  autopilot,
  context: {
    'payload': {
      // Format: 'json' or 'text'
      'format': 'json',
      // Share callback
      'onShare': (String output) {
        Clipboard.setData(ClipboardData(text: output));
      },
    },
  },
);
```

**Chrome state updates:**
- `lastShareTime`: String (ISO8601)
- `sharePayload`: String

---

### State Management Actions

#### Rebuild (ID: 5)
Trigger UI rebuild/notifyChanges.

```dart
await autopilot.actions.run(
  SystemAction.rebuild,
  autopilot,
);
```

---

#### Get Data (ID: 6)
Retrieve data into context.

```dart
await autopilot.actions.run(
  SystemAction.getData,
  autopilot,
  context: {
    'payload': {
      // Specific keys to retrieve
      'keys': ['name', 'email'],
      // Callback with retrieved data
      'callback': (Map<String, dynamic> data) {
        print('Retrieved: $data');
      },
    },
  },
);
```

---

#### Set Data (ID: 7)
Write data from context.

```dart
await autopilot.actions.run(
  SystemAction.setData,
  autopilot,
  context: {
    'payload': {
      'data': {'name': 'John', 'email': 'john@example.com'},
      // Merge with existing data (default: true)
      'merge': true,
    },
  },
);
```

---

#### Set State (ID: 8)
Update session/app state.

```dart
await autopilot.actions.run(
  SystemAction.setState,
  autopilot,
  context: {
    'payload': {
      'state': {'isLoading': true, 'selectedId': 42},
      // Merge with existing state (default: true)
      'merge': true,
    },
  },
);
```

---

#### Get State (ID: 9)
Read state into context.

```dart
await autopilot.actions.run(
  SystemAction.getState,
  autopilot,
  context: {
    'payload': {
      'keys': ['isLoading', 'selectedId'],
      'callback': (Map<String, dynamic> state) {
        print('Current state: $state');
      },
    },
  },
);
```

---

### Modal/Sheet Actions

#### Open Bottom Sheet (ID: 10)
Show bottom sheet modal.

```dart
await autopilot.actions.run(
  SystemAction.openBottomSheet,
  autopilot,
  context: {
    'payload': {
      'builder': (BuildContext context) {
        return BottomSheetContent();
      },
      'isDismissible': true,
      'enableDrag': true,
    },
  },
);
```

**Note:** This sets chrome state to signal the app shell. The app shell must listen for `bottomSheetRequested` and handle the actual display.

**Chrome state updates:**
- `bottomSheetRequested`: bool
- `bottomSheetBuilder`: Widget Function(BuildContext)
- `bottomSheetConfig`: Map

---

#### Close Bottom Sheet (ID: 11)
Dismiss bottom sheet.

```dart
await autopilot.actions.run(
  SystemAction.closeBottomSheet,
  autopilot,
  context: {
    'payload': {
      'result': {'saved': true},
    },
  },
);
```

**Chrome state updates:**
- `bottomSheetResult`: dynamic
- `bottomSheetClosing`: bool

---

#### Show Dialog (ID: 12)
Show modal dialog.

```dart
await autopilot.actions.run(
  SystemAction.showDialog,
  autopilot,
  context: {
    'payload': {
      'builder': (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
      'barrierDismissible': true,
    },
  },
);
```

**Chrome state updates:**
- `dialogRequested`: bool
- `dialogBuilder`: Widget Function(BuildContext)
- `dialogConfig`: Map

---

#### Dismiss Dialog (ID: 13)
Close active dialog.

```dart
await autopilot.actions.run(
  SystemAction.dismissDialog,
  autopilot,
  context: {
    'payload': {
      'result': true,
    },
  },
);
```

**Chrome state updates:**
- `dialogResult`: dynamic
- `dialogClosing`: bool

---

### Data ↔ UX Sync Actions

#### Set Data To UX (ID: 14)
Push data layer → UX layer.

```dart
// Simple: merge all data into UX state
await autopilot.actions.run(
  SystemAction.setDataToUx,
  autopilot,
);

// Advanced: field mapping
await autopilot.actions.run(
  SystemAction.setDataToUx,
  autopilot,
  context: {
    'payload': {
      // Map UX keys to data keys
      'mapping': {
        'userName': 'name',
        'userEmail': 'email',
      },
      // Clear UX state first
      'clear': false,
    },
  },
);
```

---

#### Set UX To Data (ID: 15)
Push UX layer → data layer.

```dart
// Simple: merge all UX state into data
await autopilot.actions.run(
  SystemAction.setUxToData,
  autopilot,
);

// Advanced: field mapping
await autopilot.actions.run(
  SystemAction.setUxToData,
  autopilot,
  context: {
    'payload': {
      // Map data keys to UX keys
      'mapping': {
        'name': 'userName',
        'email': 'userEmail',
      },
      // Clear data first
      'clear': false,
    },
  },
);
```

---

## App Shell Integration for Modals

To handle modal dialogs/sheets signaled by actions, update your app shell:

```dart
class _AIWorkHomeState extends State<AIWorkHome> {
  late final Autopilot _pilot;

  @override
  void initState() {
    super.initState();
    _pilot = Autopilot();
    SystemActionHandlers.registerAll(_pilot);
    
    // Listen for modal requests
    _pilot.addListener(_handleModalRequests);
  }

  void _handleModalRequests() {
    // Bottom sheet
    if (_pilot.stateSet.chrome<bool>('bottomSheetRequested') == true) {
      final builder = _pilot.stateSet.chrome<Widget Function(BuildContext)>(
        'bottomSheetBuilder',
      );
      if (builder != null && mounted) {
        showModalBottomSheet(
          context: context,
          builder: builder,
        ).then((result) {
          _pilot.patchChromeState({'bottomSheetResult': result});
          _pilot.publishChange();
        });
        _pilot.patchChromeState({'bottomSheetRequested': false});
      }
    }

    // Dialog
    if (_pilot.stateSet.chrome<bool>('dialogRequested') == true) {
      final builder = _pilot.stateSet.chrome<Widget Function(BuildContext)>(
        'dialogBuilder',
      );
      if (builder != null && mounted) {
        showDialog(
          context: context,
          builder: builder,
        ).then((result) {
          _pilot.patchChromeState({'dialogResult': result});
          _pilot.publishChange();
        });
        _pilot.patchChromeState({'dialogRequested': false});
      }
    }
  }

  @override
  void dispose() {
    _pilot.removeListener(_handleModalRequests);
    _pilot.dispose();
    super.dispose();
  }
}
```

---

## Custom Action Handlers

Register your own business actions:

```dart
// Define action ID
class BusinessAction {
  static const int saveEntity = 101;
  static const int deleteEntity = 102;
  static const int exportReport = 103;
}

// Create handler
Future<void> handleSaveEntity(
  Autopilot autopilot, {
  Map<String, dynamic> context = const {},
}) async {
  final data = autopilot.dataSet.snapshot();
  await database.insert('entities', data);
  autopilot.patchChromeState({'saveSuccess': true});
  autopilot.publishChange();
}

// Register in app init
_pilot.actions.register(BusinessAction.saveEntity, handleSaveEntity);

// Trigger from UI
await autopilot.actions.run(
  BusinessAction.saveEntity,
  autopilot,
);
```

---

## Best Practices

1. **Keep handlers pure** — Don't store state in handlers, use Autopilot
2. **Use payload for parameters** — All configuration goes in `context['payload']`
3. **Update chrome state for UI feedback** — Loading, errors, success states
4. **Call `publishChange()` after state updates** — Ensures UI refreshes
5. **Handle errors gracefully** — Set error state in chrome, don't crash
6. **Document your actions** — Add comments explaining payload structure

---

## Debugging

Enable action logging:

```dart
// Wrap action calls with logging
Future<void> _triggerAction(int actionId) async {
  print('Action $actionId triggered');
  try {
    await autopilot.actions.run(actionId, autopilot);
    print('Action $actionId completed');
  } catch (e) {
    print('Action $actionId failed: $e');
  }
}
```

Inspect current state:

```dart
print('Data: ${autopilot.dataSet.snapshot()}');
print('State: ${autopilot.stateSet.snapshot()}');
print('Chrome: ${autopilot.stateSet.snapshot()['chrome']}');
```
