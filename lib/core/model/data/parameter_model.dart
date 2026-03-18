class ParameterModel {
  final int i;
  final bool a;
  final bool d;
  final bool e;
  final int t;
  final String n;
  final String s;

  const ParameterModel({
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    required this.t,
    required this.n,
    required this.s,
  });

  factory ParameterModel.fromJson(Map<String, dynamic> json) => ParameterModel(
    i: json['i'] as int? ?? 0,
    a: json['a'] as bool? ?? false,
    d: json['d'] as bool? ?? false,
    e: json['e'] as bool? ?? false,
    t: json['t'] as int? ?? 0,
    n: json['n'] as String? ?? '',
    s: json['s'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'i': i,
    'a': a,
    'd': d,
    'e': e,
    't': t,
    'n': n,
    's': s,
  };

  ParameterModel copyWith({
    int? i,
    bool? a,
    bool? d,
    bool? e,
    int? t,
    String? n,
    String? s,
  }) => ParameterModel(
    i: i ?? this.i,
    a: a ?? this.a,
    d: d ?? this.d,
    e: e ?? this.e,
    t: t ?? this.t,
    n: n ?? this.n,
    s: s ?? this.s,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParameterModel &&
          other.i == i &&
          other.a == a &&
          other.d == d &&
          other.e == e &&
          other.t == t &&
          other.n == n &&
          other.s == s);

  @override
  int get hashCode => Object.hash(i, a, d, e, t, n, s);
}
