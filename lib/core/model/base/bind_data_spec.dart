import 'dart:convert';

class BindDataSpec {
  const BindDataSpec({
    required this.entity,
    this.field,
    this.get,
    this.set,
    this.list,
    this.master,
    this.detail,
    this.args = const <String, dynamic>{},
    this.m = const <String, dynamic>{},
  });

  final String entity;
  final String? field;
  final String? get;
  final String? set;
  final String? list;
  final String? master;
  final String? detail;
  final Map<String, dynamic> args;
  final Map<String, dynamic> m;

  factory BindDataSpec.fromJson(Map<String, dynamic> json) => BindDataSpec(
    entity: json['entity'] as String? ?? '',
    field: json['field'] as String?,
    get: json['get'] as String?,
    set: json['set'] as String?,
    list: json['list'] as String?,
    master: json['master'] as String?,
    detail: json['detail'] as String?,
    args: Map<String, dynamic>.from(json['args'] as Map? ?? const {}),
    m: Map<String, dynamic>.from(json['m'] as Map? ?? const {}),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'entity': entity,
    'field': field,
    'get': get,
    'set': set,
    'list': list,
    'master': master,
    'detail': detail,
    'args': args,
    'm': m,
  };

  BindDataSpec copyWith({
    String? entity,
    String? field,
    String? get,
    String? set,
    String? list,
    String? master,
    String? detail,
    Map<String, dynamic>? args,
    Map<String, dynamic>? m,
  }) {
    return BindDataSpec(
      entity: entity ?? this.entity,
      field: field ?? this.field,
      get: get ?? this.get,
      set: set ?? this.set,
      list: list ?? this.list,
      master: master ?? this.master,
      detail: detail ?? this.detail,
      args: args ?? this.args,
      m: m ?? this.m,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BindDataSpec &&
          other.entity == entity &&
          other.field == field &&
          other.get == get &&
          other.set == set &&
          other.list == list &&
          other.master == master &&
          other.detail == detail &&
          _canonicalJsonText(other.args) == _canonicalJsonText(args) &&
          _canonicalJsonText(other.m) == _canonicalJsonText(m));

  @override
  int get hashCode => Object.hash(
    entity,
    field,
    get,
    set,
    list,
    master,
    detail,
    _canonicalJsonText(args),
    _canonicalJsonText(m),
  );
}

String _canonicalJsonText(Object? value) => jsonEncode(_normalizeJson(value));

Object? _normalizeJson(Object? value) {
  if (value is Map) {
    final entries = value.entries.toList()
      ..sort(
        (left, right) => left.key.toString().compareTo(right.key.toString()),
      );
    return <String, Object?>{
      for (final entry in entries)
        entry.key.toString(): _normalizeJson(entry.value),
    };
  }
  if (value is List) {
    return value.map(_normalizeJson).toList(growable: false);
  }
  return value;
}
