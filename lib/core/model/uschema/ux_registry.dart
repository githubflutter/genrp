class UxRegistry {
  const UxRegistry({
    required this.hosts,
    required this.bodies,
    required this.templates,
    required this.templateModes,
    required this.types,
    required this.widgets,
  });

  final Map<int, String> hosts;
  final Map<int, String> bodies;
  final Map<int, String> templates;
  final Map<int, String> templateModes;
  final Map<int, String> types;
  final Map<int, String> widgets;

  factory UxRegistry.fromSpec(Map<String, dynamic> spec) {
    return UxRegistry(
      hosts: _indexById(spec['hosts']),
      bodies: _indexById(
        spec['bodiesRegistry'] ??
            spec['bodiesList'] ??
            spec['bodiesMeta'] ??
            spec['bodies'],
      ),
      templates: _indexById(spec['templates']),
      templateModes: _indexById(spec['templateModes']),
      types: _indexById(spec['types']),
      widgets: _indexById(spec['widgets']),
    );
  }

  String? hostName(int? id) => id == null ? null : hosts[id];

  String? bodyName(int? id) => id == null ? null : bodies[id];

  String? templateName(int? id) => id == null ? null : templates[id];

  String? templateModeName(int? id) => id == null ? null : templateModes[id];

  String? typeName(int? id) => id == null ? null : types[id];

  String? widgetName(int? id) => id == null ? null : widgets[id];

  static Map<int, String> _indexById(dynamic source) {
    if (source is! List) return const {};
    final items = List<Object?>.from(source);
    final result = <int, String>{};
    for (final item in items.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      final id = (map['id'] as num?)?.toInt();
      final name = map['name']?.toString();
      if (id == null || name == null || name.isEmpty) continue;
      result[id] = name;
    }
    return result;
  }
}
