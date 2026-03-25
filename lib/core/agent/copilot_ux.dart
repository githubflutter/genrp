import 'package:genrp/core/agent/autopilot.dart';

class CopilotUx {
  CopilotUx(this.autopilot);

  final Autopilot autopilot;

  String? _currentRootTemplateScope;
  int? _currentRootTemplateI;
  final Set<String> _templateScopes = <String>{};

  String? get currentRootTemplateScope => _currentRootTemplateScope;
  int? get currentRootTemplateI => _currentRootTemplateI;
  Set<String> get currentTemplateScopes =>
      Set<String>.unmodifiable(_templateScopes);

  String mountRootTemplate({
    required int templateI,
    Map<String, dynamic> initialState = const <String, dynamic>{},
    bool notify = true,
  }) {
    final scope = rootTemplateScopeFor(templateI);
    _currentRootTemplateScope = scope;
    _currentRootTemplateI = templateI;
    _templateScopes.add(scope);
    if (initialState.isNotEmpty) {
      autopilot.stateSet.patchTemplate(scope, initialState);
    }
    if (notify) {
      autopilot.publishChange();
    }
    return scope;
  }

  void clearRootTemplate(String scope, {bool notify = true}) {
    autopilot.stateSet.clearTemplate(scope);
    _templateScopes.remove(scope);
    if (_currentRootTemplateScope == scope) {
      _currentRootTemplateScope = null;
      _currentRootTemplateI = null;
    }
    if (notify) {
      autopilot.publishChange();
    }
  }

  String mountCurrentTemplate({
    required int templateI,
    Map<String, dynamic> initialState = const <String, dynamic>{},
    bool notify = true,
  }) {
    final rootTemplateI = _currentRootTemplateI;
    if (rootTemplateI != null) {
      if (templateI == rootTemplateI) {
        final scope = _currentRootTemplateScope!;
        if (initialState.isNotEmpty) {
          autopilot.stateSet.patchTemplate(scope, initialState);
        }
        if (notify) {
          autopilot.publishChange();
        }
        return scope;
      } else {
        final scope = routeNestedTemplateScopeFor(rootTemplateI: rootTemplateI, templateI: templateI);
        _templateScopes.add(scope);
        if (initialState.isNotEmpty) {
          autopilot.stateSet.patchTemplate(scope, initialState);
        }
        if (notify) {
          autopilot.publishChange();
        }
        return scope;
      }
    }

    throw StateError(
      'Cannot mount template $templateI without an active route root template',
    );
  }

  String rootTemplateScopeFor(int templateI) {
    final routeScope = autopilot.currentRoute?.scopeKey ?? 'default';
    return 'template.route.$routeScope.$templateI';
  }

  String routeNestedTemplateScopeFor({required int rootTemplateI, required int templateI}) {
    final routeScope = autopilot.currentRoute?.scopeKey ?? 'default';
    return 'template.route.$routeScope.$rootTemplateI.$templateI';
  }

  T? templateState<T>(String scope, String key) =>
      autopilot.stateSet.getTemplate<T>(scope, key);

  void setTemplateState(
    String scope,
    String key,
    dynamic value, {
    bool notify = true,
  }) {
    autopilot.stateSet.setTemplate(scope, key, value);
    if (notify) {
      autopilot.publishChange();
    }
  }

  void patchTemplateState(
    String scope,
    Map<String, dynamic> values, {
    bool notify = true,
  }) {
    autopilot.stateSet.patchTemplate(scope, values);
    if (notify) {
      autopilot.publishChange();
    }
  }

  void clearTemplateScope(String scope, {bool notify = true}) {
    autopilot.stateSet.clearTemplate(scope);
    _templateScopes.remove(scope);
    if (notify) {
      autopilot.publishChange();
    }
  }

  void clearRoute({bool notify = true}) {    for (final scope in _templateScopes.toList(growable: false)) {
      autopilot.stateSet.clearTemplate(scope);
    }
    _templateScopes.clear();
    _currentRootTemplateScope = null;
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
