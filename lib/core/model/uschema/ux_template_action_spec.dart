import 'package:flutter/material.dart';

enum UxTemplateAction { commit, refetch, cancel, share }

class UxTemplateActionSpec {
  const UxTemplateActionSpec({
    required this.action,
    this.label,
    this.tooltip,
    this.iconCodePoint,
    this.enabled = true,
    this.visible = true,
    this.payload = const <String, Object?>{},
    this.backgroundColorValue,
    this.foregroundColorValue,
  });

  factory UxTemplateActionSpec.fromJson(Map<String, dynamic> json) {
    return UxTemplateActionSpec(
      action: _actionFromJsonValue(json['action']),
      label: json['label'] as String?,
      tooltip: json['tooltip'] as String?,
      iconCodePoint: json['iconCodePoint'] as int?,
      enabled: json['enabled'] as bool? ?? true,
      visible: json['visible'] as bool? ?? true,
      payload: (json['payload'] as Map<Object?, Object?>?)?.map(
            (Object? key, Object? value) => MapEntry(key.toString(), value),
          ) ??
          const <String, Object?>{},
      backgroundColorValue: json['backgroundColorValue'] as int?,
      foregroundColorValue: json['foregroundColorValue'] as int?,
    );
  }

  final UxTemplateAction action;
  final String? label;
  final String? tooltip;
  final int? iconCodePoint;
  final bool enabled;
  final bool visible;
  final Map<String, Object?> payload;
  final int? backgroundColorValue;
  final int? foregroundColorValue;

  String get effectiveLabel => label ?? _defaultLabelFor(action);
  String get effectiveTooltip => tooltip ?? effectiveLabel;
  IconData get effectiveIcon =>
      iconCodePoint == null
          ? _defaultIconFor(action)
          : IconData(iconCodePoint!, fontFamily: 'MaterialIcons');

  Color? get backgroundColor =>
      backgroundColorValue == null ? null : Color(backgroundColorValue!);
  Color? get foregroundColor =>
      foregroundColorValue == null ? null : Color(foregroundColorValue!);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'action': action.name,
      'label': label,
      'tooltip': tooltip,
      'iconCodePoint': iconCodePoint,
      'enabled': enabled,
      'visible': visible,
      'payload': payload,
      'backgroundColorValue': backgroundColorValue,
      'foregroundColorValue': foregroundColorValue,
    };
  }

  static String _defaultLabelFor(UxTemplateAction action) => switch (action) {
    UxTemplateAction.commit => 'Commit',
    UxTemplateAction.refetch => 'Refetch',
    UxTemplateAction.cancel => 'Cancel',
    UxTemplateAction.share => 'Share',
  };

  static IconData _defaultIconFor(UxTemplateAction action) => switch (action) {
    UxTemplateAction.commit => Icons.check_circle_outline,
    UxTemplateAction.refetch => Icons.refresh_outlined,
    UxTemplateAction.cancel => Icons.close_outlined,
    UxTemplateAction.share => Icons.ios_share_outlined,
  };
}

UxTemplateAction _actionFromJsonValue(Object? raw) {
  if (raw is UxTemplateAction) return raw;
  if (raw is String) {
    for (final UxTemplateAction value in UxTemplateAction.values) {
      if (value.name == raw) return value;
    }
  }
  return UxTemplateAction.commit;
}
