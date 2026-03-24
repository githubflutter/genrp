/// Canonical base data type record.
///
/// `i` is the stable type id and `n` is the readable type name.
/// The remaining fields describe how the same logical type maps across
/// Dart, Postgres, SQLite, and JSON representations.
class DataType {
  final int i;
  final String n;
  final String d;
  final String p;
  final String s;
  final String j;

  const DataType({
    required this.i,
    required this.n,
    required this.d,
    required this.p,
    required this.s,
    required this.j,
  });

  factory DataType.fromJson(Map<String, dynamic> json) {
    return DataType(
      i: json['i'] as int? ?? 0,
      n: json['n'] as String? ?? '',
      d: json['d'] as String? ?? '',
      p: json['p'] as String? ?? '',
      s: json['s'] as String? ?? '',
      j: json['j'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'i': i, 'n': n, 'd': d, 'p': p, 's': s, 'j': j};
  }
}

/// Registry for base data types.
///
/// This follows the same broad registry direction as `UxRegister`:
/// one place owns the canonical ids, names, and lookup rules.
///
/// For ids greater than `99`, the registry treats them as generated
/// numeric types using the compact `wholeDigits/scale` encoding.
class DataTypeRegister {
  DataTypeRegister._();

  static const List<DataType> types = <DataType>[
    DataType(i: 0, n: 'bool', d: 'bool', p: 'bool', s: 'bool', j: 'bool'),
    DataType(i: 1, n: 'Int32', d: 'int', p: 'int8', s: 'integer', j: 'int'),
    DataType(i: 2, n: 'Int53', d: 'int', p: 'bigint', s: 'integer', j: 'int'),
    DataType(
      i: 3,
      n: 'Int64',
      d: 'int',
      p: 'bigint',
      s: 'integer',
      j: 'string',
    ),
    DataType(
      i: 4,
      n: 'Double',
      d: 'double',
      p: 'double precision',
      s: 'real',
      j: 'number',
    ),
    DataType(
      i: 5,
      n: 'Binary',
      d: 'List<int>',
      p: 'bytea',
      s: 'blob',
      j: 'array',
    ),
    DataType(
      i: 6,
      n: 'Json',
      d: 'Map<String, dynamic>',
      p: 'json',
      s: 'text',
      j: 'object',
    ),
    DataType(
      i: 7,
      n: 'Jsonb',
      d: 'Map<String, dynamic>',
      p: 'jsonb',
      s: 'text',
      j: 'object',
    ),
    DataType(i: 9, n: 'Guid', d: 'String', p: 'uuid', s: 'text', j: 'string'),
    DataType(
      i: 10,
      n: 'String',
      d: 'String',
      p: 'text',
      s: 'text',
      j: 'string',
    ),
    DataType(
      i: 11,
      n: 'Base64',
      d: 'String',
      p: 'text',
      s: 'text',
      j: 'string',
    ),
  ];

  static final Map<int, DataType> _typesById = <int, DataType>{
    for (final type in types) type.i: type,
  };

  static final Map<String, DataType> _typesByName = <String, DataType>{
    for (final type in types) type.n.toLowerCase(): type,
  };

  /// Generated numeric ids use `id > 99`.
  ///
  /// Example:
  /// `1202` -> whole digits `12`, scale `2`, precision `14`.
  static bool isNumericType(int id) => id > 99;

  /// Build a generated numeric type from the compact numeric id rule.
  static DataType numericType(int id) {
    final int scale = id % 100;
    final int wholeDigits = id ~/ 100;
    final int precision = wholeDigits + scale;

    return DataType(
      i: id,
      n: 'Numeric($wholeDigits,$scale)',
      d: 'String',
      p: 'numeric($precision, $scale)',
      s: 'text',
      j: 'string',
    );
  }

  /// Resolve a type by id, including generated numeric ids.
  static DataType? type(int id) => isNumericType(id) ? numericType(id) : _typesById[id];

  /// Resolve a type by its readable name.
  static DataType? typeByName(String name) => _typesByName[name.trim().toLowerCase()];
}
