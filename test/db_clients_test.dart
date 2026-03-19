import 'package:genrp/core/base/bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/db/db_contract.dart';
import 'package:genrp/core/db/pgsqladmin.dart';
import 'package:genrp/core/db/pgsqlclient.dart';
import 'package:genrp/core/db/sqliteadmin.dart';
import 'package:genrp/core/db/sqliteclient.dart';
import 'package:genrp/core/base/sysfunc.dart';
import 'package:genrp/core/base/systable.dart';
import 'package:genrp/core/db/webclient.dart';

void main() {
  group('db admin and client builders', () {
    test('PgsqlAdmin builds create database and table scripts', () {
      const admin = PgsqlAdmin();

      final dbScript = admin.buildCreateDatabase(
        const DbDatabaseSpec(name: 'genrp', owner: 'postgres'),
      );
      final tableScript = admin.buildCreateTable(
        const DbTableSpec(
          name: 'foundation_user',
          columns: <DbColumnSpec>[
            DbColumnSpec(name: 'i', type: 'bigint'),
            DbColumnSpec(name: 'n', type: 'text'),
          ],
        ),
      );

      expect(dbScript, 'CREATE DATABASE "genrp" OWNER "postgres";');
      expect(
        tableScript,
        contains('CREATE TABLE IF NOT EXISTS "foundation_user"'),
      );
      expect(tableScript, contains('"i" bigint NOT NULL'));
      expect(tableScript, contains('"n" text NOT NULL'));
    });

    test('SqliteAdmin creates virtualfun insert for create function', () {
      const admin = SqliteAdmin();

      final script = admin.buildCreateFunction(
        const DbFunctionSpec(
          name: 'edit_book',
          returns: 'json',
          body: 'select 1;',
          parameters: <DbFunctionParameterSpec>[
            DbFunctionParameterSpec(name: 'payload', type: 'text'),
          ],
          kind: DbTargetKind.business,
        ),
      );

      expect(script, contains('INSERT INTO "virtualfun"'));
      expect(script, contains("'edit_book'"));
      expect(script, contains("'business'"));
    });

    test('PgsqlClient blocks direct business-table CRUD', () {
      const client = PgsqlClient();

      expect(
        () => client.buildInsert(
          const DbCrudSpec(
            table: 'book',
            values: <String, Object?>{'i': 1, 'n': 'Book'},
            kind: DbTargetKind.business,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('SqliteClient builds soft delete for foundation rows', () {
      const client = SqliteClient();

      final sql = client.buildDelete(
        const DbCrudSpec(
          table: 'catalog_row',
          where: <String, Object?>{'catalog': 'Entity', 'i': 7},
          softDelete: true,
        ),
      );

      expect(sql, contains('UPDATE "catalog_row" SET "a" = 0'));
      expect(sql, contains('"catalog" = \'Entity\''));
      expect(sql, contains('"i" = 7'));
    });

    test('WebClient builds action request payload', () {
      const client = WebClient();

      final payload = client.buildActionRequest(
        actionId: 1001,
        data: <String, Object?>{'i': 1, 'n': 'Book'},
        username: 'demo',
        password: 'secret',
      );

      expect(payload['a'], 1001);
      expect(payload['u'], 'demo');
      expect(payload['p'], 'secret');
      expect(payload['data'], <String, Object?>{'i': 1, 'n': 'Book'});
    });

    test(
      'system entrypoint registries expose foundation and business seeds',
      () {
        expect(
          sysTableEntrypoints.map((entry) => entry.entrypoint),
          contains('app_kv'),
        );
        expect(
          sysTableEntrypoints.map((entry) => entry.entrypoint),
          contains('virtualfun'),
        );
        expect(
          sysFunctionEntrypoints.map((entry) => entry.entrypoint),
          contains('invoke_business_action'),
        );
        expect(
          sysTypeEntrypoints.map((entry) => entry.entrypoint),
          containsAll(<String>['foundation', 'business']),
        );
        expect(defaultCatalogRowSeedEntries, hasLength(1));
        expect(defaultCatalogRowSeedEntries.first.catalog, SystemDefaults.catalog);
        expect(defaultCatalogRowSeedEntries.first.payload['sid'], 1);
        expect(defaultCatalogRowSeedEntries.first.payload['fv'], 1);
        expect(defaultCatalogRowSeedEntries.first.payload['cv'], 1);
        expect(
          defaultCatalogRowSeedEntries.first.payload['ctm'],
          containsPair('entity', 'Entity'),
        );
        expect(
          defaultCatalogRowSeedEntries.first.payload['uxm'],
          containsPair('widget', 'Widget'),
        );
      },
    );
  });
}
