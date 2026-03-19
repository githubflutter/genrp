class UxCheckBoxModel {
  final int i;
  final bool a;
  final int d;
  final int e;
  final int t;
  final int hostId;
  final int bodyId;
  final String n;
  final String s;
  final String bind;
  final int? src;
  final int? fieldId;

  const UxCheckBoxModel({
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    required this.t,
    required this.hostId,
    required this.bodyId,
    required this.n,
    required this.s,
    required this.bind,
    this.src,
    this.fieldId,
  });

  factory UxCheckBoxModel.fromJson(Map<String, dynamic> json) => UxCheckBoxModel(
    i: json['i'] as int? ?? 0,
    a: json['a'] as bool? ?? false,
    d: json['d'] as int? ?? 0,
    e: json['e'] as int? ?? 0,
    t: json['t'] as int? ?? 0,
    hostId: json['hostId'] as int? ?? 0,
    bodyId: json['bodyId'] as int? ?? 0,
    n: json['n'] as String? ?? '',
    s: json['s'] as String? ?? '',
    bind: json['bind'] as String? ?? '',
    src: (json['src'] as num?)?.toInt(),
    fieldId: (json['fieldId'] as num?)?.toInt() ?? (json['f'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    'i': i,
    'a': a,
    'd': d,
    'e': e,
    't': t,
    'hostId': hostId,
    'bodyId': bodyId,
    'n': n,
    's': s,
    'bind': bind,
    'src': src,
    'fieldId': fieldId,
  };

  UxCheckBoxModel copyWith({
    int? i,
    bool? a,
    int? d,
    int? e,
    int? t,
    int? hostId,
    int? bodyId,
    String? n,
    String? s,
    String? bind,
    int? src,
    int? fieldId,
  }) => UxCheckBoxModel(
    i: i ?? this.i,
    a: a ?? this.a,
    d: d ?? this.d,
    e: e ?? this.e,
    t: t ?? this.t,
    hostId: hostId ?? this.hostId,
    bodyId: bodyId ?? this.bodyId,
    n: n ?? this.n,
    s: s ?? this.s,
    bind: bind ?? this.bind,
    src: src ?? this.src,
    fieldId: fieldId ?? this.fieldId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UxCheckBoxModel &&
          other.i == i &&
          other.a == a &&
          other.d == d &&
          other.e == e &&
          other.t == t &&
          other.hostId == hostId &&
          other.bodyId == bodyId &&
          other.n == n &&
          other.s == s &&
          other.bind == bind &&
          other.src == src &&
          other.fieldId == fieldId);

  @override
  int get hashCode => Object.hash(i, a, d, e, t, hostId, bodyId, n, s, bind, src, fieldId);
}
