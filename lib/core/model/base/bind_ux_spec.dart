import 'dart:convert';

class BindUxSpec {
  const BindUxSpec({
    required this.layer,
    required this.target,
    required this.bind,
    this.path,
    this.control,
    this.visible,
    this.editable,
    this.m = const <String, dynamic>{},
  });

  final String layer;
  final String target;
  final String bind;
  final String? path;
  final String? control;
  final bool? visible;
  final bool? editable;
  final Map<String, dynamic> m;

  factory BindUxSpec.fromJson(Map<String, dynamic> json) => BindUxSpec(
    layer: json['layer'] as String? ?? '',
    target: json['target'] as String? ?? '',
    bind: json['bind'] as String? ?? '',
    path: json['path'] as String?,
    control: json['control'] as String?,
    visible: json['visible'] as bool?,
    editable: json['editable'] as bool?,
    m: Map<String, dynamic>.from(json['m'] as Map? ?? const {}),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'layer': layer,
    'target': target,
    'bind': bind,
    'path': path,
    'control': control,
    'visible': visible,
    'editable': editable,
    'm': m,
  };

  BindUxSpec copyWith({
    String? layer,
    String? target,
    String? bind,
    String? path,
    String? control,
    bool? visible,
    bool? editable,
    Map<String, dynamic>? m,
  }) {
    return BindUxSpec(
      layer: layer ?? this.layer,
      target: target ?? this.target,
      bind: bind ?? this.bind,
      path: path ?? this.path,
      control: control ?? this.control,
      visible: visible ?? this.visible,
      editable: editable ?? this.editable,
      m: m ?? this.m,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BindUxSpec &&
          other.layer == layer &&
          other.target == target &&
          other.bind == bind &&
          other.path == path &&
          other.control == control &&
          other.visible == visible &&
          other.editable == editable &&
          _canonicalJsonText(other.m) == _canonicalJsonText(m));

  @override
  int get hashCode => Object.hash(
    layer,
    target,
    bind,
    path,
    control,
    visible,
    editable,
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
