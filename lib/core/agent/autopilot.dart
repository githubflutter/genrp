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
  final Map<int, String> _stateFieldPaths = {};
  final Map<int, String> _dataSourceFieldPaths = {};
  final Map<int, String> _dataSetFieldPaths = {};

  dynamic resolve(String path) {
    if (path.startsWith('data.')) return copilotData.getValue(path.substring(5));
    if (path.startsWith('ux.')) return copilotUX.getValue(path.substring(3));
    if (path.startsWith('state.')) return copilotUX.getValue(path.substring(6));
    return copilotData.getValue(path);
  }

  void registerFieldPath(int src, int fieldId, String path) {
    if (path.isEmpty) return;
    switch (src) {
      case 0:
        _stateFieldPaths[fieldId] = path;
      case 1:
        _dataSourceFieldPaths[fieldId] = path;
      case 2:
        _dataSetFieldPaths[fieldId] = path;
    }
  }

  dynamic resolveFieldBinding({
    int? src,
    int? fieldId,
    String? fallbackPath,
  }) {
    final resolvedPath = _resolveFieldPath(src: src, fieldId: fieldId, fallbackPath: fallbackPath);
    if (resolvedPath == null || resolvedPath.isEmpty) return null;
    return resolve(resolvedPath);
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

  void updateFieldBinding({
    int? src,
    int? fieldId,
    String? fallbackPath,
    required dynamic value,
  }) {
    final resolvedPath = _resolveFieldPath(src: src, fieldId: fieldId, fallbackPath: fallbackPath);
    if (resolvedPath == null || resolvedPath.isEmpty) return;
    updateBinding(resolvedPath, value);
  }

  String? _resolveFieldPath({
    int? src,
    int? fieldId,
    String? fallbackPath,
  }) {
    if (src != null && fieldId != null) {
      final path = switch (src) {
        0 => _stateFieldPaths[fieldId],
        1 => _dataSourceFieldPaths[fieldId],
        2 => _dataSetFieldPaths[fieldId],
        _ => null,
      };
      if (path != null && path.isNotEmpty) return path;
    }
    return fallbackPath;
  }

  void publishChange() => notifyListeners();

  Future<void> triggerAction(String name, [dynamic payload]) => actionSet.invoke(name, payload);

  Future<void> triggerActionById(int id, [dynamic payload]) => actionSet.invokeById(id, payload);
}
