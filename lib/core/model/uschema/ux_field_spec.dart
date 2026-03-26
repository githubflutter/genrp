import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/core/ux/uwidget/uwfield.dart';

/// Spec for code-generated field specs.
///
/// This is a lightweight spec used by GenUx code generation.
/// For runtime usage, consider using dedicated spec classes:
/// - [UwFieldTextSpec], [UwFieldNumberSpec], [UwFieldJsonSpec], [UwFieldBoolSpec]
/// - [UwFieldPickerSpec], [UwFieldOverlaySpec], [UwFieldTagSpec]
/// - [UwFieldFilterSpec], [UwFieldLinkerSpec]
///
/// Or use the unified [UwFieldSpec] for mode-dispatched convenience.
class UxFieldSpec with UwStateBindable {
  const UxFieldSpec({
    required this.label,
    this.hint = '',
    this.width = 260,
    this.dataTypeId,
    this.fieldMode,
    this.value,
    this.stateKey,
    this.stateSrc = 0,
    this.stateScope,
  });

  factory UxFieldSpec.fromJson(Map<String, dynamic> json) {
    return UxFieldSpec(
      label: json['label']?.toString() ?? '',
      hint: json['hint']?.toString() ?? '',
      width: (json['width'] as num?)?.toDouble() ?? 260,
      dataTypeId: (json['dataTypeId'] as num?)?.toInt(),
      fieldMode: UwFieldMode.fromJsonValue(json['fieldMode']),
      value: json['value'],
      stateKey: json['stateKey'] as String?,
      stateSrc: (json['stateSrc'] as num?)?.toInt() ?? 0,
      stateScope: json['stateScope'] as String?,
    );
  }

  final String label;
  final String hint;
  final double width;
  final int? dataTypeId;
  final UwFieldMode? fieldMode;
  final dynamic value;
  @override
  final String? stateKey;
  @override
  final int stateSrc;
  @override
  final String? stateScope;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'hint': hint,
      'width': width,
      'dataTypeId': dataTypeId,
      'fieldMode': fieldMode?.name,
      'value': value,
      'stateKey': stateKey,
      'stateSrc': stateSrc,
      'stateScope': stateScope,
    };
  }

  /// Convert to [UwFieldSpec] for use with [UwField] dispatcher.
  UwFieldSpec toUwFieldSpec({dynamic value, bool readOnly = false}) {
    return UwFieldSpec(
      mode: fieldMode,
      dataTypeId: dataTypeId,
      label: label,
      hint: hint.isEmpty ? null : hint,
      width: width,
      value: value ?? this.value,
      readOnly: readOnly,
      stateKey: stateKey,
      stateSrc: stateSrc,
      stateScope: stateScope,
    );
  }
}
