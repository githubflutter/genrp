import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genrp/core/base/bootstrap.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteCatalogRow {
  final String catalog;
  final int i;
  final bool a;
  final int d;
  final int e;
  final int t;
  final String n;
  final String s;
  final Map<String, dynamic> payload;
  final int updatedAt;

  const SqliteCatalogRow({
    required this.catalog,
    required this.i,
    required this.a,
    required this.d,
    required this.e,
    required this.t,
    required this.n,
    required this.s,
    this.payload = const <String, dynamic>{},
    required this.updatedAt,
  });

  factory SqliteCatalogRow.fromMap(Map<String, Object?> map) {
    final payloadRaw = map['payload'];
    return SqliteCatalogRow(
      catalog: map['catalog']?.toString() ?? '',
      i: (map['i'] as num?)?.toInt() ?? 0,
      a: ((map['a'] as num?)?.toInt() ?? 0) != 0,
      d: (map['d'] as num?)?.toInt() ?? 0,
      e: (map['e'] as num?)?.toInt() ?? 0,
      t: (map['t'] as num?)?.toInt() ?? 0,
      n: map['n']?.toString() ?? '',
      s: map['s']?.toString() ?? '',
      payload: payloadRaw is String && payloadRaw.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(payloadRaw) as Map)
          : const <String, dynamic>{},
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'catalog': catalog,
      'i': i,
      'a': a ? 1 : 0,
      'd': d,
      'e': e,
      't': t,
      'n': n,
      's': s,
      'payload': jsonEncode(payload),
      'updated_at': updatedAt,
    };
  }

  SqliteCatalogRow copyWith({
    String? catalog,
    int? i,
    bool? a,
    int? d,
    int? e,
    int? t,
    String? n,
    String? s,
    Map<String, dynamic>? payload,
    int? updatedAt,
  }) {
    return SqliteCatalogRow(
      catalog: catalog ?? this.catalog,
      i: i ?? this.i,
      a: a ?? this.a,
      d: d ?? this.d,
      e: e ?? this.e,
      t: t ?? this.t,
      n: n ?? this.n,
      s: s ?? this.s,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SqliteStore {
  SqliteStore({sqflite.DatabaseFactory? databaseFactory, String? databasePath})
    : _databaseFactoryOverride = databaseFactory,
      _databasePathOverride = databasePath;

  static final SqliteStore instance = SqliteStore();
  static const String defaultDatabaseName = 'genrp.sqlite.db';

  final sqflite.DatabaseFactory? _databaseFactoryOverride;
  final String? _databasePathOverride;

  sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    final existing = _database;
    if (existing != null) return existing;
    final opened = await _open();
    _database = opened;
    return opened;
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null) {
      await db.close();
    }
  }

  Future<List<SqliteCatalogRow>> listRows(String catalog) async {
    final db = await database;
    final rows = await db.query(
      'catalog_row',
      where: 'catalog = ?',
      whereArgs: <Object?>[catalog],
      orderBy: 'n ASC, i ASC',
    );
    return rows
        .map((row) => SqliteCatalogRow.fromMap(Map<String, Object?>.from(row)))
        .toList(growable: false);
  }

  Future<SqliteCatalogRow?> getRow(String catalog, int id) async {
    final db = await database;
    final rows = await db.query(
      'catalog_row',
      where: 'catalog = ? AND i = ?',
      whereArgs: <Object?>[catalog, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SqliteCatalogRow.fromMap(Map<String, Object?>.from(rows.first));
  }

  Future<int> nextRowId(String catalog) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(MAX(i), 0) AS max_i FROM catalog_row WHERE catalog = ?',
      <Object?>[catalog],
    );
    if (rows.isEmpty) return 1;
    final maxId = (rows.first['max_i'] as num?)?.toInt() ?? 0;
    return maxId + 1;
  }

  Future<void> upsertRow(SqliteCatalogRow row) async {
    final db = await database;
    final updatedRow = row.copyWith(
      updatedAt: row.updatedAt == 0
          ? DateTime.now().millisecondsSinceEpoch
          : row.updatedAt,
    );
    await db.insert(
      'catalog_row',
      updatedRow.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRow(String catalog, int id) async {
    final db = await database;
    await db.delete(
      'catalog_row',
      where: 'catalog = ? AND i = ?',
      whereArgs: <Object?>[catalog, id],
    );
  }

  Future<void> putJsonValue(String key, Object? value) async {
    final db = await database;
    await db.insert('app_kv', <String, Object?>{
      'k': key,
      'v': jsonEncode(value),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  Future<Object?> getJsonValue(String key) async {
    final db = await database;
    final rows = await db.query(
      'app_kv',
      columns: const <String>['v'],
      where: 'k = ?',
      whereArgs: <Object?>[key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['v'];
    if (raw is! String || raw.isEmpty) return null;
    return jsonDecode(raw);
  }

  Future<sqflite.Database> _open() async {
    final factory = _databaseFactoryOverride ?? _resolveDatabaseFactory();
    final path = _databasePathOverride ?? await _resolveDatabasePath();
    return factory.openDatabase(
      path,
      options: sqflite.OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE app_kv (
              k TEXT PRIMARY KEY,
              v TEXT NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE catalog_row (
              catalog TEXT NOT NULL,
              i INTEGER NOT NULL,
              a INTEGER NOT NULL DEFAULT 1,
              d INTEGER NOT NULL DEFAULT 0,
              e INTEGER NOT NULL DEFAULT 0,
              t INTEGER NOT NULL DEFAULT 0,
              n TEXT NOT NULL DEFAULT '',
              s TEXT NOT NULL DEFAULT '',
              payload TEXT NOT NULL DEFAULT '{}',
              updated_at INTEGER NOT NULL,
              PRIMARY KEY (catalog, i)
            )
          ''');
          await db.execute(
            'CREATE INDEX idx_catalog_row_catalog_name ON catalog_row (catalog, n, i)',
          );
          await db.execute('''
            CREATE TABLE vfun (
              i INTEGER NOT NULL PRIMARY KEY,
              a INTEGER NOT NULL DEFAULT 1,
              d INTEGER NOT NULL DEFAULT 0,
              e INTEGER NOT NULL DEFAULT 0,
              ei INTEGER NOT NULL DEFAULT 0,
              t INTEGER NOT NULL DEFAULT 0,
              n TEXT NOT NULL DEFAULT '',
              s TEXT NOT NULL DEFAULT '',
              tis TEXT NOT NULL DEFAULT '[0]',
              sql1 TEXT NOT NULL DEFAULT '',
              sql2 TEXT NOT NULL DEFAULT '',
              sql3 TEXT NOT NULL DEFAULT ''
            )
          ''');
          await db.execute('CREATE INDEX idx_vfun_name ON vfun (n, i)');
          await _seedFoundationData(db);
        },
      ),
    );
  }

  Future<void> _seedFoundationData(sqflite.Database db) async {
    final seededAt = DateTime.now().millisecondsSinceEpoch;

    for (final seed in defaultAppKvSeedEntries) {
      await db.insert('app_kv', <String, Object?>{
        'k': seed.key,
        'v': jsonEncode(seed.value),
        'updated_at': seed.updatedAt == 0 ? seededAt : seed.updatedAt,
      }, conflictAlgorithm: sqflite.ConflictAlgorithm.ignore);
    }

    for (final seed in defaultCatalogRowSeedEntries) {
      await db.insert('catalog_row', <String, Object?>{
        'catalog': seed.catalog,
        'i': seed.i,
        'a': seed.a ? 1 : 0,
        'd': seed.d,
        'e': seed.e,
        't': seed.t,
        'n': seed.n,
        's': seed.s,
        'payload': jsonEncode(seed.payload),
        'updated_at': seed.updatedAt == 0 ? seededAt : seed.updatedAt,
      }, conflictAlgorithm: sqflite.ConflictAlgorithm.ignore);
    }
  }

  sqflite.DatabaseFactory _resolveDatabaseFactory() {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite support is not configured for Flutter Web.',
      );
    }
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      return databaseFactoryFfi;
    }
    return sqflite.databaseFactory;
  }

  Future<String> _resolveDatabasePath() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite support is not configured for Flutter Web.',
      );
    }
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return p.join(directory.path, defaultDatabaseName);
  }
}
