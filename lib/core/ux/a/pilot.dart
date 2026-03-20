import 'package:flutter/foundation.dart';
import 'package:genrp/core/agent/data_set.dart';
import 'package:genrp/core/ux/a/action_registry.dart';
import 'package:genrp/core/ux/a/route.dart';
import 'package:genrp/core/ux/a/state_set.dart';

class UxPilot extends ChangeNotifier {
  UxPilot({this.v, this.f, this.c, this.usr, this.user});

  final DataSet dataSet = DataSet();
  final UxStateSet stateSet = UxStateSet();
  final UxActionRegistry actions = UxActionRegistry();

  String? v;
  String? f;
  String? c;
  Object? usr;
  Object? user;

  UxRoute? _currentRoute;
  String? _currentPaperScope;
  int? _currentPaperI;
  final Set<String> _templateScopes = <String>{};

  UxRoute? get currentRoute => _currentRoute;
  String? get currentPaperScope => _currentPaperScope;
  int? get currentPaperI => _currentPaperI;
  Set<String> get currentTemplateScopes =>
      Set<String>.unmodifiable(_templateScopes);

  void setContext({
    String? v,
    String? f,
    String? c,
    Object? usr,
    Object? user,
    bool notify = true,
  }) {
    this.v = v ?? this.v;
    this.f = f ?? this.f;
    this.c = c ?? this.c;
    this.usr = usr ?? this.usr;
    this.user = user ?? this.user;
    if (notify) {
      notifyListeners();
    }
  }

  void navigate(String rawRoute, {bool notify = true}) {
    mountRoute(UxRoute.parse(rawRoute), notify: notify);
  }

  void mountRoute(UxRoute route, {bool notify = true}) {
    clearRoute(notify: false);
    _currentRoute = route;
    stateSet.patchChrome(<String, dynamic>{
      'route.path': route.path,
      'route.scope': route.scopeKey,
      'route.app': route.appName,
      'route.pageSpecId': route.pageSpecId,
      'route.optionalId': route.optionalId,
    });
    if (notify) {
      notifyListeners();
    }
  }

  String mountPaper({
    required int paperI,
    Map<String, dynamic> initialState = const <String, dynamic>{},
    bool notify = true,
  }) {
    final scope = paperScopeFor(paperI);
    _currentPaperScope = scope;
    _currentPaperI = paperI;
    stateSet.patchChrome(<String, dynamic>{
      'paper.scope': scope,
      'paper.i': paperI,
    });
    if (initialState.isNotEmpty) {
      stateSet.patchPaper(scope, initialState);
    }
    if (notify) {
      notifyListeners();
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
      stateSet.patchTemplate(scope, initialState);
    }
    if (notify) {
      notifyListeners();
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
    final routeScope = _currentRoute?.scopeKey ?? 'default';
    return 'paper.$routeScope.$paperI';
  }

  String templateScopeFor({required int paperI, required int templateI}) {
    final routeScope = _currentRoute?.scopeKey ?? 'default';
    return 'template.$routeScope.$paperI.$templateI';
  }

  T? paperState<T>(String scope, String key) =>
      stateSet.getPaper<T>(scope, key);

  void setPaperState(
    String scope,
    String key,
    dynamic value, {
    bool notify = true,
  }) {
    stateSet.setPaper(scope, key, value);
    if (notify) {
      notifyListeners();
    }
  }

  void patchPaperState(
    String scope,
    Map<String, dynamic> values, {
    bool notify = true,
  }) {
    stateSet.patchPaper(scope, values);
    if (notify) {
      notifyListeners();
    }
  }

  T? templateState<T>(String scope, String key) =>
      stateSet.getTemplate<T>(scope, key);

  void setTemplateState(
    String scope,
    String key,
    dynamic value, {
    bool notify = true,
  }) {
    stateSet.setTemplate(scope, key, value);
    if (notify) {
      notifyListeners();
    }
  }

  void patchTemplateState(
    String scope,
    Map<String, dynamic> values, {
    bool notify = true,
  }) {
    stateSet.patchTemplate(scope, values);
    if (notify) {
      notifyListeners();
    }
  }

  dynamic data(String key) => dataSet[key];

  void setData(String key, dynamic value, {bool notify = true}) {
    dataSet[key] = value;
    if (notify) {
      notifyListeners();
    }
  }

  void patchData(Map<String, dynamic> values, {bool notify = true}) {
    dataSet.patch(values);
    if (notify) {
      notifyListeners();
    }
  }

  void clearTemplateScope(String scope, {bool notify = true}) {
    stateSet.clearTemplate(scope);
    _templateScopes.remove(scope);
    if (notify) {
      notifyListeners();
    }
  }

  void clearPaperScope(String scope, {bool notify = true}) {
    stateSet.clearPaper(scope);
    _templateScopes.removeWhere((String templateScope) {
      final prefix = scope.replaceFirst('paper.', 'template.');
      if (templateScope.startsWith(prefix)) {
        stateSet.clearTemplate(templateScope);
        return true;
      }
      return false;
    });
    if (_currentPaperScope == scope) {
      _currentPaperScope = null;
      _currentPaperI = null;
      stateSet.patchChrome(<String, dynamic>{
        'paper.scope': null,
        'paper.i': null,
      });
    }
    if (notify) {
      notifyListeners();
    }
  }

  void clearRoute({bool notify = true}) {
    if (_currentPaperScope != null) {
      stateSet.clearPaper(_currentPaperScope!);
      _currentPaperScope = null;
    }

    for (final scope in _templateScopes.toList(growable: false)) {
      stateSet.clearTemplate(scope);
    }
    _templateScopes.clear();

    stateSet.patchChrome(<String, dynamic>{
      'route.path': null,
      'route.scope': null,
      'route.app': null,
      'route.pageSpecId': null,
      'route.optionalId': null,
      'paper.scope': null,
      'paper.i': null,
    });
    _currentRoute = null;
    _currentPaperI = null;

    if (notify) {
      notifyListeners();
    }
  }

  void clearAll({bool notify = true}) {
    clearRoute(notify: false);
    dataSet.clear();
    stateSet.clear();
    actions.clear();
    if (notify) {
      notifyListeners();
    }
  }
}
