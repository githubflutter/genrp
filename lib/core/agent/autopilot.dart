import 'package:flutter/foundation.dart';
import 'package:genrp/core/agent/copilot_data.dart';
import 'package:genrp/core/agent/copilot_ux.dart';
import 'package:genrp/core/agent/data_set.dart';
import 'package:genrp/core/agent/state_set.dart';
import 'package:genrp/core/model/uschema/uschema.dart';

class Autopilot extends ChangeNotifier {
  Autopilot({this.v, this.f, this.c, this.usr, this.user}) {
    data = CopilotData(this);
    state = CopilotUx(this);
  }

  final DataSet dataSet = DataSet();
  final StateSet stateSet = StateSet();

  late final CopilotData data;
  late final CopilotUx state;

  String? v;
  String? f;
  String? c;
  Object? usr;
  Object? user;

  UxRouteSpec? _currentRoute;
  UxRouteSpec? get currentRoute => _currentRoute;

  void mountRoute(UxRouteSpec route, {bool notify = true}) {
    clearRoute(notify: false);
    _currentRoute = route;
    stateSet.patchChrome(<String, dynamic>{
      'route.path': route.path,
      'route.scope': route.scopeKey,
      'route.app': route.appName,
      'route.id': route.id,
      'route.optionalId': route.optionalId,
    });
    if (notify) {
      notifyListeners();
    }
  }

  void clearRoute({bool notify = true}) {
    state.clearRoute(notify: false);
    stateSet.patchChrome(<String, dynamic>{
      'route.path': null,
      'route.scope': null,
      'route.app': null,
      'route.id': null,
      'route.optionalId': null,
    });
    _currentRoute = null;
    if (notify) {
      notifyListeners();
    }
  }

  void setChrome(String key, dynamic value, {bool notify = true}) {
    stateSet.setChrome(key, value);
    if (notify) {
      notifyListeners();
    }
  }

  void patchChrome(Map<String, dynamic> values, {bool notify = true}) {
    stateSet.patchChrome(values);
    if (notify) {
      notifyListeners();
    }
  }

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

  void clearAll({bool notify = true}) {
    clearRoute(notify: false);
    state.clearAll(notify: false);
    data.clear(notify: false);
    if (notify) {
      notifyListeners();
    }
  }

  void publishChange() => notifyListeners();
}
