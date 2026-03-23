import 'package:genrp/core/model/uschema/ux_app_spec.dart';
import 'package:genrp/core/model/uschema/ux_action_holder_spec.dart';
import 'package:genrp/core/model/uschema/ux_field_spec.dart';
import 'package:genrp/core/model/uschema/ux_route_spec.dart';
import 'package:genrp/core/model/uschema/ux_template_action_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

class UxWorkspaceMeta {
  const UxWorkspaceMeta({
    this.collectionTitle = 'Collection',
    this.collectionColumns = const <String>[],
    this.collectionRows = const <List<Object?>>[],
    this.collectionViewModes = const <int>[3],
    this.properties = const <String, Object?>{},
    this.formFields = const <UxFieldSpec>[],
    this.summaryText = '',
    this.emptyTitle = 'No selection',
    this.emptyMessage = 'Choose an item from the collection to inspect it.',
    this.defaultAlertMessage = 'Something needs your attention.',
    this.collectionFlex = 7,
    this.detailFlex = 5,
    this.actions = const <UxTemplateActionSpec>[],
    this.actionHolders = const <UxActionHolderSpec>[],
  });

  final String collectionTitle;
  final List<String> collectionColumns;
  final List<List<Object?>> collectionRows;
  final List<int> collectionViewModes;
  final Map<String, Object?> properties;
  final List<UxFieldSpec> formFields;
  final String summaryText;
  final String emptyTitle;
  final String emptyMessage;
  final String defaultAlertMessage;
  final int collectionFlex;
  final int detailFlex;
  final List<UxTemplateActionSpec> actions;
  final List<UxActionHolderSpec> actionHolders;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'collectionTitle': collectionTitle,
    'collectionColumns': collectionColumns,
    'collectionRows': collectionRows,
    'collectionViewModes': collectionViewModes,
    'properties': properties,
    'formFields': formFields
        .map((field) => <String, dynamic>{
              'label': field.label,
              'hint': field.hint,
              'width': field.width,
              'dataTypeId': field.dataTypeId,
              'fieldMode': field.fieldMode?.name,
            })
        .toList(growable: false),
    'summaryText': summaryText,
    'emptyTitle': emptyTitle,
    'emptyMessage': emptyMessage,
    'defaultAlertMessage': defaultAlertMessage,
    'collectionFlex': collectionFlex,
    'detailFlex': detailFlex,
    'actions': actions.map((action) => action.toJson()).toList(growable: false),
    'actionHolders': actionHolders.map((holder) => holder.toJson()).toList(growable: false),
  };

  factory UxWorkspaceMeta.fromJson(Map<String, dynamic> json) {
    return UxWorkspaceMeta(
      collectionTitle: json['collectionTitle'] as String? ?? 'Collection',
      collectionColumns: (json['collectionColumns'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const <String>[],
      collectionRows: (json['collectionRows'] as List<dynamic>?)
              ?.map((row) => (row as List).cast<Object?>())
              .toList(growable: false) ??
          const <List<Object?>>[],
      collectionViewModes: (json['collectionViewModes'] as List<dynamic>?)
              ?.map((item) => (item as num).toInt())
              .toList(growable: false) ??
          const <int>[3],
      properties: (json['properties'] as Map<dynamic, dynamic>?)
              ?.map((key, value) => MapEntry(key.toString(), value)) ??
          const <String, Object?>{},
      formFields: (json['formFields'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (field) => UxFieldSpec(
                  label: field['label']?.toString() ?? '',
                  hint: field['hint']?.toString() ?? '',
                  width: (field['width'] as num?)?.toDouble() ?? 260,
                  dataTypeId: (field['dataTypeId'] as num?)?.toInt(),
                  fieldMode: UwFieldMode.fromJsonValue(field['fieldMode']),
                ),
              )
              .toList(growable: false) ??
          const <UxFieldSpec>[],
      summaryText: json['summaryText'] as String? ?? '',
      emptyTitle: json['emptyTitle'] as String? ?? 'No selection',
      emptyMessage: json['emptyMessage'] as String? ??
          'Choose an item from the collection to inspect it.',
      defaultAlertMessage: json['defaultAlertMessage'] as String? ??
          'Something needs your attention.',
      collectionFlex: (json['collectionFlex'] as num?)?.toInt() ?? 7,
      detailFlex: (json['detailFlex'] as num?)?.toInt() ?? 5,
      actions: (json['actions'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((action) => UxTemplateActionSpec.fromJson(_stringDynamicMap(action)))
              .toList(growable: false) ??
          const <UxTemplateActionSpec>[],
      actionHolders: (json['actionHolders'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((holder) => UxActionHolderSpec.fromJson(_stringDynamicMap(holder)))
              .toList(growable: false) ??
          const <UxActionHolderSpec>[],
    );
  }
}

class UxSpec {
  const UxSpec({
    required this.i,
    this.a = true,
    this.d = 0,
    this.e = 0,
    required this.n,
    required this.t,
    required this.l,
    this.m = const <String, dynamic>{},
    this.s = const <String, dynamic>{},
    this.uxzones = const <String, List<UxSpec>>{},
  });

  factory UxSpec.paper({
    required int i,
    required int t,
    required String n,
    Map<String, dynamic> m = const <String, dynamic>{},
    Map<String, dynamic> s = const <String, dynamic>{},
    Map<String, List<UxSpec>> uxzones = const <String, List<UxSpec>>{},
  }) {
    return UxSpec(
      i: i,
      n: n,
      t: t,
      l: UxLayer.paper.code,
      m: m,
      s: s,
      uxzones: uxzones,
    );
  }

  factory UxSpec.template({
    required int i,
    required int t,
    required String n,
    Map<String, dynamic> m = const <String, dynamic>{},
    Map<String, dynamic> s = const <String, dynamic>{},
    Map<String, List<UxSpec>> uxzones = const <String, List<UxSpec>>{},
  }) {
    return UxSpec(
      i: i,
      n: n,
      t: t,
      l: UxLayer.template.code,
      m: m,
      s: s,
      uxzones: uxzones,
    );
  }

  factory UxSpec.uwidget({
    required int i,
    required int t,
    required String n,
    Map<String, dynamic> m = const <String, dynamic>{},
    Map<String, dynamic> s = const <String, dynamic>{},
    Map<String, List<UxSpec>> uxzones = const <String, List<UxSpec>>{},
  }) {
    return UxSpec(
      i: i,
      n: n,
      t: t,
      l: UxLayer.uwidget.code,
      m: m,
      s: s,
      uxzones: uxzones,
    );
  }

  final int i;
  final bool a;
  final int d;
  final int e;
  final String n;
  final int t;
  final int l;
  final Map<String, dynamic> m;
  final Map<String, dynamic> s;
  final Map<String, List<UxSpec>> uxzones;

  String stringMeta(String key, {String fallback = ''}) {
    final value = m[key];
    return value is String ? value : fallback;
  }

  int intMeta(String key, {int fallback = 0}) {
    final value = m[key];
    return value is num ? value.toInt() : fallback;
  }

  List<int> intListMeta(String key, {List<int> fallback = const <int>[]}) {
    final value = m[key];
    if (value is! List) return fallback;
    return value.map((item) => (item as num).toInt()).toList(growable: false);
  }

  List<String> stringListMeta(String key) {
    final value = m[key];
    if (value is! List) return const <String>[];
    return value.map((item) => item.toString()).toList(growable: false);
  }

  List<List<Object?>> rowsMeta(String key) {
    final value = m[key];
    if (value is! List) return const <List<Object?>>[];
    return value.map((row) => (row as List).cast<Object?>()).toList(growable: false);
  }

  Map<String, Object?> objectMapMeta(String key) {
    final value = m[key];
    if (value is! Map) return const <String, Object?>{};
    return value.map((mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue));
  }

  List<UxFieldSpec> fieldSpecs(String key) {
    final raw = m[key];
    if (raw is! List) return const <UxFieldSpec>[];
    return raw
        .whereType<Map>()
        .map(
          (field) => UxFieldSpec(
            label: field['label']?.toString() ?? '',
            hint: field['hint']?.toString() ?? '',
            width: (field['width'] as num?)?.toDouble() ?? 260,
            dataTypeId: (field['dataTypeId'] as num?)?.toInt(),
            fieldMode: UwFieldMode.fromJsonValue(field['fieldMode']),
          ),
        )
        .toList(growable: false);
  }

  List<UxTemplateActionSpec> templateActions(String key) {
    final raw = m[key];
    if (raw is! List) return const <UxTemplateActionSpec>[];
    return raw
        .whereType<Map>()
        .map((action) => UxTemplateActionSpec.fromJson(_stringDynamicMap(action)))
        .toList(growable: false);
  }

  UxWorkspaceMeta workspaceMeta() => UxWorkspaceMeta.fromJson(m);

  List<UxActionHolderSpec> actionHolders(String key) {
    final raw = m[key];
    if (raw is! List) return const <UxActionHolderSpec>[];
    return raw
        .whereType<Map>()
        .map((holder) => UxActionHolderSpec.fromJson(_stringDynamicMap(holder)))
        .toList(growable: false);
  }

  List<UxSpec> childrenInUxZone(String uxzone) => uxzones[uxzone] ?? const <UxSpec>[];

  UxSpec? firstChildInUxZone(String uxzone) {
    final items = childrenInUxZone(uxzone);
    return items.isEmpty ? null : items.first;
  }

  UxSpec? firstChildOfLayerInUxZone(UxLayer layer, {String? uxzone}) {
    final groups = uxzone == null ? uxzones.values : <List<UxSpec>>[childrenInUxZone(uxzone)];
    for (final group in groups) {
      for (final child in group) {
        if (child.l == layer.code) return child;
      }
    }
    return null;
  }

  List<UxSpec> childrenOfLayerInUxZone(UxLayer layer, {String? uxzone}) {
    final matches = <UxSpec>[];
    final groups = uxzone == null ? uxzones.values : <List<UxSpec>>[childrenInUxZone(uxzone)];
    for (final group in groups) {
      for (final child in group) {
        if (child.l == layer.code) {
          matches.add(child);
        }
      }
    }
    return matches;
  }

  int get style => intMeta('style');
}

Map<String, dynamic> _stringDynamicMap(Map raw) {
  return raw.map((key, value) => MapEntry(key.toString(), value));
}

extension UxAppSpecAdapter on UxAppSpec {
  UxSpec toUxSpec({Map<String, List<UxSpec>> uxzones = const <String, List<UxSpec>>{}}) {
    return UxSpec(
      i: i,
      a: a,
      d: d,
      e: e,
      n: n,
      t: t,
      l: l,
      m: <String, dynamic>{...m, 'shellName': shellName},
      s: const <String, dynamic>{},
      uxzones: uxzones,
    );
  }
}

extension UxRouteSpecAdapter on UxRouteSpec {
  UxSpec toUxSpec() {
    return UxSpec(
      i: pageSpecId,
      n: appName,
      t: pageSpecId,
      l: l,
      m: <String, dynamic>{
        ...meta.toJson(),
        'path': path,
        'scopeKey': scopeKey,
        if (optionalId != null) 'optionalId': optionalId,
      },
      s: const <String, dynamic>{},
      uxzones: <String, List<UxSpec>>{
        UxZone.app: <UxSpec>[app.toUxSpec()],
        UxZone.content: <UxSpec>[spec],
      },
    );
  }
}
