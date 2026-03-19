import 'package:genrp/core/db/db_contract.dart';

class SqliteAdmin {
  const SqliteAdmin();

  String buildCreateDatabase(DbDatabaseSpec spec) {
    final filePath = spec.filePath ?? '${spec.name}.sqlite';
    return 'ATTACH DATABASE ${sqlLiteral(filePath)} AS '
        '${quoteIdentifier(spec.name)};';
  }

  String buildCreateTable(DbTableSpec spec) {
    if (spec.columns.isEmpty) {
      throw ArgumentError('columns must not be empty');
    }
    final buffer = StringBuffer('CREATE TABLE ');
    if (spec.ifNotExists) buffer.write('IF NOT EXISTS ');
    buffer.write(qualifyIdentifier(spec.schema, spec.name));
    buffer.write(' (\n  ');
    buffer.write(spec.columns.map(buildColumnDefinition).join(',\n  '));
    buffer.write('\n);');
    return buffer.toString();
  }

  String buildCreateFunction(DbFunctionSpec spec) {
    final row = spec.toVirtualFunRow();
    return 'INSERT INTO ${quoteIdentifier(spec.virtualTableName)} '
        '("i", "a", "d", "e", "ei", "t", "n", "s", "tis", "sql1", "sql2", "sql3") VALUES '
        '(${_literal(row['i'])}, '
        '${_literal(row['a'])}, '
        '${_literal(row['d'])}, '
        '${_literal(row['e'])}, '
        '${_literal(row['ei'])}, '
        '${_literal(row['t'])}, '
        '${sqlLiteral(row['n'])}, '
        '${sqlLiteral(row['s'])}, '
        '${jsonLiteral(row['tis'])}, '
        '${sqlLiteral(row['sql1'])}, '
        '${sqlLiteral(row['sql2'])}, '
        '${sqlLiteral(row['sql3'])});';
  }

  String _literal(Object? value) {
    if (value is bool) return value ? '1' : '0';
    return sqlLiteral(value);
  }
}
