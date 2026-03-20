import 'package:genrp/core/model/uschema/ux_action_spec.dart';
import 'package:genrp/core/model/uschema/ux_registry.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';

class UxSpecDocument {
  const UxSpecDocument({
    required this.raw,
    required this.id,
    required this.toolbarTitle,
    required this.initialBody,
    required this.initialState,
    required this.initialData,
    required this.registry,
    required this.fieldBindings,
    required this.actions,
    required this.bodiesByName,
    required this.bodiesById,
  });

  final Map<String, dynamic> raw;
  final String id;
  final String toolbarTitle;
  final dynamic initialBody;
  final Map<String, dynamic> initialState;
  final Map<String, dynamic> initialData;
  final UxRegistry registry;
  final List<UxFieldBindingSpec> fieldBindings;
  final List<UxActionSpec> actions;
  final Map<String, UxTemplateSpec> bodiesByName;
  final Map<int, UxTemplateSpec> bodiesById;

  factory UxSpecDocument.fromJson(Map<String, dynamic> source) {
    final normalized = _normalizeSource(source);
    final registry = UxRegistry.fromSpec(normalized);
    final typesById = registry.types;
    final actions = UxActionSpec.fromList(normalized['actions']);
    final fieldBindings =
        List<Object?>.from(normalized['fieldBindings'] as List? ?? const [])
            .whereType<Map>()
            .map((item) {
              return UxFieldBindingSpec.fromJson(
                Map<String, dynamic>.from(item),
              );
            })
            .toList(growable: false);

    final bodiesByName = <String, UxTemplateSpec>{};
    final bodiesRaw = normalized['bodies'];
    if (bodiesRaw is Map) {
      final bodyMap = Map<String, dynamic>.from(bodiesRaw);
      for (final entry in bodyMap.entries) {
        if (entry.value is! Map) continue;
        final bodyJson = Map<String, dynamic>.from(entry.value as Map);
        final templateSpec = UxTemplateSpec.fromJson(
          bodyJson,
          bodyName: entry.key,
          typesById: typesById,
        );
        bodiesByName[entry.key] = templateSpec;
      }
    }

    if (bodiesByName.isEmpty) {
      final bodiesRegistry = List<Object?>.from(
        normalized['bodiesRegistry'] as List? ?? const [],
      );
      for (final item in bodiesRegistry.whereType<Map>()) {
        final bodyJson = Map<String, dynamic>.from(item);
        final bodyId = (bodyJson['id'] as num?)?.toInt();
        final name =
            bodyJson['name']?.toString() ??
            (bodyId == null ? 'body' : 'body_$bodyId');
        final templateSpec = UxTemplateSpec.fromJson(
          bodyJson,
          bodyName: name,
          typesById: typesById,
        );
        bodiesByName[name] = templateSpec;
      }
    }

    final bodiesById = <int, UxTemplateSpec>{};
    for (final entry in bodiesByName.entries) {
      if (entry.value.bodyId != 0) {
        bodiesById[entry.value.bodyId] = entry.value;
      }
    }

    final toolbar = Map<String, dynamic>.from(
      normalized['toolbar'] as Map? ?? const {},
    );
    return UxSpecDocument(
      raw: normalized,
      id:
          (normalized['id'] ??
                  normalized['name'] ??
                  toolbar['title'] ??
                  'ux-document')
              .toString(),
      toolbarTitle: toolbar['title']?.toString() ?? 'AIBook',
      initialBody: normalized['initialBody'],
      initialState: Map<String, dynamic>.from(
        normalized['initialState'] as Map? ?? const {},
      ),
      initialData: Map<String, dynamic>.from(
        normalized['initialData'] as Map? ?? const {},
      ),
      registry: registry,
      fieldBindings: fieldBindings,
      actions: actions,
      bodiesByName: bodiesByName,
      bodiesById: bodiesById,
    );
  }

  UxTemplateSpec? resolveBody(dynamic currentBodyValue) {
    if (currentBodyValue is num) {
      final byId = bodiesById[currentBodyValue.toInt()];
      if (byId != null) return byId;
    }
    if (currentBodyValue != null) {
      final byName = bodiesByName[currentBodyValue.toString()];
      if (byName != null) return byName;
    }
    if (initialBody is num) {
      final byId = bodiesById[(initialBody as num).toInt()];
      if (byId != null) return byId;
    }
    if (initialBody != null) {
      return bodiesByName[initialBody.toString()];
    }
    return null;
  }

  static Map<String, dynamic> _normalizeSource(Map<String, dynamic> source) {
    final normalized = Map<String, dynamic>.from(source);
    final registry = source['registry'];
    if (registry is Map) {
      final registryMap = Map<String, dynamic>.from(registry);
      for (final entry in registryMap.entries) {
        if (entry.key == 'bodies') continue;
        normalized.putIfAbsent(entry.key, () => entry.value);
      }
      final registryBodies = registryMap['bodies'];
      if (registryBodies is List && !normalized.containsKey('bodiesRegistry')) {
        normalized['bodiesRegistry'] = registryBodies;
      }
    }
    final topLevelBodies = normalized['bodies'];
    if (topLevelBodies is List && !normalized.containsKey('bodiesRegistry')) {
      normalized['bodiesRegistry'] = topLevelBodies;
    }
    return normalized;
  }
}
