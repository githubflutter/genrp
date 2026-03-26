import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/node_meta.dart';

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

  int registerrt({
    int? parentruntimeid,
    required NodeMeta meta,
    Map<String, dynamic> initial = const <String, dynamic>{},
    bool notify = true,
  }) {
    final rid = autopilot.stateSet.registerrt(
      parentruntimeid: parentruntimeid,
      meta: meta,
      initial: initial,
    );
    if (notify) autopilot.publishChange();
    return rid;
  }

  T? rt<T>(int runtimeid, String key) {
    return autopilot.stateSet.rt<T>(runtimeid, key);
  }

  void setrt(
    int runtimeid,
    String key,
    dynamic value, {
    bool notify = true,
  }) {
    autopilot.stateSet.setrt(runtimeid, key, value);
    if (notify) autopilot.publishChange();
  }

  void patchrt(
    int runtimeid,
    Map<String, dynamic> values, {
    bool notify = true,
  }) {
    autopilot.stateSet.patchrt(runtimeid, values);
    if (notify) autopilot.publishChange();
  }

  void clearrt(int runtimeid, {bool notify = true}) {
    autopilot.stateSet.clearrt(runtimeid);
    if (notify) autopilot.publishChange();
  }

  void clearallrt({bool notify = true}) {
    autopilot.stateSet.clearallrt();
    _currentAppId = null;
    _currentRouteId = null;
    _currentOptionalId = null;
    _currentRootTemplateI = null;
    if (notify) autopilot.publishChange();
  }

  void clearRoute({bool notify = true}) {
    clearallrt(notify: false);
    if (notify) {
      autopilot.publishChange();
    }
  }

  void clearAll({bool notify = true}) {
    clearRoute(notify: false);
    autopilot.stateSet.clearall();
    if (notify) {
      autopilot.publishChange();
    }
  }
}
