import 'dart:convert';

import 'package:genrp/core/base/data_type.dart';

/// Lightweight conversion helpers used across the codebase.
///
/// Provides null-safe parsing and tolerant conversion for common types.
///
/// The low-level helpers (`toInt`, `toDouble`, `toBool`, and so on) are
/// still useful directly, but the preferred higher-level entry points are
/// `byType`, `byTypeName`, and `byDataType`, which dispatch from the
/// canonical `DataTypeRegister`.
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
      if (v == 'true' || v == '1' || v == 'yes' || v == 'y' || v == 'on') {
        return true;
      }
      if (v == 'false' || v == '0' || v == 'no' || v == 'n' || v == 'off') {
        return false;
      }
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
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    try {
      return value.toInt();
    } catch (_) {
      return null;
    }
  }

  /// Convert [value] using a registered base data type id.
  ///
  /// This is the preferred path when a schema or field stores only `i`.
  static dynamic byType(int dataTypeId, dynamic value, {dynamic orElse}) {
    final dataType = DataTypeRegister.type(dataTypeId);
    if (dataType == null) return orElse ?? value;
    return byDataType(dataType, value, orElse: orElse);
  }

  /// Convert [value] using a registered base data type name.
  static dynamic byTypeName(String name, dynamic value, {dynamic orElse}) {
    final dataType = DataTypeRegister.typeByName(name);
    if (dataType == null) return orElse ?? value;
    return byDataType(dataType, value, orElse: orElse);
  }

  /// Convert [value] using the target Dart representation described by [dataType].
  ///
  /// Dispatch currently keys off `dataType.d`, which keeps the converter
  /// aligned with the base registry while remaining simple.
  static dynamic byDataType(DataType dataType, dynamic value, {dynamic orElse}) {
    switch (dataType.d) {
      case 'bool':
        return toBool(value, orElse: orElse is bool ? orElse : false);
      case 'int':
        return toInt(value, orElse: orElse is int ? orElse : 0);
      case 'double':
        return toDouble(value, orElse: orElse is double ? orElse : 0.0);
      case 'String':
        return toStr(value, orElse: orElse is String ? orElse : '');
      case 'List<int>':
        return toBytes(value, orElse: orElse is List<int> ? orElse : const <int>[]);
      case 'Map<String, dynamic>':
        return toJsonMap(
          value,
          orElse: orElse is Map<String, dynamic> ? orElse : const <String, dynamic>{},
        );
      default:
        return orElse ?? value;
    }
  }

  /// Convert [value] to raw bytes.
  ///
  /// Accepts either an existing byte list, a numeric list, or a base64 string.
  static List<int> toBytes(dynamic value, {List<int> orElse = const <int>[]}) {
    if (value == null) return orElse;
    if (value is List<int>) return value;
    if (value is List) {
      try {
        return value.map((item) => toInt(item)).toList(growable: false);
      } catch (_) {
        return orElse;
      }
    }
    if (value is String) {
      try {
        return base64Decode(value);
      } catch (_) {
        return orElse;
      }
    }
    return orElse;
  }

  /// Convert [value] to a JSON-like map.
  ///
  /// Accepts a native map or a JSON string and normalizes keys to `String`.
  static Map<String, dynamic> toJsonMap(
    dynamic value, {
    Map<String, dynamic> orElse = const <String, dynamic>{},
  }) {
    if (value == null) return orElse;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((key, item) => MapEntry(key.toString(), item));
        }
      } catch (_) {
        return orElse;
      }
    }
    return orElse;
  }
}
