import 'dart:convert';

import 'package:genrp/core/model/base/bind_data_spec.dart';
import 'package:genrp/core/model/base/bind_ux_spec.dart';

class BindSpec {
  const BindSpec({
    required this.data,
    required this.ux,
    this.dataSpec,
    this.uxSpec,
    this.children = const <BindSpec>[],
    this.m = const <String, dynamic>{},
  });

  final String data;
  final String ux;
  final BindDataSpec? dataSpec;
  final BindUxSpec? uxSpec;
  final List<BindSpec> children;
  final Map<String, dynamic> m;

  factory BindSpec.fromJson(Map<String, dynamic> json) => BindSpec(
    data: json['data'] as String? ?? '',
    ux: json['ux'] as String? ?? '',
    dataSpec: json['dataSpec'] is Map
        ? BindDataSpec.fromJson(
            Map<String, dynamic>.from(json['dataSpec'] as Map),
          )
        : null,
    uxSpec: json['uxSpec'] is Map
        ? BindUxSpec.fromJson(Map<String, dynamic>.from(json['uxSpec'] as Map))
        : null,
    children:
        (json['children'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((item) => BindSpec.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false) ??
        const <BindSpec>[],
    m: Map<String, dynamic>.from(json['m'] as Map? ?? const {}),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'data': data,
    'ux': ux,
    'dataSpec': dataSpec?.toJson(),
    'uxSpec': uxSpec?.toJson(),
    'children': children.map((item) => item.toJson()).toList(growable: false),
    'm': m,
  };

  BindSpec copyWith({
    String? data,
    String? ux,
    BindDataSpec? dataSpec,
    BindUxSpec? uxSpec,
    List<BindSpec>? children,
    Map<String, dynamic>? m,
  }) {
    return BindSpec(
      data: data ?? this.data,
      ux: ux ?? this.ux,
      dataSpec: dataSpec ?? this.dataSpec,
      uxSpec: uxSpec ?? this.uxSpec,
      children: children ?? this.children,
      m: m ?? this.m,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BindSpec &&
          other.data == data &&
          other.ux == ux &&
          other.dataSpec == dataSpec &&
          other.uxSpec == uxSpec &&
          _canonicalJsonText(
                other.children
                    .map((item) => item.toJson())
                    .toList(growable: false),
              ) ==
              _canonicalJsonText(
                children.map((item) => item.toJson()).toList(growable: false),
              ) &&
          _canonicalJsonText(other.m) == _canonicalJsonText(m));

  @override
  int get hashCode => Object.hash(
    data,
    ux,
    dataSpec,
    uxSpec,
    _canonicalJsonText(
      children.map((item) => item.toJson()).toList(growable: false),
    ),
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
