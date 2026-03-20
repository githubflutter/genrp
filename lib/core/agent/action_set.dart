import 'dart:async';

import 'package:genrp/core/agent/autopilot.dart';

typedef ActionHandler =
    FutureOr<void> Function(
      Autopilot autopilot, {
      Map<String, dynamic> context,
    });

class ActionSet {
  final Map<int, ActionHandler> _handlers = <int, ActionHandler>{};

  void register(int actionId, ActionHandler handler) {
    _handlers[actionId] = handler;
  }

  bool has(int actionId) => _handlers.containsKey(actionId);

  Future<void> run(
    int actionId,
    Autopilot autopilot, {
    Map<String, dynamic> context = const <String, dynamic>{},
  }) async {
    final handler = _handlers[actionId];
    if (handler == null) {
      throw StateError('No action registered for id $actionId');
    }
    await handler(autopilot, context: context);
  }

  void unregister(int actionId) {
    _handlers.remove(actionId);
  }

  void clear() {
    _handlers.clear();
  }
}
