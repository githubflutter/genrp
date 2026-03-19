import 'package:genrp/core/db/db_contract.dart';

class WebClient {
  const WebClient();

  Map<String, Object?> buildCreateRequest(
    DbCrudSpec spec, {
    String? username,
    String? password,
  }) => _buildCrudRequest(
    operation: 'insert',
    spec: spec,
    username: username,
    password: password,
  );

  Map<String, Object?> buildReadRequest(
    DbCrudSpec spec, {
    String? username,
    String? password,
  }) => _buildCrudRequest(
    operation: 'select',
    spec: spec,
    username: username,
    password: password,
  );

  Map<String, Object?> buildUpdateRequest(
    DbCrudSpec spec, {
    String? username,
    String? password,
  }) => _buildCrudRequest(
    operation: 'update',
    spec: spec,
    username: username,
    password: password,
  );

  Map<String, Object?> buildDeleteRequest(
    DbCrudSpec spec, {
    String? username,
    String? password,
  }) => _buildCrudRequest(
    operation: spec.softDelete ? 'softDelete' : 'delete',
    spec: spec,
    username: username,
    password: password,
  );

  Map<String, Object?> buildActionRequest({
    required int actionId,
    required Object? data,
    String? username,
    String? password,
  }) {
    return <String, Object?>{
      'a': actionId,
      if (username != null && username.isNotEmpty) 'u': username,
      if (password != null && password.isNotEmpty) 'p': password,
      'data': data,
    };
  }

  Map<String, Object?> _buildCrudRequest({
    required String operation,
    required DbCrudSpec spec,
    String? username,
    String? password,
  }) {
    _assertFoundation(spec);
    final target = spec.schema == null || spec.schema!.isEmpty
        ? spec.table
        : '${spec.schema}.${spec.table}';
    return <String, Object?>{
      'op': operation,
      if (username != null && username.isNotEmpty) 'u': username,
      if (password != null && password.isNotEmpty) 'p': password,
      'data': <String, Object?>{
        'target': target,
        if (spec.columns.isNotEmpty) 'columns': spec.columns,
        if (spec.values.isNotEmpty) 'values': spec.values,
        if (spec.where.isNotEmpty) 'where': spec.where,
        if (spec.orderBy.isNotEmpty) 'orderBy': spec.orderBy,
        if (spec.limit != null) 'limit': spec.limit,
      },
    };
  }

  void _assertFoundation(DbCrudSpec spec) {
    if (spec.kind == DbTargetKind.business) {
      throw ArgumentError(
        'Business-table CRUD must go through function-style actions.',
      );
    }
  }
}
