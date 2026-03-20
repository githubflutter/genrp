import 'package:genrp/core/model/uschema/ux_action_model.dart';

class UxTodoSpec {
  const UxTodoSpec({
    required this.id,
    required this.type,
    required this.operation,
    required this.path,
    this.value,
    this.payloadKey,
    this.bind,
  });

  final String id;
  final String type;
  final String operation;
  final String path;
  final dynamic value;
  final String? payloadKey;
  final String? bind;

  factory UxTodoSpec.fromJson(Map<String, dynamic> json) {
    final valueSpec = json['value'];
    String? bind;
    String? payloadKey;
    dynamic value;

    if (valueSpec is Map<String, dynamic>) {
      bind = valueSpec['bind']?.toString();
      payloadKey = valueSpec['payload']?.toString();
      value = bind != null || payloadKey != null ? null : valueSpec['value'];
    } else {
      value = valueSpec;
    }

    return UxTodoSpec(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'data',
      operation: json['operation']?.toString() ?? 'set',
      path: json['path']?.toString() ?? '',
      value: value,
      payloadKey: payloadKey,
      bind: bind,
    );
  }
}

class UxActionSpec {
  const UxActionSpec({required this.model, required this.todos});

  final UxActionModel model;
  final List<UxTodoSpec> todos;

  int get id => model.i;
  String get name => model.s;
  String get label => model.n.isEmpty ? model.s : model.n;

  factory UxActionSpec.fromJson(Map<String, dynamic> json) {
    final todos = List<Object?>.from(json['todos'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => UxTodoSpec.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    return UxActionSpec(model: UxActionModel.fromJson(json), todos: todos);
  }

  static List<UxActionSpec> fromList(dynamic source) {
    final items = List<Object?>.from(source as List? ?? const []);
    return items
        .whereType<Map>()
        .map((item) => UxActionSpec.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
