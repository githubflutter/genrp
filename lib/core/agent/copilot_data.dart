import 'package:genrp/core/agent/autopilot.dart';

class CopilotData {
  CopilotData(this.autopilot);

  final Autopilot autopilot;

  dynamic operator [](String key) => autopilot.dataSet[key];
  T? get<T>(String key) => autopilot.dataSet.get<T>(key);

  void set(String key, dynamic value, {bool notify = true}) {
    autopilot.dataSet[key] = value;
    if (notify) autopilot.publishChange();
  }

  void patch(Map<String, dynamic> values, {bool notify = true}) {
    autopilot.dataSet.patch(values);
    if (notify) autopilot.publishChange();
  }

  Map<String, dynamic> snapshot() => autopilot.dataSet.snapshot();

  void clear({bool notify = true}) {
    autopilot.dataSet.clear();
    if (notify) autopilot.publishChange();
  }
}
