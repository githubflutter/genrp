import 'package:genrp/core/agent/autopilot.dart';

/// Minimal CopilotData that holds a reference to the parent `Autopilot`.
class CopilotData {
  final Autopilot autopilot;
  CopilotData(this.autopilot);

  dynamic getValue(String path) => autopilot.dataSet[path];

  void setValue(String path, dynamic value, {bool notify = true}) {
    autopilot.dataSet[path] = value;
    if (notify) autopilot.publishChange();
  }

  void patch(Map<String, dynamic> values, {bool notify = true}) {
    autopilot.dataSet.patch(values);
    if (notify) autopilot.publishChange();
  }
}
