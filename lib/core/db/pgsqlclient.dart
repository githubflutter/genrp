import 'package:genrp/core/db/db_contract.dart';

class PgsqlClient {
  const PgsqlClient();

  String buildSelect(DbCrudSpec spec) {
    _assertFoundation(spec);
    final columns = spec.columns.isEmpty
        ? '*'
        : spec.columns.map(quoteIdentifier).join(', ');
    final buffer = StringBuffer(
      'SELECT $columns FROM ${qualifyIdentifier(spec.schema, spec.table)}',
    );
    if (spec.where.isNotEmpty) {
      buffer.write(' WHERE ${buildWhereClause(spec.where)}');
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
    final values = spec.values.values.map(sqlLiteral).join(', ');
    return 'INSERT INTO ${qualifyIdentifier(spec.schema, spec.table)} '
        '($columns) VALUES ($values);';
  }

  String buildUpdate(DbCrudSpec spec) {
    _assertFoundation(spec);
    return 'UPDATE ${qualifyIdentifier(spec.schema, spec.table)} SET '
        '${buildAssignments(spec.values)} WHERE '
        '${buildWhereClause(spec.where)};';
  }

  String buildDelete(DbCrudSpec spec) {
    _assertFoundation(spec);
    if (spec.softDelete) {
      return 'UPDATE ${qualifyIdentifier(spec.schema, spec.table)} SET '
          '${quoteIdentifier(spec.activeColumn)} = FALSE WHERE '
          '${buildWhereClause(spec.where)};';
    }
    return 'DELETE FROM ${qualifyIdentifier(spec.schema, spec.table)} WHERE '
        '${buildWhereClause(spec.where)};';
  }

  void _assertFoundation(DbCrudSpec spec) {
    if (spec.kind == DbTargetKind.business) {
      throw ArgumentError(
        'Business-table CRUD must go through function-style actions.',
      );
    }
  }
}
