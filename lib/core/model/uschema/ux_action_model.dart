class UxActionModel {
  final int i;
  final bool a;
  final int d;
  final int e;
  final int t;
  final String n;
  final String s;

  const UxActionModel({
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    required this.t,
    required this.n,
    required this.s,
  });

  factory UxActionModel.fromJson(Map<String, dynamic> json) {
    final displayName =
        json['n']?.toString() ??
        json['label']?.toString() ??
        json['name']?.toString() ??
        '';
    final systemName =
        json['s']?.toString() ?? json['name']?.toString() ?? displayName;
    return UxActionModel(
      i: (json['id'] as num?)?.toInt() ?? (json['i'] as num?)?.toInt() ?? 0,
      a: json['a'] as bool? ?? true,
      d: (json['d'] as num?)?.toInt() ?? 0,
      e: (json['e'] as num?)?.toInt() ?? 0,
      t: (json['t'] as num?)?.toInt() ?? 0,
      n: displayName,
      s: systemName,
    );
  }

  Map<String, dynamic> toJson() => {
    'i': i,
    'a': a,
    'd': d,
    'e': e,
    't': t,
    'n': n,
    's': s,
  };
}
