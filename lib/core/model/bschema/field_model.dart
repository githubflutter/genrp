class FieldModel {
  final int i;
  final bool a;
  final int d;
  final int e;
  final int ci;
  final int t;
  final String n;
  final String s;

  const FieldModel({
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    this.ci = 0,
    required this.t,
    required this.n,
    required this.s,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) => FieldModel(
    i: json['i'] as int? ?? 0,
    a: json['a'] as bool? ?? false,
    d: json['d'] as int? ?? 0,
    e: json['e'] as int? ?? 0,
    ci: (json['ci'] as num?)?.toInt() ?? 0,
    t: json['t'] as int? ?? 0,
    n: json['n'] as String? ?? '',
    s: json['s'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'i': i,
    'a': a,
    'd': d,
    'e': e,
    'ci': ci,
    't': t,
    'n': n,
    's': s,
  };

  FieldModel copyWith({
    int? i,
    bool? a,
    int? d,
    int? e,
    int? ci,
    int? t,
    String? n,
    String? s,
  }) => FieldModel(
    i: i ?? this.i,
    a: a ?? this.a,
    d: d ?? this.d,
    e: e ?? this.e,
    ci: ci ?? this.ci,
    t: t ?? this.t,
    n: n ?? this.n,
    s: s ?? this.s,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldModel &&
          other.i == i &&
          other.a == a &&
          other.d == d &&
          other.e == e &&
          other.ci == ci &&
          other.t == t &&
          other.n == n &&
          other.s == s);

  @override
  int get hashCode => Object.hash(i, a, d, e, ci, t, n, s);
}
