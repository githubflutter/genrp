import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/action.dart';
import 'package:genrp/core/agent/mock_transport.dart';
import 'package:genrp/core/base/x.dart';

/// Minimal concrete Autopilot implementation used by the app.
class AutopilotGo extends Autopilot {
  AutopilotGo();

  String? _loadedSpecId;
  String? specError;

  void configureSpec(Map<String, dynamic> spec) {
    final nextSpecId =
        (spec['id'] ?? spec['name'] ?? spec['toolbar']?['title'] ?? 'aibook')
            .toString();
    if (_loadedSpecId == nextSpecId) return;

    _loadedSpecId = nextSpecId;
    specError = null;

    final error = _validateSpec(spec);
    if (error != null) {
      specError = error;
      Future.microtask(() => publishChange());
      return;
    }

    actionSet.clear();
    dataSet.clear();
    stateSet.clear();
    clearFieldPaths();
    clearSelectedUxIdentity(notify: false);
    _configureFieldBindings(spec);

    final initialData = Map<String, dynamic>.from(
      spec['initialData'] as Map? ?? const {},
    );
    if (initialData.containsKey('x_row') && initialData['x_row'] is Map) {
      initialData['x_row'] = X.fromJson(
        Map<String, dynamic>.from(initialData['x_row']),
      );
    }
    copilotData.patch(initialData, notify: false);
    copilotUX.patch(
      Map<String, dynamic>.from(spec['initialState'] as Map? ?? const {}),
      notify: false,
    );

    final actions = Action.fromList(spec['actions']);
    for (final action in actions) {
      if (action.name.isEmpty) continue;
      actionSet.register(
        action.name,
        (payload) => _runAction(action, payload),
        action,
      );
    }
  }

  void _configureFieldBindings(Map<String, dynamic> spec) {
    final bindings = List<Object?>.from(
      spec['fieldBindings'] as List? ?? const [],
    );
    for (final item in bindings.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      final src = (map['src'] as num?)?.toInt();
      final fieldId =
          (map['fieldId'] as num?)?.toInt() ?? (map['f'] as num?)?.toInt();
      final path = map['path']?.toString() ?? '';
      final slot = (map['slot'] as num?)?.toInt();
      if (src == null || fieldId == null) continue;
      if (slot != null) {
        registerFieldSlot(src, fieldId, slot);
      }
      if (path.isNotEmpty) {
        registerFieldPath(src, fieldId, path);
      }
    }
  }

  String? _validateSpec(Map<String, dynamic> spec) {
    String? checkDuplicates(String key) {
      final list = List<Object?>.from(spec[key] ?? []);
      final seenIds = <int>{};
      for (final item in list.whereType<Map>()) {
        final id = (item['id'] as num?)?.toInt();
        if (id != null) {
          if (!seenIds.add(id)) return 'Duplicate id $id found in $key';
        }
      }
      return null;
    }

    final e1 = checkDuplicates('bodiesRegistry');
    if (e1 != null) return e1;
    final e2 = checkDuplicates('widgets');
    if (e2 != null) return e2;

    return null;
  }

  Future<void> _runAction(Action action, dynamic payload) async {
    if (action.name == 'saveBook') {
      final xRow = copilotData.getValue('x_row');
      if (xRow is X) {
        final savedRow = await MockTransport.saveRow(xRow);
        copilotData.setValue('x_row', savedRow);
      }
    }

    for (final todo in action.todos) {
      await _runTodo(todo, payload);
    }
  }

  Future<void> _runTodo(Todo todo, dynamic payload) async {
    if (todo.operation != 'set' || todo.path.isEmpty) return;

    dynamic value;
    if (todo.bind != null) {
      value = resolve(todo.bind!);
    } else if (todo.payloadKey != null && payload is Map) {
      value = payload[todo.payloadKey];
    } else {
      value = todo.value;
    }

    if (todo.type == 'data') {
      copilotData.setValue(todo.path, value);
      return;
    }

    if (todo.type == 'ux' || todo.type == 'state') {
      copilotUX.setValue(todo.path, value);
    }
  }
}
