import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/mock_transport.dart';
import 'package:genrp/core/base/x.dart';
import 'package:genrp/core/model/uschema/ux_action_spec.dart';
import 'package:genrp/core/model/uschema/ux_document_spec.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';

/// Minimal concrete Autopilot implementation used by the app.
class AutopilotGo extends Autopilot {
  AutopilotGo();

  String? _loadedSpecId;
  UxSpecDocument? loadedSpec;
  String? specError;
  final Map<int, UxActionSpec> _actionsById = <int, UxActionSpec>{};

  @override
  void clearActions() {
    _actionsById.clear();
  }

  void configureSpec(dynamic specInput) {
    final spec = specInput is UxSpecDocument
        ? specInput
        : UxSpecDocument.fromJson(Map<String, dynamic>.from(specInput as Map));
    final nextSpecId = spec.id;
    if (_loadedSpecId == nextSpecId) return;

    _loadedSpecId = nextSpecId;
    loadedSpec = spec;
    specError = null;

    final error = _validateSpec(spec);
    if (error != null) {
      specError = error;
      Future.microtask(() => publishChange());
      return;
    }

    resetRuntime(notify: false);
    _configureFieldBindings(spec);

    final initialData = Map<String, dynamic>.from(spec.initialData);
    if (initialData.containsKey('x_row') && initialData['x_row'] is Map) {
      initialData['x_row'] = X.fromJson(
        Map<String, dynamic>.from(initialData['x_row']),
      );
    }
    copilotData.patch(initialData, notify: false);
    copilotUX.patch(spec.initialState, notify: false);

    final actions = spec.actions;
    for (final action in actions) {
      if (action.id == 0) continue;
      _actionsById[action.id] = action;
    }
  }

  @override
  Future<void> triggerActionById(int id, [dynamic payload]) async {
    final action = _actionsById[id];
    if (action == null) return;
    await _runAction(action, payload);
  }

  @override
  String actionLabelForId(int id) {
    final action = _actionsById[id];
    if (action == null) return '';
    return action.label;
  }

  @override
  bool hasAction(int id) => _actionsById.containsKey(id);

  void _configureFieldBindings(UxSpecDocument spec) {
    for (final binding in spec.fieldBindings) {
      if (binding.slot != null) {
        registerFieldSlot(binding.src, binding.fieldId, binding.slot!);
      }
      if (binding.path.isNotEmpty) {
        registerFieldPath(binding.src, binding.fieldId, binding.path);
      }
    }
  }

  String? _validateSpec(UxSpecDocument spec) {
    final raw = spec.raw;

    String? checkDuplicates(String key) {
      final list = List<Object?>.from(raw[key] ?? []);
      final seenIds = <int>{};
      for (final item in list.whereType<Map>()) {
        final id = (item['id'] as num?)?.toInt();
        if (id != null) {
          if (!seenIds.add(id)) return 'Duplicate id $id found in $key';
        }
      }
      return null;
    }

    final e1 = checkDuplicates('bodiesRegistry');
    if (e1 != null) return e1;
    final e2 = checkDuplicates('widgets');
    if (e2 != null) return e2;

    // Validate fieldBindings: must have src and fieldId
    final bindings = List<Object?>.from(raw['fieldBindings'] as List? ?? []);
    for (final item in bindings.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      final src = (map['src'] as num?)?.toInt();
      final fieldId =
          (map['fieldId'] as num?)?.toInt() ?? (map['f'] as num?)?.toInt();
      if (src == null || fieldId == null) {
        return 'fieldBinding missing src or fieldId';
      }
    }

    final actionIds = spec.actions.map((action) => action.id).toSet();
    final typeIds = spec.registry.types.keys.toSet();

    String? validateNode(UxNodeSpec node, {required bool isRoot}) {
      final typeId = node.typeId;
      if (typeId != null && !typeIds.contains(typeId)) {
        return 'Invalid typeId $typeId in ${isRoot ? 'body' : 'body child'}';
      }

      final actionId = node.actionId;
      if (actionId != 0 && !actionIds.contains(actionId)) {
        return 'Invalid actionId $actionId in body child';
      }

      for (final child in node.children) {
        final error = validateNode(child, isRoot: false);
        if (error != null) return error;
      }

      return null;
    }

    for (final body in spec.bodiesByName.values) {
      final templateTypeId = body.templateTypeId;
      if (!UxTemplateType.known.contains(templateTypeId)) {
        return 'Unknown template type $templateTypeId in body';
      }

      for (final modeId in body.modeIds) {
        if (!UxTemplateMode.known.contains(modeId)) {
          return 'Unknown template mode $modeId in body';
        }
        if (!UxTemplateSpec.isModeSupportedByType(templateTypeId, modeId)) {
          return 'Mode $modeId is not supported by template type $templateTypeId';
        }
      }

      final bodyError = validateNode(body.root, isRoot: true);
      if (bodyError != null) {
        return bodyError;
      }

      final checkboxError = body.checkbox == null
          ? null
          : validateNode(body.checkbox!, isRoot: false);
      if (checkboxError != null) {
        return checkboxError;
      }

      for (final center in body.actionCenters.values) {
        for (final actionId in center.actionIds) {
          if (!actionIds.contains(actionId)) {
            return 'Invalid actionId $actionId in action center';
          }
        }
      }
    }

    return null;
  }

  Future<void> _runAction(UxActionSpec action, dynamic payload) async {
    if (action.name == 'saveBook') {
      final xRow = copilotData.getValue('x_row');
      if (xRow is X) {
        final savedRow = await MockTransport.saveRow(xRow);
        copilotData.setValue('x_row', savedRow);
      }
    }

    for (final todo in action.todos) {
      await _runTodo(todo, payload);
    }
  }

  Future<void> _runTodo(UxTodoSpec todo, dynamic payload) async {
    if (todo.operation != 'set' || todo.path.isEmpty) return;

    dynamic value;
    if (todo.bind != null) {
      value = resolve(todo.bind!);
    } else if (todo.payloadKey != null && payload is Map) {
      value = payload[todo.payloadKey];
    } else {
      value = todo.value;
    }

    if (todo.type == 'data') {
      copilotData.setValue(todo.path, value);
      return;
    }

    if (todo.type == 'ux' || todo.type == 'state') {
      copilotUX.setValue(todo.path, value);
    }
  }
}
