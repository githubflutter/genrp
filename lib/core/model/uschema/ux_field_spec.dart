import 'package:genrp/core/ux/uwidget/uwfield.dart';

class UxFieldSpec {
  const UxFieldSpec({
    required this.label,
    this.hint = '',
    this.width = 260,
    this.dataTypeId,
    this.fieldMode,
  });

  final String label;
  final String hint;
  final double width;
  final int? dataTypeId;
  final UwFieldMode? fieldMode;
}
