import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aistudio/aistudio.dart';
import 'package:genrp/core/db/sqlite_store.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class _FakeDatabase implements sqflite.Database {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSqliteStore extends SqliteStore {
  final Map<String, SqliteCatalogRow> _rows = <String, SqliteCatalogRow>{};

  String _key(String catalog, int id) => '$catalog::$id';

  @override
  Future<sqflite.Database> get database async => _FakeDatabase();

  @override
  Future<void> close() async {}

  @override
  Future<void> deleteRow(String catalog, int id) async {
    _rows.remove(_key(catalog, id));
  }

  @override
  Future<SqliteCatalogRow?> getRow(String catalog, int id) async {
    return _rows[_key(catalog, id)];
  }

  @override
  Future<int> nextRowId(String catalog) async {
    var maxId = 0;
    for (final row in _rows.values) {
      if (row.catalog == catalog && row.i > maxId) {
        maxId = row.i;
      }
    }
    return maxId + 1;
  }

  @override
  Future<List<SqliteCatalogRow>> listRows(String catalog) async {
    final rows = _rows.values
        .where((row) => row.catalog == catalog)
        .toList(growable: false);
    rows.sort((left, right) {
      final byName = left.n.compareTo(right.n);
      return byName != 0 ? byName : left.i.compareTo(right.i);
    });
    return rows;
  }

  @override
  Future<void> upsertRow(SqliteCatalogRow row) async {
    _rows[_key(row.catalog, row.i)] = row.copyWith(
      updatedAt: row.updatedAt == 0
          ? DateTime.now().millisecondsSinceEpoch
          : row.updatedAt,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUi(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('AIStudio loads rows, filters by search, and selects a row', (
    tester,
  ) async {
    final store = _FakeSqliteStore();
    await store.upsertRow(
      const SqliteCatalogRow(
        catalog: 'Host',
        i: 1,
        a: true,
        d: 10,
        e: 2,
        t: 0,
        n: 'Main Host',
        s: 'main_host',
        updatedAt: 0,
      ),
    );
    await store.upsertRow(
      const SqliteCatalogRow(
        catalog: 'Host',
        i: 2,
        a: true,
        d: 10,
        e: 2,
        t: 0,
        n: 'Secondary Host',
        s: 'secondary_host',
        updatedAt: 0,
      ),
    );

    await tester.pumpWidget(AIStudioApp(store: store));
    await pumpUi(tester);

    await tester.tap(find.text('Host'));
    await pumpUi(tester);

    expect(
      find.byKey(const ValueKey<String>('aistudio_row_Host_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('aistudio_row_Host_2')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('aistudio_search_field')),
      'Main',
    );
    await pumpUi(tester);

    expect(
      find.byKey(const ValueKey<String>('aistudio_row_Host_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('aistudio_row_Host_2')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('aistudio_search_field')),
      '',
    );
    await pumpUi(tester);

    await tester.tap(find.byKey(const ValueKey<String>('aistudio_row_Host_1')));
    await pumpUi(tester);

    expect(
      find.byKey(const ValueKey<String>('aistudio_detail_name_field')),
      findsOneWidget,
    );

    await store.close();
  });

  testWidgets('AIStudio creates a draft row without inserting it', (
    tester,
  ) async {
    final store = _FakeSqliteStore();

    await tester.pumpWidget(AIStudioApp(store: store));
    await pumpUi(tester);

    await tester.tap(find.text('Host'));
    await pumpUi(tester);

    await tester.tap(find.byKey(const ValueKey<String>('aistudio_add_button')));
    await pumpUi(tester);

    expect(await store.listRows('Host'), isEmpty);
    expect(
      find.byKey(const ValueKey<String>('aistudio_row_Host_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('aistudio_detail_name_field')),
      findsOneWidget,
    );
    expect(find.text('0 (draft)'), findsOneWidget);

    await store.close();
  });

  testWidgets('AIStudio edits and saves a selected UX catalog row', (tester) async {
    final store = _FakeSqliteStore();

    await store.upsertRow(
      const SqliteCatalogRow(
        catalog: 'Host',
        i: 1,
        a: true,
        d: 10,
        e: 2,
        t: 0,
        n: 'Main Host',
        s: 'main_host',
        updatedAt: 0,
      ),
    );

    await tester.pumpWidget(AIStudioApp(store: store));
    await pumpUi(tester);

    await tester.tap(find.text('Host'));
    await pumpUi(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('aistudio_row_Host_1')),
    );
    await pumpUi(tester);

    expect(
      find.byKey(const ValueKey<String>('aistudio_detail_name_field')),
      findsOneWidget,
    );
    expect(find.text('Main Host'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey<String>('aistudio_detail_name_field')),
      'Updated Host',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('aistudio_detail_system_field')),
      'updated_host',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    final detailScrollable = find.descendant(
      of: find.byKey(const ValueKey<String>('aistudio_detail_scroll')),
      matching: find.byType(Scrollable),
    ).first;

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('aistudio_detail_save_button')),
      200,
      scrollable: detailScrollable,
    );
    await tester.ensureVisible(find.byKey(const ValueKey<String>('aistudio_detail_save_button')));

    await tester.tap(find.byKey(const ValueKey<String>('aistudio_detail_save_button')));
    await pumpUi(tester);

    final saved = await store.getRow('Host', 1);
    expect(saved, isNotNull);
    expect(saved!.n, 'Updated Host');
    expect(saved.s, 'updated_host');
    expect(saved.d, greaterThan(10));

    await store.close();
  });

  testWidgets('AIStudio deletes a selected UX catalog row', (tester) async {
    final store = _FakeSqliteStore();

    await store.upsertRow(
      const SqliteCatalogRow(
        catalog: 'Host',
        i: 3,
        a: true,
        d: 10,
        e: 2,
        t: 0,
        n: 'Delete Me',
        s: 'delete_me',
        updatedAt: 0,
      ),
    );

    await tester.pumpWidget(AIStudioApp(store: store));
    await pumpUi(tester);

    await tester.tap(find.text('Host'));
    await pumpUi(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('aistudio_row_Host_3')),
    );
    await pumpUi(tester);

    final detailScrollable = find.descendant(
      of: find.byKey(const ValueKey<String>('aistudio_detail_scroll')),
      matching: find.byType(Scrollable),
    ).first;

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('aistudio_detail_delete_button')),
      200,
      scrollable: detailScrollable,
    );
    await tester.ensureVisible(find.byKey(const ValueKey<String>('aistudio_detail_delete_button')));
    await tester.drag(detailScrollable, const Offset(0, -80));
    await pumpUi(tester);

    await tester.tap(find.byKey(const ValueKey<String>('aistudio_detail_delete_button')));
    await pumpUi(tester);

    expect(await store.getRow('Host', 3), isNull);
    expect(
      find.byKey(const ValueKey<String>('aistudio_right_empty')),
      findsOneWidget,
    );

    await store.close();
  });
}
