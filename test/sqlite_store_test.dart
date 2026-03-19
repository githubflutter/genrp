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
