/// Typed model for a single todo item.
class Todo {
  const Todo({
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

  factory Todo.fromMap(Map<String, dynamic> map) {
    final valueSpec = map['value'];
    String? bind;
    String? payloadKey;
    dynamic value;

    if (valueSpec is Map<String, dynamic>) {
      bind = valueSpec['bind']?.toString();
      payloadKey = valueSpec['payload']?.toString();
      value = bind != null ? null : payloadKey != null ? null : valueSpec['value'];
    } else {
      value = valueSpec;
    }

    return Todo(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? 'data',
      operation: map['operation']?.toString() ?? 'set',
      path: map['path']?.toString() ?? '',
      value: value,
      payloadKey: payloadKey,
      bind: bind,
    );
  }
}

/// Typed model for an action with ordered todos.
class Action {
  const Action({
    required this.id,
    required this.name,
    required this.todos,
  });

  final int id;
  final String name;
  final List<Todo> todos;

  static List<Action> fromList(dynamic source) {
    final items = List<Object?>.from(source as List? ?? const []);
    return items
        .whereType<Map>()
        .map((item) => Action.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  factory Action.fromMap(Map<String, dynamic> map) {
    final todos = List<Object?>.from(map['todos'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Todo.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    return Action(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name']?.toString() ?? '',
      todos: todos,
    );
  }
}
