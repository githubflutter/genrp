import 'package:genrp/core/agent/autopilot.dart';

/// Minimal CopilotUX that holds a reference to the parent `Autopilot`.
class CopilotUX {
  final Autopilot autopilot;
  CopilotUX(this.autopilot);

  dynamic getValue(String path) => autopilot.stateSet.get(path);

  void setValue(String path, dynamic value, {bool notify = true}) {
    autopilot.stateSet.set(path, value);
    if (notify) autopilot.publishChange();
  }

  void patch(Map<String, dynamic> values, {bool notify = true}) {
    autopilot.stateSet.patch(values);
    if (notify) autopilot.publishChange();
  }

  void clear({bool notify = true}) {
    autopilot.stateSet.clear();
    if (notify) autopilot.publishChange();
  }
}
