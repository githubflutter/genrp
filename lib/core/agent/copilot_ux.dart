import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';

class CopilotUx {
  CopilotUx(this.autopilot);

  final Autopilot autopilot;

  int? _currentAppId;
  int? _currentRouteId;
  String? _currentOptionalId;
  int? _currentRootTemplateI;

  int? get currentAppId => _currentAppId;
  int? get currentRouteId => _currentRouteId;
  String? get currentOptionalId => _currentOptionalId;
  int? get currentRootTemplateI => _currentRootTemplateI;

  void mountRootTemplate({
    required int templateI,
    Map<String, dynamic> initialState = const <String, dynamic>{},
    bool notify = true,
  }) {
    final route = autopilot.currentRoute;
    if (route == null) return;

    _currentAppId = route.app.i;
    _currentRouteId = route.id;
    _currentOptionalId = route.optionalId;
    _currentRootTemplateI = templateI;

    if (initialState.isNotEmpty) {
      final code = UxRegister.templateCode(
        appId: _currentAppId!,
        routeId: _currentRouteId!,
        templateId: templateI,
        optionalId: _currentOptionalId,
      );
      autopilot.stateSet.patchTemplate(code, initialState);
    }
    if (notify) {
      autopilot.publishChange();
    }
  }

  void clearRootTemplate(int appId, int routeId, int templateI, {String? optionalId, bool notify = true}) {
    final code = UxRegister.templateCode(
      appId: appId,
      routeId: routeId,
      templateId: templateI,
      optionalId: optionalId,
    );
    autopilot.stateSet.clearTemplate(code);
    if (_currentAppId == appId && _currentRouteId == routeId && _currentRootTemplateI == templateI && _currentOptionalId == optionalId) {
      _currentAppId = null;
      _currentRouteId = null;
      _currentOptionalId = null;
      _currentRootTemplateI = null;
    }
    if (notify) {
      autopilot.publishChange();
    }
  }

  void mountTemplate({
    required int templateId,
    Map<String, dynamic> initialState = const <String, dynamic>{},
    bool notify = true,
  }) {
    final route = autopilot.currentRoute;
    if (route == null) return;

    final code = UxRegister.templateCode(
      appId: route.app.i,
      routeId: route.id,
      templateId: templateId,
      optionalId: route.optionalId,
    );
    if (initialState.isNotEmpty) {
      autopilot.stateSet.patchTemplate(code, initialState);
    }
    if (notify) {
      autopilot.publishChange();
    }
  }

  void mountUWidget({
    required int templateId,
    required int uwidgetId,
    Map<String, dynamic> initialState = const <String, dynamic>{},
    bool notify = true,
  }) {
    final route = autopilot.currentRoute;
    if (route == null) return;

    final code = UxRegister.uwidgetCode(
      appId: route.app.i,
      routeId: route.id,
      templateId: templateId,
      uwidgetId: uwidgetId,
      optionalId: route.optionalId,
    );
    if (initialState.isNotEmpty) {
      autopilot.stateSet.patchUWidget(code, initialState);
    }
    if (notify) {
      autopilot.publishChange();
    }
  }

  T? templateState<T>(Object templateId, String key) {
    final route = autopilot.currentRoute;
    if (route == null) return null;

    final tid = templateId is int ? templateId : int.tryParse(templateId.toString()) ?? 0;
    final code = UxRegister.templateCode(
      appId: route.app.i,
      routeId: route.id,
      templateId: tid,
      optionalId: route.optionalId,
    );
    return autopilot.stateSet.getTemplate<T>(code, key);
  }

  void setTemplateState(
    Object templateId,
    String key,
    dynamic value, {
    bool notify = true,
  }) {
    final route = autopilot.currentRoute;
    if (route == null) return;

    final tid = templateId is int ? templateId : int.tryParse(templateId.toString()) ?? 0;
    final code = UxRegister.templateCode(
      appId: route.app.i,
      routeId: route.id,
      templateId: tid,
      optionalId: route.optionalId,
    );
    autopilot.stateSet.setTemplate(code, key, value);
    if (notify) {
      autopilot.publishChange();
    }
  }

  void patchTemplateState(
    Object templateId,
    Map<String, dynamic> values, {
    bool notify = true,
  }) {
    final route = autopilot.currentRoute;
    if (route == null) return;

    final tid = templateId is int ? templateId : int.tryParse(templateId.toString()) ?? 0;
    final code = UxRegister.templateCode(
      appId: route.app.i,
      routeId: route.id,
      templateId: tid,
      optionalId: route.optionalId,
    );
    autopilot.stateSet.patchTemplate(code, values);
    if (notify) {
      autopilot.publishChange();
    }
  }

  void clearTemplateState(Object templateId, {bool notify = true}) {
    final route = autopilot.currentRoute;
    if (route == null) return;

    final tid = templateId is int ? templateId : int.tryParse(templateId.toString()) ?? 0;
    final code = UxRegister.templateCode(
      appId: route.app.i,
      routeId: route.id,
      templateId: tid,
      optionalId: route.optionalId,
    );
    autopilot.stateSet.clearTemplate(code);
    if (notify) {
      autopilot.publishChange();
    }
  }

  void clearRoute({bool notify = true}) {
    final route = autopilot.currentRoute;
    if (route != null) {
      final code = UxRegister.routeCode(route.app.i, route.id, optionalId: route.optionalId);
      autopilot.stateSet.clearRoute(code);
    }
    _currentAppId = null;
    _currentRouteId = null;
    _currentOptionalId = null;
    _currentRootTemplateI = null;

    if (notify) {
      autopilot.publishChange();
    }
  }

  void clearAll({bool notify = true}) {
    clearRoute(notify: false);
    autopilot.stateSet.clear();
    if (notify) {
      autopilot.publishChange();
    }
  }
}
