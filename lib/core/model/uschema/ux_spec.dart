import 'package:genrp/core/model/uschema/ux_app_spec.dart';
import 'package:genrp/core/model/uschema/ux_field_spec.dart';
import 'package:genrp/core/model/uschema/ux_route_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

/// Typed workspace metadata stored in `UxSpec.m` for `tworkspace`.
///
/// This keeps stable template configuration in the schema layer instead of
/// spreading it across widget constructor parameters.
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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'collectionTitle': collectionTitle,
    'collectionColumns': collectionColumns,
    'collectionRows': collectionRows,
    'collectionViewModes': collectionViewModes,
    'properties': properties,
    'formFields': formFields
        .map(
          (field) => <String, dynamic>{
            'label': field.label,
            'hint': field.hint,
            'width': field.width,
            'dataTypeId': field.dataTypeId,
            'fieldMode': field.fieldMode?.name,
          },
        )
        .toList(growable: false),
    'summaryText': summaryText,
    'emptyTitle': emptyTitle,
    'emptyMessage': emptyMessage,
    'defaultAlertMessage': defaultAlertMessage,
    'collectionFlex': collectionFlex,
    'detailFlex': detailFlex,
  };

  factory UxWorkspaceMeta.fromJson(Map<String, dynamic> json) {
    return UxWorkspaceMeta(
      collectionTitle: json['collectionTitle'] as String? ?? 'Collection',
      collectionColumns:
          (json['collectionColumns'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const <String>[],
      collectionRows:
          (json['collectionRows'] as List<dynamic>?)
              ?.map((row) => (row as List).cast<Object?>())
              .toList(growable: false) ??
          const <List<Object?>>[],
      collectionViewModes:
          (json['collectionViewModes'] as List<dynamic>?)
              ?.map((item) => (item as num).toInt())
              .toList(growable: false) ??
          const <int>[3],
      properties:
          (json['properties'] as Map<dynamic, dynamic>?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          const <String, Object?>{},
      formFields:
          (json['formFields'] as List<dynamic>?)
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
      emptyMessage:
          json['emptyMessage'] as String? ??
          'Choose an item from the collection to inspect it.',
      defaultAlertMessage:
          json['defaultAlertMessage'] as String? ??
          'Something needs your attention.',
      collectionFlex: (json['collectionFlex'] as num?)?.toInt() ?? 7,
      detailFlex: (json['detailFlex'] as num?)?.toInt() ?? 5,
    );
  }
}

class UxWidgetSlot {
  const UxWidgetSlot({this.i, this.style = 0});

  final int? i;
  final int style;

  factory UxWidgetSlot.fromSpec(UxSpec? spec) {
    return UxWidgetSlot(i: spec?.i, style: spec?.style ?? 0);
  }
}

class UxFrameMeta {
  const UxFrameMeta({this.scroll = 'none'});

  final String scroll;

  Map<String, dynamic> toJson() => <String, dynamic>{'scroll': scroll};

  factory UxFrameMeta.fromJson(Map<String, dynamic> json) {
    return UxFrameMeta(scroll: json['scroll'] as String? ?? 'none');
  }
}

class UxWorkspaceSlots {
  const UxWorkspaceSlots({
    this.topToolbar = const UxWidgetSlot(),
    this.bottomToolbar = const UxWidgetSlot(),
    this.collection = const UxWidgetSlot(),
    this.plist = const UxWidgetSlot(),
    this.form = const UxWidgetSlot(),
    this.empty = const UxWidgetSlot(),
    this.alert = const UxWidgetSlot(),
  });

  final UxWidgetSlot topToolbar;
  final UxWidgetSlot bottomToolbar;
  final UxWidgetSlot collection;
  final UxWidgetSlot plist;
  final UxWidgetSlot form;
  final UxWidgetSlot empty;
  final UxWidgetSlot alert;
}

/// Unified UX schema record.
///
/// This is the canonical structural model for authored UX content.
/// The migration target is for app, route, template, and uwidget
/// rendering to operate from this shape and its recursive `uxzones`.
///
/// Doctrine fields:
/// `i` instance id
/// `a` active flag
/// `d` edited epoch ms
/// `e` editor id
/// `n` readable name
/// `t` type id within layer
/// `l` layer id
/// `m` stable/read-mostly state
/// `s` mutable/live state
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

  factory UxSpec.fromJson(Map<String, dynamic> json) {
    final rawUxZones = json['uxzones'] as Map<dynamic, dynamic>?;
    return UxSpec(
      i: (json['i'] as num?)?.toInt() ?? 0,
      a: json['a'] as bool? ?? true,
      d: (json['d'] as num?)?.toInt() ?? 0,
      e: (json['e'] as num?)?.toInt() ?? 0,
      n: json['n'] as String? ?? '',
      t: (json['t'] as num?)?.toInt() ?? 0,
      l: (json['l'] as num?)?.toInt() ?? 0,
      m: _stringDynamicMap(json['m'] as Map? ?? const <String, dynamic>{}),
      s: _stringDynamicMap(json['s'] as Map? ?? const <String, dynamic>{}),
      uxzones: rawUxZones == null
          ? const <String, List<UxSpec>>{}
          : rawUxZones.map(
              (key, value) => MapEntry(
                key.toString(),
                (value as List<dynamic>)
                    .whereType<Map>()
                    .map((item) => UxSpec.fromJson(_stringDynamicMap(item)))
                    .toList(growable: false),
              ),
            ),
    );
  }

  factory UxSpec.rootTemplate({
    required int i,
    required int t,
    required String n,
    UxFrameMeta frame = const UxFrameMeta(),
    Map<String, dynamic> m = const <String, dynamic>{},
    Map<String, dynamic> s = const <String, dynamic>{},
    Map<String, List<UxSpec>> uxzones = const <String, List<UxSpec>>{},
  }) {
    return UxSpec(
      i: i,
      n: n,
      t: t,
      l: UxLayer.template.code,
      m: <String, dynamic>{...m, 'frame': frame.toJson()},
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

  bool get hasFrame => m.containsKey('frame');
  UxFrameMeta get frame => hasFrame
      ? UxFrameMeta.fromJson(m['frame'] as Map<String, dynamic>)
      : const UxFrameMeta();

  Map<String, dynamic> toJson() => <String, dynamic>{
    'i': i,
    'a': a,
    'd': d,
    'e': e,
    'n': n,
    't': t,
    'l': l,
    'm': m,
    's': s,
    'uxzones': uxzones.map(
      (key, value) => MapEntry(
        key,
        value.map((spec) => spec.toJson()).toList(growable: false),
      ),
    ),
  };

  String metaString(String key, {String fallback = ''}) {
    final value = m[key];
    return value is String ? value : fallback;
  }

  int metaInt(String key, {int fallback = 0}) {
    final value = m[key];
    return value is num ? value.toInt() : fallback;
  }

  List<int> metaInts(String key, {List<int> fallback = const <int>[]}) {
    final value = m[key];
    if (value is! List) return fallback;
    return value.map((item) => (item as num).toInt()).toList(growable: false);
  }

  List<String> metaStrings(String key) {
    final value = m[key];
    if (value is! List) return const <String>[];
    return value.map((item) => item.toString()).toList(growable: false);
  }

  List<List<Object?>> metaRows(String key) {
    final value = m[key];
    if (value is! List) return const <List<Object?>>[];
    return value
        .map((row) => (row as List).cast<Object?>())
        .toList(growable: false);
  }

  Map<String, Object?> metaObjectMap(String key) {
    final value = m[key];
    if (value is! Map) return const <String, Object?>{};
    return value.map(
      (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
    );
  }

  List<UxFieldSpec> metaFieldSpecs(String key) {
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

  UxWorkspaceMeta get workspace => UxWorkspaceMeta.fromJson(m);

  List<UxSpec> uxzoneChildren(String uxzone) =>
      uxzones[uxzone] ?? const <UxSpec>[];

  UxSpec? firstInUxZone(String uxzone) {
    final items = uxzoneChildren(uxzone);
    return items.isEmpty ? null : items.first;
  }

  UxSpec? firstOfLayer(UxLayer layer, {String? uxzone}) {
    final groups = uxzone == null
        ? uxzones.values
        : <List<UxSpec>>[uxzoneChildren(uxzone)];
    for (final group in groups) {
      for (final child in group) {
        if (child.l == layer.code) return child;
      }
    }
    return null;
  }

  UxSpec? firstOfType(
    int type, {
    UxLayer layer = UxLayer.uwidget,
    String? uxzone,
  }) {
    final groups = uxzone == null
        ? uxzones.values
        : <List<UxSpec>>[uxzoneChildren(uxzone)];
    for (final group in groups) {
      for (final child in group) {
        if (child.l == layer.code && child.t == type) return child;
      }
    }
    return null;
  }

  List<UxSpec> ofLayer(UxLayer layer, {String? uxzone}) {
    final matches = <UxSpec>[];
    final groups = uxzone == null
        ? uxzones.values
        : <List<UxSpec>>[uxzoneChildren(uxzone)];
    for (final group in groups) {
      for (final child in group) {
        if (child.l == layer.code) {
          matches.add(child);
        }
      }
    }
    return matches;
  }

  /// Resolve well-known workspace slots from zoned child specs.
  ///
  /// This keeps slot discovery in the schema layer so `GenUx` can render
  /// from `meta + slots` rather than scanning zone lists itself.
  UxWorkspaceSlots get workspaceSlots => UxWorkspaceSlots(
    topToolbar: UxWidgetSlot.fromSpec(firstOfType(4, uxzone: UxZone.header)),
    bottomToolbar: UxWidgetSlot.fromSpec(firstOfType(4, uxzone: UxZone.footer)),
    collection: UxWidgetSlot.fromSpec(
      firstOfType(12, uxzone: UxZone.collection),
    ),
    plist: UxWidgetSlot.fromSpec(firstOfType(6, uxzone: UxZone.detail)),
    form: UxWidgetSlot.fromSpec(firstOfType(5, uxzone: UxZone.detail)),
    empty: UxWidgetSlot.fromSpec(firstOfType(9, uxzone: UxZone.feedback)),
    alert: UxWidgetSlot.fromSpec(firstOfType(11, uxzone: UxZone.feedback)),
  );

  int get style => metaInt('style');
}

Map<String, dynamic> _stringDynamicMap(Map raw) {
  return raw.map((key, value) => MapEntry(key.toString(), value));
}

extension UxAppSpecAdapter on UxAppSpec {
  UxSpec toUxSpec({
    Map<String, List<UxSpec>> uxzones = const <String, List<UxSpec>>{},
  }) {
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
      i: id,
      n: appName,
      t: id,
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
