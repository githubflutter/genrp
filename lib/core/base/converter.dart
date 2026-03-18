/// Lightweight conversion helpers used across the codebase.
///
/// Provides null-safe parsing and tolerant conversion for common types.
class Converter {
  Converter._();

  /// Convert [value] to `int` if possible, otherwise return [orElse].
  static int toInt(dynamic value, {int orElse = 0}) {
    if (value == null) return orElse;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? orElse;
    }
    try {
      return value.toInt();
    } catch (_) {
      return orElse;
    }
  }

  /// Convert [value] to `double` if possible, otherwise return [orElse].
  static double toDouble(dynamic value, {double orElse = 0.0}) {
    if (value == null) return orElse;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? orElse;
    try {
      return (value as num).toDouble();
    } catch (_) {
      return orElse;
    }
  }

  /// Convert [value] to `bool` if possible, otherwise return [orElse].
  /// Accepts `true`/`false`, `1`/`0`, `"1"`/`"0"`, and common truthy strings.
  static bool toBool(dynamic value, {bool orElse = false}) {
    if (value == null) return orElse;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == 'true' || v == '1' || v == 'yes' || v == 'y' || v == 'on') return true;
      if (v == 'false' || v == '0' || v == 'no' || v == 'n' || v == 'off') return false;
      return orElse;
    }
    return orElse;
  }

  /// Convert [value] to `String`. Returns [orElse] when value is null.
  static String toStr(dynamic value, {String orElse = ''}) {
    if (value == null) return orElse;
    if (value is String) return value;
    return value.toString();
  }

  /// Parse an integer from [value] returning `null` on failure.
  static int? tryInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    try {
      return value.toInt();
    } catch (_) {
      return null;
    }
  }
}
