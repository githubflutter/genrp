import 'dart:convert';

import 'package:genrp/core/base/systype.dart';

export 'package:genrp/core/base/systype.dart';

class DbDatabaseSpec {
  const DbDatabaseSpec({
    required this.name,
    this.filePath,
    this.owner,
    this.options = const <String, Object?>{},
  });

  final String name;
  final String? filePath;
  final String? owner;
  final Map<String, Object?> options;
}

class DbColumnSpec {
  const DbColumnSpec({
    required this.name,
    required this.type,
    this.primaryKey = false,
    this.unique = false,
    this.defaultExpression,
    this.referencesTable,
    this.referencesColumn,
  });

  final String name;
  final String type;
  final bool primaryKey;
  final bool unique;
  final String? defaultExpression;
  final String? referencesTable;
  final String? referencesColumn;

  Map<String, Object?> toMap() => <String, Object?>{
    'name': name,
    'type': type,
    'primaryKey': primaryKey,
    'unique': unique,
    'defaultExpression': defaultExpression,
    'referencesTable': referencesTable,
    'referencesColumn': referencesColumn,
  };
}

class DbTableSpec {
  const DbTableSpec({
    required this.name,
    required this.columns,
    this.schema,
    this.ifNotExists = true,
    this.kind = DbTargetKind.foundation,
  });

  final String name;
  final String? schema;
  final List<DbColumnSpec> columns;
  final bool ifNotExists;
  final DbTargetKind kind;
}

class DbFunctionParameterSpec {
  const DbFunctionParameterSpec({
    required this.name,
    required this.type,
    this.mode = 'IN',
    this.defaultExpression,
  });

  final String name;
  final String type;
  final String mode;
  final String? defaultExpression;

  Map<String, Object?> toMap() => <String, Object?>{
    'name': name,
    'type': type,
    'mode': mode,
    'defaultExpression': defaultExpression,
  };
}

class DbFunctionSpec {
  const DbFunctionSpec({
    required this.name,
    required this.body,
    this.schema,
    this.parameters = const <DbFunctionParameterSpec>[],
    this.returns = 'void',
    this.language = 'sql',
    this.replace = true,
    this.kind = DbTargetKind.foundation,
    this.virtualTableName = 'vfun',
    this.i = 0,
    this.a = true,
    this.d = 0,
    this.e = 0,
    this.ei = 0,
    this.t = 0,
    this.tis = const <int>[0],
    this.n = '',
    this.s = '',
    this.sql1 = '',
    this.sql2 = '',
    this.sql3 = '',
  });

  final String name;
  final String? schema;
  final List<DbFunctionParameterSpec> parameters;
  final String returns;
  final String body;
  final String language;
  final bool replace;
  final DbTargetKind kind;
  final String virtualTableName;
  final int i;
  final bool a;
  final int d;
  final int e;
  final int ei;
  final int t;
  final List<int> tis;
  final String n;
  final String s;
  final String sql1;
  final String sql2;
  final String sql3;

  Map<String, Object?> toVirtualFunRow() => <String, Object?>{
    'i': i,
    'a': a,
    'd': d,
    'e': e,
    'ei': ei,
    't': t,
    'n': n.isEmpty ? name : n,
    's': s.isEmpty ? name : s,
    'tis': tis.isEmpty ? const <int>[0] : tis,
    'sql1': sql1.isEmpty ? body : sql1,
    'sql2': sql2,
    'sql3': sql3,
  };
}

class DbCrudSpec {
  const DbCrudSpec({
    required this.table,
    this.schema,
    this.columns = const <String>[],
    this.values = const <String, Object?>{},
    this.where = const <String, Object?>{},
    this.orderBy = const <String>[],
    this.limit,
    this.softDelete = false,
    this.activeColumn = 'a',
    this.kind = DbTargetKind.foundation,
  });

  final String table;
  final String? schema;
  final List<String> columns;
  final Map<String, Object?> values;
  final Map<String, Object?> where;
  final List<String> orderBy;
  final int? limit;
  final bool softDelete;
  final String activeColumn;
  final DbTargetKind kind;
}

String quoteIdentifier(String identifier) =>
    '"${identifier.replaceAll('"', '""')}"';

String qualifyIdentifier(String? schema, String name) {
  final tableName = quoteIdentifier(name);
  if (schema == null || schema.isEmpty) return tableName;
  return '${quoteIdentifier(schema)}.$tableName';
}

String sqlLiteral(Object? value) {
  if (value == null) return 'NULL';
  if (value is bool) return value ? 'TRUE' : 'FALSE';
  if (value is num) return value.toString();
  if (value is DateTime) return "'${value.toUtc().toIso8601String()}'";
  if (value is Map || value is List) {
    final encoded = jsonEncode(value).replaceAll("'", "''");
    return "'$encoded'";
  }
  final text = value.toString().replaceAll("'", "''");
  return "'$text'";
}

String jsonLiteral(Object? value) => sqlLiteral(jsonEncode(value));

String buildColumnDefinition(DbColumnSpec column) {
  final buffer = StringBuffer('${quoteIdentifier(column.name)} ${column.type}');
  buffer.write(' NOT NULL');
  if (column.primaryKey) buffer.write(' PRIMARY KEY');
  if (column.unique) buffer.write(' UNIQUE');
  if (column.defaultExpression != null &&
      column.defaultExpression!.trim().isNotEmpty) {
    buffer.write(' DEFAULT ${column.defaultExpression}');
  }
  if (column.referencesTable != null && column.referencesTable!.isNotEmpty) {
    buffer.write(' REFERENCES ${quoteIdentifier(column.referencesTable!)}');
    if (column.referencesColumn != null &&
        column.referencesColumn!.isNotEmpty) {
      buffer.write(' (${quoteIdentifier(column.referencesColumn!)})');
    }
  }
  return buffer.toString();
}

String buildAssignments(
  Map<String, Object?> values, {
  String Function(Object? value)? literalBuilder,
}) {
  if (values.isEmpty) {
    throw ArgumentError('values must not be empty');
  }
  final literal = literalBuilder ?? sqlLiteral;
  return values.entries
      .map((entry) => '${quoteIdentifier(entry.key)} = ${literal(entry.value)}')
      .join(', ');
}

String buildWhereClause(
  Map<String, Object?> where, {
  String Function(Object? value)? literalBuilder,
}) {
  if (where.isEmpty) {
    throw ArgumentError('where must not be empty');
  }
  final literal = literalBuilder ?? sqlLiteral;
  return where.entries
      .map((entry) {
        if (entry.value == null) {
          return '${quoteIdentifier(entry.key)} IS NULL';
        }
        return '${quoteIdentifier(entry.key)} = ${literal(entry.value)}';
      })
      .join(' AND ');
}

String renderFunctionParameters(List<DbFunctionParameterSpec> parameters) {
  return parameters
      .map((parameter) {
        final buffer = StringBuffer(
          '${parameter.mode.toUpperCase()} ${quoteIdentifier(parameter.name)} '
          '${parameter.type}',
        );
        if (parameter.defaultExpression != null &&
            parameter.defaultExpression!.trim().isNotEmpty) {
          buffer.write(' DEFAULT ${parameter.defaultExpression}');
        }
        return buffer.toString();
      })
      .join(', ');
}
