import 'package:genrp/core/model/data/system_model.dart';
import 'package:genrp/meta.dart';

class DefaultAppKvSeedEntry {
  const DefaultAppKvSeedEntry({
    required this.key,
    required this.value,
    this.updatedAt = 0,
  });

  final String key;
  final Object? value;
  final int updatedAt;
}

class DefaultCatalogRowSeedEntry {
  const DefaultCatalogRowSeedEntry({
    required this.catalog,
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    required this.t,
    required this.n,
    required this.s,
    required this.payload,
    this.updatedAt = 0,
  });

  final String catalog;
  final int i;
  final bool a;
  final int d;
  final int e;
  final int t;
  final String n;
  final String s;
  final Map<String, Object?> payload;
  final int updatedAt;
}

class SystemDefaults {
  SystemDefaults._();

  static const String catalog = 'System';
  static const int rowId = 1;
  static const String systemName = 'genrp';

  static const Map<String, dynamic> defaultCtm = <String, dynamic>{
    'entity': 'Entity',
    'field': 'Field',
    'table': 'Table',
    'column': 'Column',
    'function': 'Function',
    'parameter': 'Parameter',
    'system': 'System',
    'user': 'User',
  };

  static const Map<String, dynamic> defaultUxm = <String, dynamic>{
    'host': 'Host',
    'body': 'Body',
    'template': 'Template',
    'type': 'Type',
    'widget': 'Widget',
    'fieldBinding': 'FieldBinding',
    'uxAction': 'UX Action',
    'bodySpecNode': 'Body Spec Node',
  };

  static const Map<String, dynamic> defaultM1 = <String, dynamic>{};
  static const Map<String, dynamic> defaultM2 = <String, dynamic>{};

  static SystemModel model({
    int sid = rowId,
    String n = 'GenRP',
    int? fv,
    int? cv,
    int ld = 0,
    int lds = 0,
    int ldu = 0,
    Map<String, dynamic>? ctm,
    Map<String, dynamic>? uxm,
    Map<String, dynamic>? m1,
    Map<String, dynamic>? m2,
  }) {
    return SystemModel(
      sid: sid,
      n: n,
      fv: fv ?? AppMeta.f,
      cv: cv ?? AppMeta.v,
      ld: ld,
      lds: lds,
      ldu: ldu,
      ctm: Map<String, dynamic>.from(ctm ?? defaultCtm),
      uxm: Map<String, dynamic>.from(uxm ?? defaultUxm),
      m1: Map<String, dynamic>.from(m1 ?? defaultM1),
      m2: Map<String, dynamic>.from(m2 ?? defaultM2),
    );
  }

  static DefaultCatalogRowSeedEntry seedCatalogRow({SystemModel? system}) {
    final resolved = system ?? model();
    return DefaultCatalogRowSeedEntry(
      catalog: catalog,
      i: rowId,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      n: resolved.n,
      s: systemName,
      payload: resolved.toJson(),
    );
  }

  static SystemModel fromPayload(Map<String, dynamic> payload) {
    return SystemModel.fromJson(payload);
  }

  static SystemModel update(
    SystemModel current, {
    String? n,
    int? fv,
    int? cv,
    int? ld,
    int? lds,
    int? ldu,
    Map<String, dynamic>? ctm,
    Map<String, dynamic>? uxm,
    Map<String, dynamic>? m1,
    Map<String, dynamic>? m2,
    bool touchEditedAt = false,
    bool touchUpdatedAt = true,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return current.copyWith(
      n: n,
      fv: fv,
      cv: cv,
      ld: ld ?? (touchEditedAt ? now : null),
      lds: lds,
      ldu: ldu ?? (touchUpdatedAt ? now : null),
      ctm: ctm,
      uxm: uxm,
      m1: m1,
      m2: m2,
    );
  }
}

final defaultAppKvSeedEntries = <DefaultAppKvSeedEntry>[];

final defaultCatalogRowSeedEntries = <DefaultCatalogRowSeedEntry>[
  SystemDefaults.seedCatalogRow(),
];
