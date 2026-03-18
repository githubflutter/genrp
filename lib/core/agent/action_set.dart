import 'action.dart';

typedef ActionHandler = Future<void> Function(dynamic payload);

/// Minimal action registry for agents.
class ActionSet {
  final Map<String, ActionHandler> _handlers = {};
  final Map<String, Action> _actions = {};

  ActionSet();

  void register(String name, ActionHandler handler, [Action? action]) {
    _handlers[name] = handler;
    if (action != null) _actions[name] = action;
  }

  Future<void> invoke(String name, [dynamic payload]) async {
    final h = _handlers[name];
    if (h != null) await h(payload);
  }

  Action? getAction(String name) => _actions[name];

  void clear() {
    _handlers.clear();
    _actions.clear();
  }
}
