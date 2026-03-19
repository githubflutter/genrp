class UserModel {
  final int i;
  final int d;
  final int e;
  final bool a;
  final String u;
  final String p;
  final String n;
  final int x;
  final int l;

  const UserModel({
    required this.i,
    required this.d,
    required this.e,
    required this.a,
    required this.u,
    required this.p,
    required this.n,
    required this.x,
    required this.l,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    i: (json['i'] as num?)?.toInt() ?? 0,
    d: (json['d'] as num?)?.toInt() ?? 0,
    e: (json['e'] as num?)?.toInt() ?? 0,
    a: json['a'] as bool? ?? false,
    u: json['u'] as String? ?? '',
    p: json['p'] as String? ?? '',
    n: json['n'] as String? ?? '',
    x: (json['x'] as num?)?.toInt() ?? 0,
    l: (json['l'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'i': i,
    'd': d,
    'e': e,
    'a': a,
    'u': u,
    'p': p,
    'n': n,
    'x': x,
    'l': l,
  };

  UserModel copyWith({
    int? i,
    int? d,
    int? e,
    bool? a,
    String? u,
    String? p,
    String? n,
    int? x,
    int? l,
  }) {
    return UserModel(
      i: i ?? this.i,
      d: d ?? this.d,
      e: e ?? this.e,
      a: a ?? this.a,
      u: u ?? this.u,
      p: p ?? this.p,
      n: n ?? this.n,
      x: x ?? this.x,
      l: l ?? this.l,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserModel &&
          other.i == i &&
          other.d == d &&
          other.e == e &&
          other.a == a &&
          other.u == u &&
          other.p == p &&
          other.n == n &&
          other.x == x &&
          other.l == l);

  @override
  int get hashCode => Object.hash(i, d, e, a, u, p, n, x, l);
}
