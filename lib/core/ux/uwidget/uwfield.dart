import 'package:flutter/material.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfields/uwfields.dart';

class UwFieldSpec {
  const UwFieldSpec({
    this.mode,
    this.dataTypeId,
    this.label,
    this.hint,
    this.width,
    this.value,
    this.readOnly = false,
    this.items,
    this.itemLabelBuilder,
    this.tags,
    this.tagDelimiter = ', ',
    this.showChips = true,
    this.allowDuplicates = false,
    this.stateKey,
    this.stateSrc = 0,
    this.stateScope,
    this.filterOp = FilterOp.contains,
    this.leftIcon,
    this.leftTooltip,
    this.rightIcon,
    this.rightTooltip,
    this.dateFormat,
    this.firstDate,
    this.lastDate,
    this.colorFormat = ColorFormat.hex,
    this.valueIsInt = false,
    this.allowMultiple = false,
    this.allowedExtensions,
    this.maxFileSize,
    this.showValue = false,
  });

  factory UwFieldSpec.fromJson(Map<String, dynamic> json) {
    return UwFieldSpec(
      mode: UwFieldMode.fromJsonValue(json['mode'], fallback: json['dataTypeId'] is int ? UwField.modeForDataType(json['dataTypeId'] as int) : UwFieldMode.text),
      dataTypeId: json['dataTypeId'] as int?,
      label: json['label'] as String?,
      hint: json['hint'] as String?,
      width: (json['width'] as num?)?.toDouble(),
      value: json['value'],
      readOnly: json['readOnly'] as bool? ?? false,
      items: json['items'] as List<dynamic>?,
      tags: json['tags'] as List<dynamic>?,
      tagDelimiter: json['tagDelimiter'] as String? ?? ', ',
      showChips: json['showChips'] as bool? ?? true,
      allowDuplicates: json['allowDuplicates'] as bool? ?? false,
      stateKey: json['stateKey'] as String?,
      stateSrc: json['stateSrc'] as int? ?? 0,
      stateScope: json['stateScope'] as String?,
      filterOp: _filterOpFromJsonValue(json['filterOp']),
      leftTooltip: json['leftTooltip'] as String?,
      rightTooltip: json['rightTooltip'] as String?,
      dateFormat: json['dateFormat'] as String?,
      firstDate: _dateTimeFromJsonValue(json['firstDate']),
      lastDate: _dateTimeFromJsonValue(json['lastDate']),
      colorFormat: _colorFormatFromJsonValue(json['colorFormat']),
      valueIsInt: json['valueIsInt'] as bool? ?? false,
      allowMultiple: json['allowMultiple'] as bool? ?? false,
      allowedExtensions: (json['allowedExtensions'] as List<dynamic>?)?.map((dynamic e) => e.toString()).toList(growable: false),
      maxFileSize: json['maxFileSize'] as int?,
      showValue: json['showValue'] as bool? ?? false,
    );
  }

  final UwFieldMode? mode;
  final int? dataTypeId;

  final String? label;
  final String? hint;
  final double? width;

  final dynamic value;
  final bool readOnly;

  final List<dynamic>? items;
  final String Function(dynamic)? itemLabelBuilder;

  final List<dynamic>? tags;
  final String tagDelimiter;
  final bool showChips;
  final bool allowDuplicates;

  final String? stateKey;
  final int stateSrc;
  final String? stateScope;

  UwStateBindingSpec? get stateBinding {
    final key = stateKey;
    if (key == null || key.isEmpty) return null;
    return UwStateBindingSpec.fromLegacy(
      key: key,
      sourceCode: stateSrc,
      uwidget: stateScope,
    );
  }

  final FilterOp filterOp;

  final String? dateFormat;
  final DateTime? firstDate;
  final DateTime? lastDate;

  final ColorFormat colorFormat;
  final bool valueIsInt;

  final bool allowMultiple;
  final List<String>? allowedExtensions;
  final int? maxFileSize;

  final bool showValue;

  final IconData? leftIcon;
  final String? leftTooltip;
  final IconData? rightIcon;
  final String? rightTooltip;

  UwFieldMode get effectiveMode {
    if (mode != null) return mode!;
    if (dataTypeId != null) {
      return UwField.modeForDataType(dataTypeId!);
    }
    return UwFieldMode.text;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mode': mode?.code,
      'dataTypeId': dataTypeId,
      'label': label,
      'hint': hint,
      'width': width,
      'value': value,
      'readOnly': readOnly,
      'items': items,
      'tags': tags,
      'tagDelimiter': tagDelimiter,
      'showChips': showChips,
      'allowDuplicates': allowDuplicates,
      'stateKey': stateKey,
      'stateSrc': stateSrc,
      'stateScope': stateScope,
      'filterOp': filterOp.name,
      'leftTooltip': leftTooltip,
      'rightTooltip': rightTooltip,
      'dateFormat': dateFormat,
      'firstDate': firstDate?.toIso8601String(),
      'lastDate': lastDate?.toIso8601String(),
      'colorFormat': colorFormat.name,
      'valueIsInt': valueIsInt,
      'allowMultiple': allowMultiple,
      'allowedExtensions': allowedExtensions,
      'maxFileSize': maxFileSize,
      'showValue': showValue,
    };
  }
}

FilterOp _filterOpFromJsonValue(Object? raw) {
  if (raw is FilterOp) return raw;
  if (raw is String) {
    for (final FilterOp value in FilterOp.values) {
      if (value.name == raw) return value;
    }
  }
  return FilterOp.contains;
}

DateTime? _dateTimeFromJsonValue(Object? raw) {
  if (raw is DateTime) return raw;
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  return null;
}

ColorFormat _colorFormatFromJsonValue(Object? raw) {
  if (raw is ColorFormat) return raw;
  if (raw is String) {
    for (final ColorFormat value in ColorFormat.values) {
      if (value.name == raw) return value;
    }
  }
  return ColorFormat.hex;
}

class UwFieldCallbacks {
  const UwFieldCallbacks({
    this.onChanged,
    this.onRefresh,
    this.onTagAdded,
    this.onTagRemoved,
    this.onLink,
    this.onPush,
    this.onFilterApplied,
    this.onFilterCleared,
    this.onLeftPressed,
    this.onRightPressed,
  });

  final void Function(dynamic)? onChanged;
  final void Function()? onRefresh;
  final void Function(dynamic)? onTagAdded;
  final void Function(int)? onTagRemoved;
  final void Function(bool)? onLink;
  final void Function(dynamic)? onPush;
  final void Function(Map<String, dynamic>)? onFilterApplied;
  final void Function()? onFilterCleared;
  final void Function()? onLeftPressed;
  final void Function()? onRightPressed;
}

class UwField extends StatelessWidget with Ux {
  const UwField({required this.i, required this.autopilot, required this.spec, this.callbacks = const UwFieldCallbacks(), this.s = 0, super.key});

  final int uwid = 14;
  final int s;
  @override
  final int i;
  @override
  final String n = 'field';

  final Autopilot autopilot;
  final UwFieldSpec spec;
  final UwFieldCallbacks callbacks;

  static UwFieldMode modeForDataType(int dataTypeId) {
    if (dataTypeId == 0) return UwFieldMode.bool_;
    if (dataTypeId >= 1 && dataTypeId <= 4) return UwFieldMode.number;
    if (dataTypeId == 6 || dataTypeId == 7) return UwFieldMode.json;
    if (dataTypeId > 99) return UwFieldMode.number;
    return UwFieldMode.text;
  }

  @override
  Widget build(BuildContext context) {
    return _buildDedicatedWidget(spec.effectiveMode);
  }

  Widget _buildDedicatedWidget(UwFieldMode mode) {
    switch (mode) {
      case UwFieldMode.text:
        return UwFieldText(
          i: i,
          autopilot: autopilot,
          spec: UwFieldTextSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value?.toString(),
            readOnly: spec.readOnly,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.number:
        return UwFieldNumber(
          i: i,
          autopilot: autopilot,
          spec: UwFieldNumberSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value is num ? spec.value : num.tryParse(spec.value?.toString() ?? ''),
            readOnly: spec.readOnly,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.json:
        return UwFieldJson(
          i: i,
          autopilot: autopilot,
          spec: UwFieldJsonSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value?.toString(),
            readOnly: spec.readOnly,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.bool_:
        return UwFieldBool(
          i: i,
          autopilot: autopilot,
          spec: UwFieldBoolSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value == true,
            readOnly: spec.readOnly,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.date:
        return UwFieldDate(
          i: i,
          autopilot: autopilot,
          spec: UwFieldDateSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value is int ? spec.value : int.tryParse(spec.value?.toString() ?? ''),
            readOnly: spec.readOnly,
            firstDate: spec.firstDate,
            lastDate: spec.lastDate,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.datetime:
        return UwFieldDateTime(
          i: i,
          autopilot: autopilot,
          spec: UwFieldDateTimeSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value is int ? spec.value : int.tryParse(spec.value?.toString() ?? ''),
            readOnly: spec.readOnly,
            firstDate: spec.firstDate,
            lastDate: spec.lastDate,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.dates:
        return UwFieldDates(
          i: i,
          autopilot: autopilot,
          spec: UwFieldDatesSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value is List ? spec.value : null,
            readOnly: spec.readOnly,
            firstDate: spec.firstDate,
            lastDate: spec.lastDate,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.datetimes:
        return UwFieldDateTimes(
          i: i,
          autopilot: autopilot,
          spec: UwFieldDateTimesSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value is List ? spec.value : null,
            readOnly: spec.readOnly,
            firstDate: spec.firstDate,
            lastDate: spec.lastDate,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.daterange:
        return UwFieldDateRange(
          i: i,
          autopilot: autopilot,
          spec: UwFieldDateRangeSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value is List ? spec.value : null,
            readOnly: spec.readOnly,
            firstDate: spec.firstDate,
            lastDate: spec.lastDate,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.datetimerange:
        return UwFieldDateTimeRange(
          i: i,
          autopilot: autopilot,
          spec: UwFieldDateTimeRangeSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value is List ? spec.value : null,
            readOnly: spec.readOnly,
            firstDate: spec.firstDate,
            lastDate: spec.lastDate,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.combo:
      case UwFieldMode.select:
        return UwFieldOverlay(
          i: i,
          autopilot: autopilot,
          spec: UwFieldOverlaySpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value,
            readOnly: spec.readOnly,
            isSelectMode: mode == UwFieldMode.select,
            items: spec.items,
            itemLabelBuilder: spec.itemLabelBuilder,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.link:
        return UwFieldLinker(
          i: i,
          autopilot: autopilot,
          spec: UwFieldLinkerSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value,
            readOnly: spec.readOnly,
            stateKey: spec.stateKey,
            stateSrc: spec.stateSrc,
            stateScope: spec.stateScope,
            leftTooltip: spec.leftTooltip,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.tag:
        return UwFieldTag(
          i: i,
          autopilot: autopilot,
          spec: UwFieldTagSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            tags: spec.tags,
            items: spec.items,
            itemLabelBuilder: spec.itemLabelBuilder,
            tagDelimiter: spec.tagDelimiter,
            showChips: spec.showChips,
            allowDuplicates: spec.allowDuplicates,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: UwFieldCallbacks(
            onChanged: callbacks.onChanged,
            onTagAdded: callbacks.onTagAdded,
            onTagRemoved: callbacks.onTagRemoved,
            onLeftPressed: callbacks.onLeftPressed,
            onRightPressed: callbacks.onRightPressed,
          ),
          s: s,
        );
      case UwFieldMode.filter:
        return UwFieldFilter(
          i: i,
          autopilot: autopilot,
          spec: UwFieldFilterSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            filterOp: spec.filterOp,
            leftTooltip: spec.leftTooltip,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: UwFieldCallbacks(
            onChanged: callbacks.onChanged,
            onFilterApplied: callbacks.onFilterApplied,
            onFilterCleared: callbacks.onFilterCleared,
            onLeftPressed: callbacks.onLeftPressed,
            onRightPressed: callbacks.onRightPressed,
          ),
          s: s,
        );
      case UwFieldMode.file:
        return UwFieldFile(
          i: i,
          autopilot: autopilot,
          spec: UwFieldFileSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value,
            readOnly: spec.readOnly,
            allowMultiple: spec.allowMultiple,
            allowedExtensions: spec.allowedExtensions,
            maxFileSize: spec.maxFileSize,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.color:
        return UwFieldColor(
          i: i,
          autopilot: autopilot,
          spec: UwFieldColorSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value,
            readOnly: spec.readOnly,
            format: spec.colorFormat,
            valueIsInt: spec.valueIsInt,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
      case UwFieldMode.checklist:
        return UwFieldChecklist(
          i: i,
          autopilot: autopilot,
          spec: UwFieldChecklistSpec(
            label: spec.label,
            hint: spec.hint,
            width: spec.width,
            value: spec.value,
            readOnly: spec.readOnly,
            allowMultiple: spec.allowMultiple,
            items: spec.items,
            itemLabelBuilder: spec.itemLabelBuilder,
            showValue: spec.showValue,
            leftIcon: spec.leftIcon,
            leftTooltip: spec.leftTooltip,
            rightIcon: spec.rightIcon,
            rightTooltip: spec.rightTooltip,
          ),
          callbacks: callbacks,
          s: s,
        );
    }
  }
}
