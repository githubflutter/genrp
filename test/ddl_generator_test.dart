import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/db/sqlite_store.dart';
import 'package:genrp/core/generator/ddl_generator.dart';

void main() {
  test('generateCreate produces valid SQL', () {
    const entity = SqliteCatalogRow(
      catalog: 'Entity',
      i: 1,
      a: true,
      d: 10,
      e: 2,
      t: 0,
      n: 'User',
      s: 'user',
      updatedAt: 0,
    );

    const fields = [
      SqliteCatalogRow(
        catalog: 'Field',
        i: 2,
        a: true,
        d: 10,
        e: 2,
        t: 10, // String -> text
        n: 'Username',
        s: 'username',
        updatedAt: 0,
      ),
      SqliteCatalogRow(
        catalog: 'Field',
        i: 3,
        a: true,
        d: 10,
        e: 2,
        t: 1, // Int32 -> int8
        n: 'Age',
        s: 'age',
        updatedAt: 0,
      ),
    ];

    final sql = DdlGenerator.generateCreate(entity, fields);
    expect(sql, contains('CREATE TABLE t_user ('));
    expect(sql, contains('i bigint NOT NULL PRIMARY KEY'));
    expect(sql, contains('username text NOT NULL'));
    expect(sql, contains('age int8 NOT NULL'));
    expect(sql, contains(');'));
  });

  test('generateDrop produces valid SQL', () {
    const entity = SqliteCatalogRow(
      catalog: 'Entity',
      i: 1,
      a: true,
      d: 10,
      e: 2,
      t: 0,
      n: 'User',
      s: 'user',
      updatedAt: 0,
    );

    final sql = DdlGenerator.generateDrop(entity);
    expect(sql, equals('DROP TABLE IF EXISTS t_user;'));
  });

  test('generateCreateFunction produces valid SQL', () {
    const function = SqliteCatalogRow(
      catalog: 'Function',
      i: 1,
      a: true,
      d: 10,
      e: 2,
      t: 0,
      n: 'Save User',
      s: 'save_user',
      updatedAt: 0,
    );

    const parameters = [
      SqliteCatalogRow(
        catalog: 'Parameter',
        i: 2,
        a: true,
        d: 10,
        e: 2,
        t: 10, // String -> text
        n: 'Name',
        s: 'name',
        updatedAt: 0,
      ),
    ];

    final sql = DdlGenerator.generateCreateFunction(function, parameters);
    expect(sql, contains('CREATE OR REPLACE FUNCTION f_save_user('));
    expect(sql, contains('p_name text'));
    expect(sql, contains(') RETURNS jsonb AS \$\$'));
  });

  test('generateVirtualFun produces valid SQLite payload', () {
    const function = SqliteCatalogRow(
      catalog: 'Function',
      i: 1,
      a: true,
      d: 10,
      e: 2,
      t: 0,
      n: 'Save User',
      s: 'save_user',
      updatedAt: 0,
    );

    final script = DdlGenerator.generateVirtualFun(function, '{"action": "save"}');
    expect(script, contains('INSERT INTO vfun (i, a, d, e, n, s, payload) VALUES ('));
    expect(script, contains('\'{"action": "save"}\''));
  });
}
