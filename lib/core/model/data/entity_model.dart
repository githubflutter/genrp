bool _intListEquals(List<int> a, List<int> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

class EntityModel {
  final int i;
  final bool a;
  final int d;
  final int e;
  final int t;
  final List<int> tis;
  final String n;
  final String s;

  const EntityModel({
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    required this.t,
    this.tis = const <int>[0],
    required this.n,
    required this.s,
  });

  factory EntityModel.fromJson(Map<String, dynamic> json) {
    final rawTis = json['tis'];
    final tis = rawTis is List
        ? rawTis
              .map((item) => (item as num?)?.toInt() ?? 0)
              .toList(growable: false)
        : const <int>[0];

    return EntityModel(
      i: json['i'] as int? ?? 0,
      a: json['a'] as bool? ?? false,
      d: json['d'] as int? ?? 0,
      e: json['e'] as int? ?? 0,
      t: json['t'] as int? ?? 0,
      tis: tis.isEmpty ? const <int>[0] : tis,
      n: json['n'] as String? ?? '',
      s: json['s'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'i': i,
    'a': a,
    'd': d,
    'e': e,
    't': t,
    'tis': tis,
    'n': n,
    's': s,
  };

  EntityModel copyWith({
    int? i,
    bool? a,
    int? d,
    int? e,
    int? t,
    List<int>? tis,
    String? n,
    String? s,
  }) => EntityModel(
    i: i ?? this.i,
    a: a ?? this.a,
    d: d ?? this.d,
    e: e ?? this.e,
    t: t ?? this.t,
    tis: tis ?? this.tis,
    n: n ?? this.n,
    s: s ?? this.s,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityModel &&
          other.i == i &&
          other.a == a &&
          other.d == d &&
          other.e == e &&
          other.t == t &&
          _intListEquals(other.tis, tis) &&
          other.n == n &&
          other.s == s);

  @override
  int get hashCode => Object.hash(i, a, d, e, t, Object.hashAll(tis), n, s);
}
