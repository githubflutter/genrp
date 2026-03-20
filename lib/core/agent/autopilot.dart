import 'package:flutter/foundation.dart';
import 'package:genrp/core/agent/copilot_data.dart';
import 'package:genrp/core/agent/copilot_ux.dart';
import 'package:genrp/core/base/x.dart';
import 'package:genrp/core/agent/data_set.dart';
import 'package:genrp/core/agent/state_set.dart';

abstract class Autopilot extends ChangeNotifier {
  Autopilot() {
    dataSet = DataSet();
    stateSet = StateSet();
    copilotData = CopilotData(this);
    copilotUX = CopilotUX(this);
  }

  late final CopilotData copilotData;
  late final CopilotUX copilotUX;
  late final DataSet dataSet;
  late final StateSet stateSet;
  final Map<int, String> _stateFieldPaths = {};
  final Map<int, String> _dataSourceFieldPaths = {};
  final Map<int, String> _dataSetFieldPaths = {};

  final Map<int, int> _dataSourceFieldSlots = {};
  final Map<int, int> _dataSetFieldSlots = {};

  int? _selectedHostId;
  int? _selectedBodyId;
  int? _selectedWidgetId;

  int? get selectedHostId => _selectedHostId;
  int? get selectedBodyId => _selectedBodyId;
  int? get selectedWidgetId => _selectedWidgetId;

  void clearSelectedUxIdentity({bool notify = true}) {
    if (_selectedHostId == null &&
        _selectedBodyId == null &&
        _selectedWidgetId == null) {
      return;
    }
    _selectedHostId = null;
    _selectedBodyId = null;
    _selectedWidgetId = null;
    if (notify) publishChange();
  }

  void selectUxIdentity({
    required int hostId,
    required int bodyId,
    required int widgetId,
    bool notify = true,
  }) {
    if (_selectedHostId == hostId &&
        _selectedBodyId == bodyId &&
        _selectedWidgetId == widgetId) {
      return;
    }
    _selectedHostId = hostId;
    _selectedBodyId = bodyId;
    _selectedWidgetId = widgetId;
    if (notify) publishChange();
  }

  bool isSelectedUxIdentity({
    required int hostId,
    required int bodyId,
    required int widgetId,
  }) {
    if (_selectedHostId == null ||
        _selectedBodyId == null ||
        _selectedWidgetId == null) {
      return false;
    }
    return _selectedHostId == hostId &&
        _selectedBodyId == bodyId &&
        _selectedWidgetId == widgetId;
  }

  String selectionStateKey({
    required int hostId,
    required int bodyId,
    int? widgetId,
  }) {
    if (widgetId == null) {
      return 'selection.$hostId.$bodyId';
    }
    return 'selection.$hostId.$bodyId.$widgetId';
  }

  String selectionSetStateKey({
    required int hostId,
    required int bodyId,
    int? widgetId,
  }) {
    if (widgetId == null) {
      return 'selections.$hostId.$bodyId';
    }
    return 'selections.$hostId.$bodyId.$widgetId';
  }

  int? selectedIndexFor({
    required int hostId,
    required int bodyId,
    int? widgetId,
  }) {
    final value = copilotUX.getValue(
      selectionStateKey(hostId: hostId, bodyId: bodyId, widgetId: widgetId),
    );
    return (value as num?)?.toInt();
  }

  void selectIndex({
    required int hostId,
    required int bodyId,
    required int index,
    int? widgetId,
    bool notify = true,
  }) {
    final key = selectionStateKey(
      hostId: hostId,
      bodyId: bodyId,
      widgetId: widgetId,
    );
    final current = copilotUX.getValue(key);
    if (current == index) return;
    copilotUX.setValue(key, index, notify: notify);
  }

  void clearSelectedIndex({
    required int hostId,
    required int bodyId,
    int? widgetId,
    bool notify = true,
  }) {
    final key = selectionStateKey(
      hostId: hostId,
      bodyId: bodyId,
      widgetId: widgetId,
    );
    if (copilotUX.getValue(key) == null) return;
    copilotUX.setValue(key, null, notify: notify);
  }

  bool isSelectedIndex({
    required int hostId,
    required int bodyId,
    required int index,
    int? widgetId,
  }) {
    return selectedIndexFor(
          hostId: hostId,
          bodyId: bodyId,
          widgetId: widgetId,
        ) ==
        index;
  }

  List<int> selectedIndexesFor({
    required int hostId,
    required int bodyId,
    int? widgetId,
  }) {
    final value = copilotUX.getValue(
      selectionSetStateKey(hostId: hostId, bodyId: bodyId, widgetId: widgetId),
    );
    if (value is List) {
      final result =
          value
              .whereType<num>()
              .map((item) => item.toInt())
              .toSet()
              .toList(growable: false)
            ..sort();
      return result;
    }
    return const <int>[];
  }

  void setSelectedIndexes({
    required int hostId,
    required int bodyId,
    required List<int> indexes,
    int? widgetId,
    bool notify = true,
  }) {
    final normalized = indexes.toSet().toList(growable: false)..sort();
    final key = selectionSetStateKey(
      hostId: hostId,
      bodyId: bodyId,
      widgetId: widgetId,
    );
    final current = selectedIndexesFor(
      hostId: hostId,
      bodyId: bodyId,
      widgetId: widgetId,
    );
    if (listEquals(current, normalized)) return;
    copilotUX.setValue(key, normalized, notify: notify);
  }

  void toggleSelectedIndex({
    required int hostId,
    required int bodyId,
    required int index,
    int? widgetId,
    bool notify = true,
  }) {
    final current = selectedIndexesFor(
      hostId: hostId,
      bodyId: bodyId,
      widgetId: widgetId,
    );
    final next = current.toSet();
    if (!next.add(index)) {
      next.remove(index);
    }
    setSelectedIndexes(
      hostId: hostId,
      bodyId: bodyId,
      widgetId: widgetId,
      indexes: next.toList(growable: false),
      notify: notify,
    );
  }

  void clearSelectedIndexes({
    required int hostId,
    required int bodyId,
    int? widgetId,
    bool notify = true,
  }) {
    final key = selectionSetStateKey(
      hostId: hostId,
      bodyId: bodyId,
      widgetId: widgetId,
    );
    final current = selectedIndexesFor(
      hostId: hostId,
      bodyId: bodyId,
      widgetId: widgetId,
    );
    if (current.isEmpty) return;
    copilotUX.setValue(key, const <int>[], notify: notify);
  }

  void clearFieldPaths() {
    _stateFieldPaths.clear();
    _dataSourceFieldPaths.clear();
    _dataSetFieldPaths.clear();
    _dataSourceFieldSlots.clear();
    _dataSetFieldSlots.clear();
  }

  void clearActions();

  void resetRuntime({
    bool clearData = true,
    bool clearUxState = true,
    bool clearActionRegistry = true,
    bool clearBindings = true,
    bool clearSelectionIdentity = true,
    bool notify = true,
  }) {
    if (clearActionRegistry) {
      clearActions();
    }
    if (clearData) {
      copilotData.clear(notify: false);
    }
    if (clearUxState) {
      copilotUX.clear(notify: false);
    }
    if (clearBindings) {
      clearFieldPaths();
    }
    if (clearSelectionIdentity) {
      clearSelectedUxIdentity(notify: false);
    }
    if (notify) {
      publishChange();
    }
  }

  dynamic resolve(String path) {
    if (path.startsWith('data.')) {
      return copilotData.getValue(path.substring(5));
    }
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

  void registerFieldSlot(int src, int fieldId, int slot) {
    switch (src) {
      case 1:
        _dataSourceFieldSlots[fieldId] = slot;
      case 2:
        _dataSetFieldSlots[fieldId] = slot;
    }
  }

  int? _resolveFieldSlot(int? src, int? fieldId) {
    if (src != null && fieldId != null) {
      return switch (src) {
        1 => _dataSourceFieldSlots[fieldId],
        2 => _dataSetFieldSlots[fieldId],
        _ => null,
      };
    }
    return null;
  }

  dynamic resolveFieldBinding({int? src, int? fieldId, String? fallbackPath}) {
    final slot = _resolveFieldSlot(src, fieldId);
    if (slot != null && (src == 1 || src == 2)) {
      final value = copilotData.getValue('x_row');
      if (value is X) {
        if (slot >= 0 && slot < value.v.length) {
          return value.v[slot];
        }
        return null;
      }
    }

    final resolvedPath = _resolveFieldPath(
      src: src,
      fieldId: fieldId,
      fallbackPath: fallbackPath,
    );
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
    final slot = _resolveFieldSlot(src, fieldId);
    if (slot != null && (src == 1 || src == 2)) {
      final xRow = copilotData.getValue('x_row');
      if (xRow is X) {
        if (slot >= 0 && slot < xRow.v.length) {
          xRow.v[slot] = value;
        } else {
          // If the list is too short, we pad it with nulls
          while (xRow.v.length <= slot) {
            xRow.v.add(null);
          }
          xRow.v[slot] = value;
        }
        publishChange();
        return;
      }
    }

    final resolvedPath = _resolveFieldPath(
      src: src,
      fieldId: fieldId,
      fallbackPath: fallbackPath,
    );
    if (resolvedPath == null || resolvedPath.isEmpty) return;
    updateBinding(resolvedPath, value);
  }

  String? _resolveFieldPath({int? src, int? fieldId, String? fallbackPath}) {
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

  Future<void> triggerActionById(int id, [dynamic payload]) async {}

  String actionLabelForId(int id) => '';

  bool hasAction(int id) => false;
}
