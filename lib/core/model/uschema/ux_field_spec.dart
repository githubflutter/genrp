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
class UxFieldSpec {
  const UxFieldSpec({required this.label, this.hint = '', this.width = 260, this.dataTypeId, this.fieldMode});

  final String label;
  final String hint;
  final double width;
  final int? dataTypeId;
  final UwFieldMode? fieldMode;

  /// Convert to [UwFieldSpec] for use with [UwField] dispatcher.
  UwFieldSpec toUwFieldSpec({dynamic value, bool readOnly = false}) {
    return UwFieldSpec(mode: fieldMode, dataTypeId: dataTypeId, label: label, hint: hint.isEmpty ? null : hint, width: width, value: value, readOnly: readOnly);
  }
}
