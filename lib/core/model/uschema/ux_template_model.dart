class UxTemplateModel {
  final int i;
  final bool a;
  final int d;
  final int e;
  final int t;
  final String n;
  final String s;

  const UxTemplateModel({
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    required this.t,
    required this.n,
    required this.s,
  });

  factory UxTemplateModel.fromJson(Map<String, dynamic> json) {
    final name = json['n']?.toString() ?? json['name']?.toString() ?? '';
    return UxTemplateModel(
      i: (json['i'] as num?)?.toInt() ?? (json['id'] as num?)?.toInt() ?? 0,
      a: json['a'] as bool? ?? true,
      d: (json['d'] as num?)?.toInt() ?? 0,
      e: (json['e'] as num?)?.toInt() ?? 0,
      t: (json['t'] as num?)?.toInt() ?? 0,
      n: name,
      s: json['s']?.toString() ?? name,
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
