import 'package:genrp/core/db/db_contract.dart';

class SqliteClient {
  const SqliteClient();

  String buildSelect(DbCrudSpec spec) {
    _assertFoundation(spec);
    final columns = spec.columns.isEmpty
        ? '*'
        : spec.columns.map(quoteIdentifier).join(', ');
    final buffer = StringBuffer(
      'SELECT $columns FROM ${qualifyIdentifier(spec.schema, spec.table)}',
    );
    if (spec.where.isNotEmpty) {
      buffer.write(
        ' WHERE ${buildWhereClause(spec.where, literalBuilder: _literal)}',
      );
    }
    if (spec.orderBy.isNotEmpty) {
      buffer.write(' ORDER BY ${spec.orderBy.join(', ')}');
    }
    if (spec.limit != null) {
      buffer.write(' LIMIT ${spec.limit}');
    }
    buffer.write(';');
    return buffer.toString();
  }

  String buildInsert(DbCrudSpec spec) {
    _assertFoundation(spec);
    if (spec.values.isEmpty) {
      throw ArgumentError('values must not be empty');
    }
    final columns = spec.values.keys.map(quoteIdentifier).join(', ');
    final values = spec.values.values.map(_literal).join(', ');
    return 'INSERT INTO ${qualifyIdentifier(spec.schema, spec.table)} '
        '($columns) VALUES ($values);';
  }

  String buildUpdate(DbCrudSpec spec) {
    _assertFoundation(spec);
    return 'UPDATE ${qualifyIdentifier(spec.schema, spec.table)} SET '
        '${buildAssignments(spec.values, literalBuilder: _literal)} WHERE '
        '${buildWhereClause(spec.where, literalBuilder: _literal)};';
  }

  String buildDelete(DbCrudSpec spec) {
    _assertFoundation(spec);
    if (spec.softDelete) {
      return 'UPDATE ${qualifyIdentifier(spec.schema, spec.table)} SET '
          '${quoteIdentifier(spec.activeColumn)} = 0 WHERE '
          '${buildWhereClause(spec.where, literalBuilder: _literal)};';
    }
    return 'DELETE FROM ${qualifyIdentifier(spec.schema, spec.table)} WHERE '
        '${buildWhereClause(spec.where, literalBuilder: _literal)};';
  }

  void _assertFoundation(DbCrudSpec spec) {
    if (spec.kind == DbTargetKind.business) {
      throw ArgumentError(
        'Business-table CRUD must go through function-style actions.',
      );
    }
  }

  String _literal(Object? value) {
    if (value is bool) return value ? '1' : '0';
    return sqlLiteral(value);
  }
}
