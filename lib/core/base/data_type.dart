class DataType {
  final int i;
  final String n;
  final String d;
  final String p;
  final String s;
  final String j;

  const DataType({required this.i, required this.n, required this.d, required this.p, required this.s, required this.j});

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

class TypeMapper {
  static const List<DataType> dataTypes = <DataType>[
    DataType(i: 0, n: 'bool', d: 'bool', p: 'bool', s: 'bool', j: 'bool'),
    DataType(i: 1, n: 'Int32', d: 'int', p: 'int8', s: 'integer', j: 'int'),
    DataType(i: 2, n: 'Int53', d: 'int', p: 'bigint', s: 'integer', j: 'int'),
    DataType(i: 3, n: 'Int64', d: 'int', p: 'bigint', s: 'integer', j: 'string'),
    DataType(i: 4, n: 'Double', d: 'double', p: 'double precision', s: 'real', j: 'number'),
    DataType(i: 5, n: 'Binary', d: 'List<int>', p: 'bytea', s: 'blob', j: 'array'),
    DataType(i: 6, n: 'Json', d: 'Map<String, dynamic>', p: 'json', s: 'text', j: 'object'),
    DataType(i: 7, n: 'Jsonb', d: 'Map<String, dynamic>', p: 'jsonb', s: 'text', j: 'object'),
    DataType(i: 9, n: 'Guid', d: 'String', p: 'uuid', s: 'text', j: 'string'),
    DataType(i: 10, n: 'String', d: 'String', p: 'text', s: 'text', j: 'string'),
    DataType(i: 11, n: 'Base64', d: 'String', p: 'text', s: 'text', j: 'string'),
  ];

  static DataType _numericDataType(int id) {
    final int scale = id % 100;
    final int wholeDigits = id ~/ 100;
    final int precision = wholeDigits + scale;

    return DataType(i: id, n: 'Numeric($wholeDigits,$scale)', d: 'String', p: 'numeric($precision, $scale)', s: 'text', j: 'string');
  }

  static DataType? byId(int id) {
    for (final dataType in dataTypes) {
      if (dataType.i == id) {
        return dataType;
      }
    }

    if (id > 99) {
      return _numericDataType(id);
    }

    return null;
  }

  static DataType? byDisplayName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final dataType in dataTypes) {
      if (dataType.n.toLowerCase() == normalized) {
        return dataType;
      }
    }
    return null;
  }
}
