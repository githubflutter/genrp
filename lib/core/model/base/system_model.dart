import 'dart:convert';

class SystemModel {
  final int sid;
  final String n;
  final int fv;
  final int cv;
  final int ld;
  final int lds;
  final int ldu;
  final Map<String, dynamic> ctm;
  final Map<String, dynamic> uxm;
  final Map<String, dynamic> m1;
  final Map<String, dynamic> m2;

  const SystemModel({
    required this.sid,
    required this.n,
    required this.fv,
    required this.cv,
    required this.ld,
    required this.lds,
    required this.ldu,
    required this.ctm,
    required this.uxm,
    required this.m1,
    required this.m2,
  });

  factory SystemModel.fromJson(Map<String, dynamic> json) => SystemModel(
    sid: (json['sid'] as num?)?.toInt() ?? 0,
    n: json['n'] as String? ?? '',
    fv: (json['fv'] as num?)?.toInt() ?? 0,
    cv: (json['cv'] as num?)?.toInt() ?? 0,
    ld: (json['ld'] as num?)?.toInt() ?? 0,
    lds: (json['lds'] as num?)?.toInt() ?? 0,
    ldu: (json['ldu'] as num?)?.toInt() ?? 0,
    ctm: Map<String, dynamic>.from(json['ctm'] as Map? ?? const {}),
    uxm: Map<String, dynamic>.from(json['uxm'] as Map? ?? const {}),
    m1: Map<String, dynamic>.from(json['m1'] as Map? ?? const {}),
    m2: Map<String, dynamic>.from(json['m2'] as Map? ?? const {}),
  );

  Map<String, dynamic> toJson() => {
    'sid': sid,
    'n': n,
    'fv': fv,
    'cv': cv,
    'ld': ld,
    'lds': lds,
    'ldu': ldu,
    'ctm': ctm,
    'uxm': uxm,
    'm1': m1,
    'm2': m2,
  };

  SystemModel copyWith({
    int? sid,
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
  }) {
    return SystemModel(
      sid: sid ?? this.sid,
      n: n ?? this.n,
      fv: fv ?? this.fv,
      cv: cv ?? this.cv,
      ld: ld ?? this.ld,
      lds: lds ?? this.lds,
      ldu: ldu ?? this.ldu,
      ctm: ctm ?? this.ctm,
      uxm: uxm ?? this.uxm,
      m1: m1 ?? this.m1,
      m2: m2 ?? this.m2,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SystemModel &&
          other.sid == sid &&
          other.n == n &&
          other.fv == fv &&
          other.cv == cv &&
          other.ld == ld &&
          other.lds == lds &&
          other.ldu == ldu &&
          _canonicalJsonText(other.ctm) == _canonicalJsonText(ctm) &&
          _canonicalJsonText(other.uxm) == _canonicalJsonText(uxm) &&
          _canonicalJsonText(other.m1) == _canonicalJsonText(m1) &&
          _canonicalJsonText(other.m2) == _canonicalJsonText(m2));

  @override
  int get hashCode => Object.hash(
    sid,
    n,
    fv,
    cv,
    ld,
    lds,
    ldu,
    _canonicalJsonText(ctm),
    _canonicalJsonText(uxm),
    _canonicalJsonText(m1),
    _canonicalJsonText(m2),
  );
}

String _canonicalJsonText(Object? value) => jsonEncode(_normalizeJson(value));

Object? _normalizeJson(Object? value) {
  if (value is Map) {
    final entries = value.entries.toList()
      ..sort(
        (left, right) => left.key.toString().compareTo(right.key.toString()),
      );
    return <String, Object?>{
      for (final entry in entries)
        entry.key.toString(): _normalizeJson(entry.value),
    };
  }
  if (value is List) {
    return value.map(_normalizeJson).toList(growable: false);
  }
  return value;
}
