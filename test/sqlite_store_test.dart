import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/db/sqlite_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'SqliteStore seeds system metadata and supports row + kv operations',
    () async {
      sqfliteFfiInit();
      final store = SqliteStore(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );

      final seededSystem = await store.getRow('System', 1);
      expect(seededSystem, isNotNull);
      expect(seededSystem!.n, 'GenRP');
      expect(seededSystem.payload['sid'], 1);
      expect(seededSystem.payload['fv'], 1);
      expect(seededSystem.payload['cv'], 1);
      expect(seededSystem.payload['ctm'], containsPair('entity', 'Entity'));
      expect(seededSystem.payload['uxm'], containsPair('widget', 'Widget'));
      expect(seededSystem.payload['m1'], isEmpty);
      expect(seededSystem.payload['m2'], isEmpty);

      final db = await store.database;
      final vfunTables = await db.query(
        'sqlite_master',
        columns: const <String>['name'],
        where: 'type = ? AND name = ?',
        whereArgs: const <Object?>['table', 'vfun'],
      );
      expect(vfunTables, hasLength(1));

      await db.insert('vfun', <String, Object?>{
        'i': 1,
        'a': 1,
        'd': 1700000000000,
        'e': 7,
        'ei': 6,
        't': 4,
        'n': 'Edit User',
        's': 'edit_user',
        'tis': '[2,3]',
        'sql1': 'select 1;',
        'sql2': '',
        'sql3': '',
      });

      final vfunRows = await db.query(
        'vfun',
        where: 'i = ?',
        whereArgs: const <Object?>[1],
      );
      expect(vfunRows, hasLength(1));
      expect(vfunRows.first['n'], 'Edit User');
      expect(vfunRows.first['tis'], '[2,3]');
      expect(vfunRows.first['sql1'], 'select 1;');

      expect(await store.nextRowId('entity'), 1);

      const row = SqliteCatalogRow(
        catalog: 'entity',
        i: 1,
        a: true,
        d: 0,
        e: 0,
        t: 10,
        n: 'User',
        s: 'app user',
        payload: <String, dynamic>{'fields': 2},
        updatedAt: 123,
      );

      await store.upsertRow(row);

      final rows = await store.listRows('entity');
      expect(rows, hasLength(1));
      expect(rows.first.catalog, 'entity');
      expect(rows.first.i, 1);
      expect(rows.first.payload['fields'], 2);
      expect(await store.nextRowId('entity'), 2);

      final loaded = await store.getRow('entity', 1);
      expect(loaded, isNotNull);
      expect(loaded!.n, 'User');
      expect(loaded.s, 'app user');

      await store.putJsonValue('aibook.spec.cache', <String, dynamic>{
        'bodyId': 1,
        'title': 'Editor',
      });
      final cached = await store.getJsonValue('aibook.spec.cache');
      expect(cached, isA<Map<String, dynamic>>());
      expect((cached as Map<String, dynamic>)['bodyId'], 1);

      await store.deleteRow('entity', 1);
      expect(await store.getRow('entity', 1), isNull);

      await store.close();
    },
  );
}
