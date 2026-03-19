class ParameterModel {
  final int i;
  final bool a;
  final int d;
  final int e;
  final int fi;
  final String n;
  final String s;

  const ParameterModel({
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    required this.fi,
    required this.n,
    required this.s,
  });

  factory ParameterModel.fromJson(Map<String, dynamic> json) => ParameterModel(
    i: json['i'] as int? ?? 0,
    a: json['a'] as bool? ?? false,
    d: json['d'] as int? ?? 0,
    e: json['e'] as int? ?? 0,
    fi: (json['fi'] as num?)?.toInt() ?? (json['t'] as num?)?.toInt() ?? 0,
    n: json['n'] as String? ?? '',
    s: json['s'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'i': i,
    'a': a,
    'd': d,
    'e': e,
    'fi': fi,
    'n': n,
    's': s,
  };

  ParameterModel copyWith({
    int? i,
    bool? a,
    int? d,
    int? e,
    int? fi,
    String? n,
    String? s,
  }) => ParameterModel(
    i: i ?? this.i,
    a: a ?? this.a,
    d: d ?? this.d,
    e: e ?? this.e,
    fi: fi ?? this.fi,
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
          other.fi == fi &&
          other.n == n &&
          other.s == s);

  @override
  int get hashCode => Object.hash(i, a, d, e, fi, n, s);
}
