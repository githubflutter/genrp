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
        '("schema_name", "function_name", "returns_type", "language", '
        '"target_kind", "parameter_json", "script_body") VALUES '
        '(${sqlLiteral(row['schema_name'])}, '
        '${sqlLiteral(row['function_name'])}, '
        '${sqlLiteral(row['returns_type'])}, '
        '${sqlLiteral(row['language'])}, '
        '${sqlLiteral(row['target_kind'])}, '
        '${jsonLiteral(row['parameter_json'])}, '
        '${sqlLiteral(row['script_body'])});';
  }
}
