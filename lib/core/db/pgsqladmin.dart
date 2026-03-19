import 'package:genrp/core/db/db_contract.dart';

class PgsqlAdmin {
  const PgsqlAdmin();

  String buildCreateDatabase(DbDatabaseSpec spec) {
    final buffer = StringBuffer(
      'CREATE DATABASE ${quoteIdentifier(spec.name)}',
    );
    if (spec.owner != null && spec.owner!.isNotEmpty) {
      buffer.write(' OWNER ${quoteIdentifier(spec.owner!)}');
    }
    for (final entry in spec.options.entries) {
      buffer.write(' ${entry.key.toUpperCase()} ${entry.value}');
    }
    buffer.write(';');
    return buffer.toString();
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
    final buffer = StringBuffer('CREATE');
    if (spec.replace) buffer.write(' OR REPLACE');
    buffer.write(' FUNCTION ${qualifyIdentifier(spec.schema, spec.name)}(');
    buffer.write(renderFunctionParameters(spec.parameters));
    buffer.write(')\nRETURNS ${spec.returns}\n');
    buffer.write('LANGUAGE ${spec.language}\n');
    buffer.write('AS \$\$\n${spec.body.trim()}\n\$\$;');
    return buffer.toString();
  }
}
