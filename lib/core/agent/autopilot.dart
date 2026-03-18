import 'package:flutter/foundation.dart';
import 'package:genrp/core/agent/copilot_data.dart';
import 'package:genrp/core/agent/copilot_ux.dart';
import 'package:genrp/core/agent/data_set.dart';
import 'package:genrp/core/agent/state_set.dart';
import 'package:genrp/core/agent/action_set.dart';

abstract class Autopilot extends ChangeNotifier {
  Autopilot() {
    dataSet = DataSet();
    stateSet = StateSet();
    actionSet = ActionSet();
    copilotData = CopilotData(this);
    copilotUX = CopilotUX(this);
  }

  late final CopilotData copilotData;
  late final CopilotUX copilotUX;
  late final DataSet dataSet;
  late final StateSet stateSet;
  late final ActionSet actionSet;

  dynamic resolve(String path) {
    if (path.startsWith('data.')) return copilotData.getValue(path.substring(5));
    if (path.startsWith('ux.')) return copilotUX.getValue(path.substring(3));
    if (path.startsWith('state.')) return copilotUX.getValue(path.substring(6));
    return copilotData.getValue(path);
  }

  void updateBinding(String path, dynamic value) {
    if (path.startsWith('data.')) {
      copilotData.setValue(path.substring(5), value);
      return;
    }
    if (path.startsWith('ux.')) {
      copilotUX.setValue(path.substring(3), value);
      return;
    }
    if (path.startsWith('state.')) {
      copilotUX.setValue(path.substring(6), value);
      return;
    }
    copilotData.setValue(path, value);
  }

  void publishChange() => notifyListeners();

  Future<void> triggerAction(String name, [dynamic payload]) => actionSet.invoke(name, payload);
}
