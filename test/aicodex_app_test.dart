import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aicodex/aicodex.dart';
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

  Finder detailScrollable() => find
      .descendant(
        of: find.byKey(const ValueKey<String>('aicodex_detail_scroll')),
        matching: find.byType(Scrollable),
      )
      .first;

  Finder detailByKey(String key) =>
      find.byKey(ValueKey<String>(key), skipOffstage: false);

  testWidgets('AICodex edits and saves a selected catalog row', (tester) async {
    final store = _FakeSqliteStore();

    await store.upsertRow(
      const SqliteCatalogRow(
        catalog: 'Entity',
        i: 1,
        a: true,
        d: 10,
        e: 2,
        t: 3,
        n: 'Book',
        s: 'book',
        payload: <String, dynamic>{'kind': 'root'},
        updatedAt: 0,
      ),
    );

    await tester.pumpWidget(AICodexApp(store: store));
    await pumpUi(tester);

    await tester.tap(find.text('Entity'));
    await pumpUi(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('aicodex_row_Entity_1')),
    );
    await pumpUi(tester);

    expect(
      find.byKey(const ValueKey<String>('aicodex_detail_name_field')),
      findsOneWidget,
    );
    expect(find.text('Book'), findsWidgets);

    await tester.enterText(
      detailByKey('aicodex_detail_name_field'),
      'Book Revised',
    );
    await tester.enterText(
      detailByKey('aicodex_detail_system_field'),
      'Book Revised',
    );
    await tester.scrollUntilVisible(
      detailByKey('aicodex_detail_active_switch'),
      200,
      scrollable: detailScrollable(),
    );
    final activeSwitch = tester.widget<SwitchListTile>(
      detailByKey('aicodex_detail_active_switch'),
    );
    activeSwitch.onChanged?.call(false);
    await tester.pump();
    await tester.scrollUntilVisible(
      detailByKey('aicodex_detail_payload_field'),
      200,
      scrollable: detailScrollable(),
    );
    await tester.enterText(
      detailByKey('aicodex_detail_payload_field'),
      '{"kind":"root","slot":1}',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.scrollUntilVisible(
      detailByKey('aicodex_detail_save_button'),
      200,
      scrollable: detailScrollable(),
    );
    await tester.ensureVisible(
      detailByKey('aicodex_detail_save_button'),
    );

    await tester.tap(detailByKey('aicodex_detail_save_button'));
    await pumpUi(tester);

    final saved = await store.getRow('Entity', 1);
    expect(saved, isNotNull);
    expect(saved!.n, 'Book Revised');
    expect(saved.s, 'book_revised');
    expect(saved.a, isFalse);
    expect(saved.payload['slot'], 1);
    expect(saved.d, greaterThan(10));

    await store.close();
  });

  testWidgets('AICodex deletes a selected catalog row', (tester) async {
    final store = _FakeSqliteStore();

    await store.upsertRow(
      const SqliteCatalogRow(
        catalog: 'Entity',
        i: 3,
        a: true,
        d: 10,
        e: 2,
        t: 0,
        n: 'Delete Me',
        s: 'delete_me',
        payload: <String, dynamic>{},
        updatedAt: 0,
      ),
    );

    await tester.pumpWidget(AICodexApp(store: store));
    await pumpUi(tester);

    await tester.tap(find.text('Entity'));
    await pumpUi(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('aicodex_row_Entity_3')),
    );
    await pumpUi(tester);
    await tester.scrollUntilVisible(
      detailByKey('aicodex_detail_delete_button'),
      200,
      scrollable: detailScrollable(),
    );
    await tester.ensureVisible(
      detailByKey('aicodex_detail_delete_button'),
    );
    await tester.drag(detailScrollable(), const Offset(0, -80));
    await pumpUi(tester);

    await tester.tap(detailByKey('aicodex_detail_delete_button'));
    await pumpUi(tester);

    expect(await store.getRow('Entity', 3), isNull);
    expect(
      find.byKey(const ValueKey<String>('aicodex_detail_empty')),
      findsOneWidget,
    );

    await store.close();
  });
}
