import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/action.dart';

/// Minimal concrete Autopilot implementation used by the app.
class AutopilotGo extends Autopilot {
  AutopilotGo();

  String? _loadedSpecId;

  void configureSpec(Map<String, dynamic> spec) {
    final nextSpecId =
        (spec['id'] ?? spec['name'] ?? spec['toolbar']?['title'] ?? 'aibook')
            .toString();
    if (_loadedSpecId == nextSpecId) return;

    _loadedSpecId = nextSpecId;
    actionSet.clear();
    dataSet.clear();
    stateSet.clear();
    clearFieldPaths();
    clearSelectedUxIdentity(notify: false);
    _configureFieldBindings(spec);

    copilotData.patch(
      Map<String, dynamic>.from(spec['initialData'] as Map? ?? const {}),
      notify: false,
    );
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
      if (src == null || fieldId == null || path.isEmpty) continue;
      registerFieldPath(src, fieldId, path);
    }
  }

  Future<void> _runAction(Action action, dynamic payload) async {
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
