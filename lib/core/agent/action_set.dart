import 'action.dart';

typedef ActionHandler = Future<void> Function(dynamic payload);

/// Minimal action registry for agents.
class ActionSet {
  final Map<String, ActionHandler> _handlers = {};
  final Map<String, Action> _actions = {};
  final Map<int, String> _actionNamesById = {};

  ActionSet();

  void register(String name, ActionHandler handler, [Action? action]) {
    _handlers[name] = handler;
    if (action != null) {
      _actions[name] = action;
      _actionNamesById[action.id] = name;
    }
  }

  Future<void> invoke(String name, [dynamic payload]) async {
    final h = _handlers[name];
    if (h != null) await h(payload);
  }

  Action? getAction(String name) => _actions[name];

  Future<void> invokeById(int id, [dynamic payload]) async {
    final name = _actionNamesById[id];
    if (name == null) return;
    await invoke(name, payload);
  }

  void clear() {
    _handlers.clear();
    _actions.clear();
    _actionNamesById.clear();
  }
}
