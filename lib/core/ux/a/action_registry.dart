import 'dart:async';

import 'package:genrp/core/ux/a/pilot.dart';

typedef UxActionHandler =
    FutureOr<void> Function(UxPilot pilot, {Map<String, dynamic> context});

class UxActionRegistry {
  final Map<int, UxActionHandler> _handlers = <int, UxActionHandler>{};

  void register(int actionId, UxActionHandler handler) {
    _handlers[actionId] = handler;
  }

  bool has(int actionId) => _handlers.containsKey(actionId);

  Future<void> run(
    int actionId,
    UxPilot pilot, {
    Map<String, dynamic> context = const <String, dynamic>{},
  }) async {
    final handler = _handlers[actionId];
    if (handler == null) {
      throw StateError('No UX action registered for id $actionId');
    }
    await handler(pilot, context: context);
  }

  void unregister(int actionId) {
    _handlers.remove(actionId);
  }

  void clear() {
    _handlers.clear();
  }
}
