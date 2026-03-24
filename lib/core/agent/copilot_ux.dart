import 'package:genrp/core/agent/autopilot.dart';

class CopilotUx {
  CopilotUx(this.autopilot);

  final Autopilot autopilot;

  String? _currentPaperScope;
  int? _currentPaperI;
  final Set<String> _templateScopes = <String>{};

  String? get currentPaperScope => _currentPaperScope;
  int? get currentPaperI => _currentPaperI;
  Set<String> get currentTemplateScopes =>
      Set<String>.unmodifiable(_templateScopes);

  String mountPaper({
    required int paperI,
    Map<String, dynamic> initialState = const <String, dynamic>{},
    bool notify = true,
  }) {
    final scope = paperScopeFor(paperI);
    _currentPaperScope = scope;
    _currentPaperI = paperI;
    autopilot.patchChrome(<String, dynamic>{
      'paper.scope': scope,
      'paper.i': paperI,
    });
    if (initialState.isNotEmpty) {
      autopilot.stateSet.patchPaper(scope, initialState);
    }
    if (notify) {
      autopilot.publishChange();
    }
    return scope;
  }

  String mountTemplate({
    required int paperI,
    required int templateI,
    Map<String, dynamic> initialState = const <String, dynamic>{},
    bool notify = true,
  }) {
    final scope = templateScopeFor(paperI: paperI, templateI: templateI);
    _templateScopes.add(scope);
    if (initialState.isNotEmpty) {
      autopilot.stateSet.patchTemplate(scope, initialState);
    }
    if (notify) {
      autopilot.publishChange();
    }
    return scope;
  }

  String mountCurrentTemplate({
    required int templateI,
    Map<String, dynamic> initialState = const <String, dynamic>{},
    bool notify = true,
  }) {
    final paperI = _currentPaperI;
    if (paperI == null) {
      throw StateError(
        'Cannot mount template $templateI without an active paper',
      );
    }
    return mountTemplate(
      paperI: paperI,
      templateI: templateI,
      initialState: initialState,
      notify: notify,
    );
  }

  String paperScopeFor(int paperI) {
    final routeScope = autopilot.currentRoute?.scopeKey ?? 'default';
    return 'paper.$routeScope.$paperI';
  }

  String templateScopeFor({required int paperI, required int templateI}) {
    final routeScope = autopilot.currentRoute?.scopeKey ?? 'default';
    return 'template.$routeScope.$paperI.$templateI';
  }

  T? paperState<T>(String scope, String key) =>
      autopilot.stateSet.getPaper<T>(scope, key);

  void setPaperState(
    String scope,
    String key,
    dynamic value, {
    bool notify = true,
  }) {
    autopilot.stateSet.setPaper(scope, key, value);
    if (notify) {
      autopilot.publishChange();
    }
  }

  void patchPaperState(
    String scope,
    Map<String, dynamic> values, {
    bool notify = true,
  }) {
    autopilot.stateSet.patchPaper(scope, values);
    if (notify) {
      autopilot.publishChange();
    }
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

  void clearPaperScope(String scope, {bool notify = true}) {
    autopilot.stateSet.clearPaper(scope);
    _templateScopes.removeWhere((String templateScope) {
      final prefix = scope.replaceFirst('paper.', 'template.');
      if (templateScope.startsWith(prefix)) {
        autopilot.stateSet.clearTemplate(templateScope);
        return true;
      }
      return false;
    });
    if (_currentPaperScope == scope) {
      _currentPaperScope = null;
      _currentPaperI = null;
      autopilot.patchChrome(<String, dynamic>{
        'paper.scope': null,
        'paper.i': null,
      });
    }
    if (notify) {
      autopilot.publishChange();
    }
  }

  void clearRoute({bool notify = true}) {
    if (_currentPaperScope != null) {
      autopilot.stateSet.clearPaper(_currentPaperScope!);
      _currentPaperScope = null;
    }

    for (final scope in _templateScopes.toList(growable: false)) {
      autopilot.stateSet.clearTemplate(scope);
    }
    _templateScopes.clear();

    autopilot.patchChrome(<String, dynamic>{
      'paper.scope': null,
      'paper.i': null,
    });
    _currentPaperI = null;

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
