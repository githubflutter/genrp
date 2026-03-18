class X {
  final List<dynamic> v;

  const X({List<dynamic>? v}) : v = v ?? const <dynamic>[];

  factory X.fromJson(Map<String, dynamic> json) {
    return X(v: (json['v'] as List<dynamic>?) ?? const <dynamic>[]);
  }

  Map<String, dynamic> toJson() {
    return {'v': v};
  }
}

class Xi extends X {
  final int i;

  const Xi({required dynamic i, super.v}) : i = i as int;

  factory Xi.fromJson(Map<String, dynamic> json) {
    return Xi(i: json['i'], v: (json['v'] as List<dynamic>?) ?? const <dynamic>[]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'i': i};
  }
}

class Xia extends X {
  final int i;
  final bool a;

  const Xia({required dynamic i, required dynamic a, super.v}) : i = i as int, a = a as bool;

  factory Xia.fromJson(Map<String, dynamic> json) {
    return Xia(i: json['i'], a: json['a'], v: (json['v'] as List<dynamic>?) ?? const <dynamic>[]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'i': i, 'a': a};
  }
}

class Xiad extends X {
  final int i;
  final bool a;
  final int d;

  const Xiad({required dynamic i, required dynamic a, required dynamic d, super.v}) : i = i as int, a = a as bool, d = d as int;

  factory Xiad.fromJson(Map<String, dynamic> json) {
    return Xiad(i: json['i'], a: json['a'], d: json['d'], v: (json['v'] as List<dynamic>?) ?? const <dynamic>[]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'i': i, 'a': a, 'd': d};
  }
}

class Xiade extends X {
  final int i;
  final bool a;
  final int d;
  final int e;

  const Xiade({required dynamic i, required dynamic a, required dynamic d, required dynamic e, super.v}) : i = i as int, a = a as bool, d = d as int, e = e as int;

  factory Xiade.fromJson(Map<String, dynamic> json) {
    return Xiade(i: json['i'], a: json['a'], d: json['d'], e: json['e'], v: (json['v'] as List<dynamic>?) ?? const <dynamic>[]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'i': i, 'a': a, 'd': d, 'e': e};
  }
}
