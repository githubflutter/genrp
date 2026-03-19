import 'package:genrp/core/base/data_type.dart';
import 'package:genrp/core/db/sqlite_store.dart';

class DdlGenerator {
  static String generateCreate(SqliteCatalogRow entity, List<SqliteCatalogRow> fields) {
    final buffer = StringBuffer();
    buffer.writeln('CREATE TABLE t_${entity.s} (');
    final lines = <String>[];

    // Default columns
    lines.add('  i bigint NOT NULL PRIMARY KEY');
    lines.add('  a boolean NOT NULL');
    lines.add('  d bigint NOT NULL');
    lines.add('  e bigint NOT NULL');

    // Add fields
    for (final field in fields) {
      if (!field.a) continue;
      final dataType = TypeMapper.byId(field.t);
      if (dataType != null) {
        lines.add('  ${field.s} ${dataType.p} NOT NULL');
      }
    }

    buffer.writeln(lines.join(',\n'));
    buffer.writeln(');');
    return buffer.toString();
  }

  static String generateDrop(SqliteCatalogRow entity) {
    return 'DROP TABLE IF EXISTS t_${entity.s};';
  }

  static String generateCreateFunction(SqliteCatalogRow function, List<SqliteCatalogRow> parameters) {
    final buffer = StringBuffer();
    buffer.writeln('CREATE OR REPLACE FUNCTION f_${function.s}(');

    final pLines = <String>[];
    for (final param in parameters) {
      if (!param.a) continue;
      final dataType = TypeMapper.byId(param.t);
      if (dataType != null) {
        pLines.add('  p_${param.s} ${dataType.p}');
      }
    }

    if (pLines.isNotEmpty) {
      buffer.writeln(pLines.join(',\n'));
    }

    buffer.writeln(') RETURNS jsonb AS \$\$');
    buffer.writeln('BEGIN');
    buffer.writeln('  -- Function implementation goes here');
    buffer.writeln('  RETURN \'{"status": "ok"}\'::jsonb;');
    buffer.writeln('END;');
    buffer.writeln('\$\$ LANGUAGE plpgsql;');

    return buffer.toString();
  }

  static String generateVirtualFun(SqliteCatalogRow function, String script) {
    final buffer = StringBuffer();
    buffer.writeln('-- SQLite vfun script payload for ${function.n}');
    buffer.writeln('INSERT INTO vfun (i, a, d, e, n, s, payload) VALUES (');
    buffer.writeln('  ${function.i},');
    buffer.writeln('  ${function.a ? 1 : 0},');
    buffer.writeln('  ${function.d},');
    buffer.writeln('  ${function.e},');
    buffer.writeln('  \'${function.n}\',');
    buffer.writeln('  \'${function.s}\',');
    buffer.writeln('  \'${script.replaceAll('\'', '\'\'')}\'');
    buffer.writeln(');');
    return buffer.toString();
  }
}
