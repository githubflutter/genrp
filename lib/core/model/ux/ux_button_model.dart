class UxButtonModel {
  final int i;
  final bool a;
  final int d;
  final int e;
  final int t;
  final int hostId;
  final int bodyId;
  final String n;
  final String s;
  final int actionId;
  final String actionName;

  const UxButtonModel({
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    required this.t,
    required this.hostId,
    required this.bodyId,
    required this.n,
    required this.s,
    required this.actionId,
    required this.actionName,
  });

  factory UxButtonModel.fromJson(Map<String, dynamic> json) => UxButtonModel(
    i: json['i'] as int? ?? 0,
    a: json['a'] as bool? ?? false,
    d: json['d'] as int? ?? 0,
    e: json['e'] as int? ?? 0,
    t: json['t'] as int? ?? 0,
    hostId: json['hostId'] as int? ?? 0,
    bodyId: json['bodyId'] as int? ?? 0,
    n: json['n'] as String? ?? '',
    s: json['s'] as String? ?? '',
    actionId: json['actionId'] as int? ?? 0,
    actionName: json['actionName'] as String? ?? '',
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
    'actionId': actionId,
    'actionName': actionName,
  };

  UxButtonModel copyWith({
    int? i,
    bool? a,
    int? d,
    int? e,
    int? t,
    int? hostId,
    int? bodyId,
    String? n,
    String? s,
    int? actionId,
    String? actionName,
  }) => UxButtonModel(
    i: i ?? this.i,
    a: a ?? this.a,
    d: d ?? this.d,
    e: e ?? this.e,
    t: t ?? this.t,
    hostId: hostId ?? this.hostId,
    bodyId: bodyId ?? this.bodyId,
    n: n ?? this.n,
    s: s ?? this.s,
    actionId: actionId ?? this.actionId,
    actionName: actionName ?? this.actionName,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UxButtonModel &&
          other.i == i &&
          other.a == a &&
          other.d == d &&
          other.e == e &&
          other.t == t &&
          other.hostId == hostId &&
          other.bodyId == bodyId &&
          other.n == n &&
          other.s == s &&
          other.actionId == actionId &&
          other.actionName == actionName);

  @override
  int get hashCode => Object.hash(i, a, d, e, t, hostId, bodyId, n, s, actionId, actionName);
}
