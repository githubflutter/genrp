import 'package:genrp/core/model/uschema/ux_template_action_spec.dart';

enum UxActionHolderPosition { top, bottom, left, right, floating, contextual }

enum UxActionHolderPresentation {
  toolbar,
  rail,
  drawer,
  floatingIsland,
  menu,
}

enum UxActionHolderTrigger { always, rightClick, longPress, manual }

class UxActionHolderSpec {
  const UxActionHolderSpec({
    required this.index,
    this.position = UxActionHolderPosition.top,
    this.presentation = UxActionHolderPresentation.toolbar,
    this.trigger = UxActionHolderTrigger.always,
    this.visible = true,
    this.label,
    this.scopeVid,
    this.actionKinds = const <UxTemplateAction>[],
  });

  factory UxActionHolderSpec.fromJson(Map<String, dynamic> json) {
    return UxActionHolderSpec(
      index: json['index'] as int? ?? 1,
      position: _positionFromJsonValue(json['position']),
      presentation: _presentationFromJsonValue(json['presentation']),
      trigger: _triggerFromJsonValue(json['trigger']),
      visible: json['visible'] as bool? ?? true,
      label: json['label'] as String?,
      scopeVid: json['scopeVid'] as int?,
      actionKinds: (json['actionKinds'] as List<dynamic>?)
              ?.map((dynamic value) => _templateActionFromJsonValue(value))
              .toList(growable: false) ??
          const <UxTemplateAction>[],
    );
  }

  final int index;
  final UxActionHolderPosition position;
  final UxActionHolderPresentation presentation;
  final UxActionHolderTrigger trigger;
  final bool visible;
  final String? label;
  final int? scopeVid;
  final List<UxTemplateAction> actionKinds;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'index': index,
      'position': position.name,
      'presentation': presentation.name,
      'trigger': trigger.name,
      'visible': visible,
      'label': label,
      'scopeVid': scopeVid,
      'actionKinds': actionKinds
          .map((UxTemplateAction action) => action.name)
          .toList(growable: false),
    };
  }
}

UxActionHolderPosition _positionFromJsonValue(Object? raw) {
  if (raw is UxActionHolderPosition) return raw;
  if (raw is String) {
    for (final UxActionHolderPosition value in UxActionHolderPosition.values) {
      if (value.name == raw) return value;
    }
  }
  return UxActionHolderPosition.top;
}

UxActionHolderPresentation _presentationFromJsonValue(Object? raw) {
  if (raw is UxActionHolderPresentation) return raw;
  if (raw is String) {
    for (final UxActionHolderPresentation value
        in UxActionHolderPresentation.values) {
      if (value.name == raw) return value;
    }
  }
  return UxActionHolderPresentation.toolbar;
}

UxActionHolderTrigger _triggerFromJsonValue(Object? raw) {
  if (raw is UxActionHolderTrigger) return raw;
  if (raw is String) {
    for (final UxActionHolderTrigger value in UxActionHolderTrigger.values) {
      if (value.name == raw) return value;
    }
  }
  return UxActionHolderTrigger.always;
}

UxTemplateAction _templateActionFromJsonValue(Object? raw) {
  if (raw is UxTemplateAction) return raw;
  if (raw is String) {
    for (final UxTemplateAction value in UxTemplateAction.values) {
      if (value.name == raw) return value;
    }
  }
  return UxTemplateAction.commit;
}
