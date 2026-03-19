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

class FunctionType {
  static const int sysGet = 0;
  static const int sysSet = 1;
  static const int jssGet = 2;
  static const int jssSet = 3;
  static const int bizGet = 4;
  static const int bizSet = 5;

  static const Map<int, String> labelsById = <int, String>{
    sysGet: 'sys-get',
    sysSet: 'sys-set',
    jssGet: 'jss-get',
    jssSet: 'jss-set',
    bizGet: 'biz-get',
    bizSet: 'biz-set',
  };

  static const Map<String, int> idsByLabel = <String, int>{
    'sys-get': sysGet,
    'sys-set': sysSet,
    'jss-get': jssGet,
    'jss-set': jssSet,
    'biz-get': bizGet,
    'biz-set': bizSet,
  };

  static String? labelById(int id) => labelsById[id];

  static int? idByLabel(String label) => idsByLabel[label.trim().toLowerCase()];

  static bool isSystem(int id) => id == sysGet || id == sysSet;

  static bool isJss(int id) => id == jssGet || id == jssSet;

  static bool isBusiness(int id) => id == bizGet || id == bizSet;

  static bool isGetter(int id) => id == sysGet || id == jssGet || id == bizGet;

  static bool isSetter(int id) => id == sysSet || id == jssSet || id == bizSet;
}

class FunctionModel {
  final int i;
  final bool a;
  final int d;
  final int e;
  final int ei;
  final int t;
  final List<int> tis;
  final String n;
  final String s;

  const FunctionModel({
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    this.ei = 0,
    required this.t,
    this.tis = const <int>[0],
    required this.n,
    required this.s,
  });

  factory FunctionModel.fromJson(Map<String, dynamic> json) {
    final rawTis = json['tis'];
    final tis = rawTis is List
        ? rawTis
              .map((item) => (item as num?)?.toInt() ?? 0)
              .toList(growable: false)
        : const <int>[0];

    return FunctionModel(
      i: json['i'] as int? ?? 0,
      a: json['a'] as bool? ?? false,
      d: json['d'] as int? ?? 0,
      e: json['e'] as int? ?? 0,
      ei: (json['ei'] as num?)?.toInt() ?? 0,
      t: (json['t'] as num?)?.toInt() ?? 0,
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
    'ei': ei,
    't': t,
    'tis': tis,
    'n': n,
    's': s,
  };

  FunctionModel copyWith({
    int? i,
    bool? a,
    int? d,
    int? e,
    int? ei,
    int? t,
    List<int>? tis,
    String? n,
    String? s,
  }) => FunctionModel(
    i: i ?? this.i,
    a: a ?? this.a,
    d: d ?? this.d,
    e: e ?? this.e,
    ei: ei ?? this.ei,
    t: t ?? this.t,
    tis: tis ?? this.tis,
    n: n ?? this.n,
    s: s ?? this.s,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FunctionModel &&
          other.i == i &&
          other.a == a &&
          other.d == d &&
          other.e == e &&
          other.ei == ei &&
          other.t == t &&
          _intListEquals(other.tis, tis) &&
          other.n == n &&
          other.s == s);

  @override
  int get hashCode => Object.hash(i, a, d, e, ei, t, Object.hashAll(tis), n, s);
}
