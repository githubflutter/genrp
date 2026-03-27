import 'package:genrp/core/model/bschema/column_model.dart' as bschema;
import 'package:genrp/core/model/bschema/entity_model.dart' as bschema;
import 'package:genrp/core/model/bschema/field_model.dart' as bschema;
import 'package:genrp/core/model/bschema/function_model.dart' as bschema;
import 'package:genrp/core/model/bschema/parameter_model.dart' as bschema;
import 'package:genrp/core/model/bschema/table_model.dart' as bschema;

enum AICodexFieldKind { boolean, integer, integerList, text, functionType }

class AICodexFieldSpec {
  const AICodexFieldSpec({
    required this.key,
    required this.label,
    required this.kind,
    this.hint = '',
    this.defaultValue,
  });

  final String key;
  final String label;
  final AICodexFieldKind kind;
  final String hint;
  final Object? defaultValue;
}

class AICodexCatalogSpec {
  const AICodexCatalogSpec({
    required this.label,
    required this.columns,
    required this.formFields,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final String label;
  final List<String> columns;
  final List<AICodexFieldSpec> formFields;
  final String emptyTitle;
  final String emptyMessage;
}

class AICodexMockBackend {
  AICodexMockBackend();

  static const List<String> orderedCatalogLabels = <String>[
    'Entity',
    'Field',
    'Table',
    'Column',
    'Function',
    'Parameter',
  ];

  static const Map<String, AICodexCatalogSpec>
  catalogSpecs = <String, AICodexCatalogSpec>{
    'Entity': AICodexCatalogSpec(
      label: 'Entity',
      columns: <String>['i', 'a', 'd', 'e', 't', 'tis', 'n', 's'],
      formFields: <AICodexFieldSpec>[
        AICodexFieldSpec(
          key: 'a',
          label: 'Active',
          kind: AICodexFieldKind.boolean,
          defaultValue: true,
        ),
        AICodexFieldSpec(
          key: 'e',
          label: 'Editor ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 1,
        ),
        AICodexFieldSpec(
          key: 't',
          label: 'Type ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 0,
        ),
        AICodexFieldSpec(
          key: 'tis',
          label: 'Type IDs',
          kind: AICodexFieldKind.integerList,
          hint: 'Comma-separated integers',
          defaultValue: <int>[0],
        ),
        AICodexFieldSpec(key: 'n', label: 'Name', kind: AICodexFieldKind.text),
        AICodexFieldSpec(
          key: 's',
          label: 'Slug',
          kind: AICodexFieldKind.text,
          hint: 'Leave blank to derive from the name',
        ),
      ],
      emptyTitle: 'No entities yet',
      emptyMessage: 'Create an entity to seed the in-memory business schema.',
    ),
    'Field': AICodexCatalogSpec(
      label: 'Field',
      columns: <String>['i', 'a', 'd', 'e', 'ci', 't', 'n', 's'],
      formFields: <AICodexFieldSpec>[
        AICodexFieldSpec(
          key: 'a',
          label: 'Active',
          kind: AICodexFieldKind.boolean,
          defaultValue: true,
        ),
        AICodexFieldSpec(
          key: 'e',
          label: 'Editor ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 1,
        ),
        AICodexFieldSpec(
          key: 'ci',
          label: 'Column ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 0,
        ),
        AICodexFieldSpec(
          key: 't',
          label: 'Type ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 0,
        ),
        AICodexFieldSpec(key: 'n', label: 'Name', kind: AICodexFieldKind.text),
        AICodexFieldSpec(
          key: 's',
          label: 'Slug',
          kind: AICodexFieldKind.text,
          hint: 'Leave blank to derive from the name',
        ),
      ],
      emptyTitle: 'No fields yet',
      emptyMessage: 'Create a field to describe a property in the mock schema.',
    ),
    'Table': AICodexCatalogSpec(
      label: 'Table',
      columns: <String>['i', 'a', 'd', 'e', 't', 'n', 's'],
      formFields: <AICodexFieldSpec>[
        AICodexFieldSpec(
          key: 'a',
          label: 'Active',
          kind: AICodexFieldKind.boolean,
          defaultValue: true,
        ),
        AICodexFieldSpec(
          key: 'e',
          label: 'Editor ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 1,
        ),
        AICodexFieldSpec(
          key: 't',
          label: 'Type ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 0,
        ),
        AICodexFieldSpec(key: 'n', label: 'Name', kind: AICodexFieldKind.text),
        AICodexFieldSpec(
          key: 's',
          label: 'Slug',
          kind: AICodexFieldKind.text,
          hint: 'Leave blank to derive from the name',
        ),
      ],
      emptyTitle: 'No tables yet',
      emptyMessage:
          'Create a table to represent a persisted structure in memory.',
    ),
    'Column': AICodexCatalogSpec(
      label: 'Column',
      columns: <String>['i', 'a', 'd', 'e', 't', 'n', 's'],
      formFields: <AICodexFieldSpec>[
        AICodexFieldSpec(
          key: 'a',
          label: 'Active',
          kind: AICodexFieldKind.boolean,
          defaultValue: true,
        ),
        AICodexFieldSpec(
          key: 'e',
          label: 'Editor ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 1,
        ),
        AICodexFieldSpec(
          key: 't',
          label: 'Type ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 0,
        ),
        AICodexFieldSpec(key: 'n', label: 'Name', kind: AICodexFieldKind.text),
        AICodexFieldSpec(
          key: 's',
          label: 'Slug',
          kind: AICodexFieldKind.text,
          hint: 'Leave blank to derive from the name',
        ),
      ],
      emptyTitle: 'No columns yet',
      emptyMessage:
          'Create a column to connect the database shape to the mock schema.',
    ),
    'Function': AICodexCatalogSpec(
      label: 'Function',
      columns: <String>['i', 'a', 'd', 'e', 'ei', 't', 'tis', 'n', 's'],
      formFields: <AICodexFieldSpec>[
        AICodexFieldSpec(
          key: 'a',
          label: 'Active',
          kind: AICodexFieldKind.boolean,
          defaultValue: true,
        ),
        AICodexFieldSpec(
          key: 'e',
          label: 'Editor ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 1,
        ),
        AICodexFieldSpec(
          key: 'ei',
          label: 'Entity ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 0,
        ),
        AICodexFieldSpec(
          key: 't',
          label: 'Function Type',
          kind: AICodexFieldKind.functionType,
          defaultValue: bschema.FunctionType.bizGet,
        ),
        AICodexFieldSpec(
          key: 'tis',
          label: 'Type IDs',
          kind: AICodexFieldKind.integerList,
          hint: 'Comma-separated integers',
          defaultValue: <int>[0],
        ),
        AICodexFieldSpec(key: 'n', label: 'Name', kind: AICodexFieldKind.text),
        AICodexFieldSpec(
          key: 's',
          label: 'Slug',
          kind: AICodexFieldKind.text,
          hint: 'Leave blank to derive from the name',
        ),
      ],
      emptyTitle: 'No functions yet',
      emptyMessage:
          'Create a function to model the mock action layer for bschema.',
    ),
    'Parameter': AICodexCatalogSpec(
      label: 'Parameter',
      columns: <String>['i', 'a', 'd', 'e', 'fi', 'n', 's'],
      formFields: <AICodexFieldSpec>[
        AICodexFieldSpec(
          key: 'a',
          label: 'Active',
          kind: AICodexFieldKind.boolean,
          defaultValue: true,
        ),
        AICodexFieldSpec(
          key: 'e',
          label: 'Editor ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 1,
        ),
        AICodexFieldSpec(
          key: 'fi',
          label: 'Function ID',
          kind: AICodexFieldKind.integer,
          defaultValue: 0,
        ),
        AICodexFieldSpec(key: 'n', label: 'Name', kind: AICodexFieldKind.text),
        AICodexFieldSpec(
          key: 's',
          label: 'Slug',
          kind: AICodexFieldKind.text,
          hint: 'Leave blank to derive from the name',
        ),
      ],
      emptyTitle: 'No parameters yet',
      emptyMessage:
          'Create a parameter to finish the function contract in memory.',
    ),
  };

  final List<bschema.EntityModel> _entities = <bschema.EntityModel>[
    const bschema.EntityModel(
      i: 1,
      a: true,
      d: 1742550000000,
      e: 1,
      t: 10,
      tis: <int>[1, 2],
      n: 'Customer',
      s: 'customer',
    ),
    const bschema.EntityModel(
      i: 2,
      a: true,
      d: 1742550001000,
      e: 1,
      t: 11,
      tis: <int>[3],
      n: 'Order',
      s: 'order',
    ),
  ];

  final List<bschema.FieldModel> _fields = <bschema.FieldModel>[
    const bschema.FieldModel(
      i: 1,
      a: true,
      d: 1742550000000,
      e: 1,
      ci: 1,
      t: 2,
      n: 'Name',
      s: 'name',
    ),
    const bschema.FieldModel(
      i: 2,
      a: true,
      d: 1742550001000,
      e: 1,
      ci: 2,
      t: 3,
      n: 'Active',
      s: 'active',
    ),
  ];

  final List<bschema.TableModel> _tables = <bschema.TableModel>[
    const bschema.TableModel(
      i: 1,
      a: true,
      d: 1742550000000,
      e: 1,
      t: 1,
      n: 't1',
      s: 't1',
    ),
    const bschema.TableModel(
      i: 2,
      a: true,
      d: 1742550001000,
      e: 1,
      t: 1,
      n: 't2',
      s: 't2',
    ),
  ];

  final List<bschema.ColumnModel> _columns = <bschema.ColumnModel>[
    const bschema.ColumnModel(
      i: 1,
      a: true,
      d: 1742550000000,
      e: 1,
      t: 1,
      n: 'c1',
      s: 'c1',
    ),
    const bschema.ColumnModel(
      i: 2,
      a: true,
      d: 1742550001000,
      e: 1,
      t: 2,
      n: 'c2',
      s: 'c2',
    ),
  ];

  final List<bschema.FunctionModel> _functions = <bschema.FunctionModel>[
    const bschema.FunctionModel(
      i: 1,
      a: true,
      d: 1742550000000,
      e: 1,
      ei: 1,
      t: bschema.FunctionType.bizGet,
      tis: <int>[1],
      n: 'get_customer',
      s: 'get_customer',
    ),
    const bschema.FunctionModel(
      i: 2,
      a: true,
      d: 1742550001000,
      e: 1,
      ei: 2,
      t: bschema.FunctionType.bizSet,
      tis: <int>[2],
      n: 'set_customer',
      s: 'set_customer',
    ),
  ];

  final List<bschema.ParameterModel> _parameters = <bschema.ParameterModel>[
    const bschema.ParameterModel(
      i: 1,
      a: true,
      d: 1742550000000,
      e: 1,
      fi: 1,
      n: 'customer_id',
      s: 'customer_id',
    ),
    const bschema.ParameterModel(
      i: 2,
      a: true,
      d: 1742550001000,
      e: 1,
      fi: 2,
      n: 'payload',
      s: 'payload',
    ),
  ];

  Iterable<String> get catalogLabels => orderedCatalogLabels;

  AICodexCatalogSpec specFor(String label) {
    final spec = catalogSpecs[label];
    if (spec == null) {
      throw ArgumentError.value(label, 'label', 'Unknown catalog');
    }
    return spec;
  }

  int countFor(String label) => rowsFor(label).length;

  List<Map<String, Object?>> rowsFor(String label) {
    switch (label) {
      case 'Entity':
        return _entities
            .map((record) => Map<String, Object?>.from(record.toJson()))
            .toList(growable: false);
      case 'Field':
        return _fields
            .map((record) => Map<String, Object?>.from(record.toJson()))
            .toList(growable: false);
      case 'Table':
        return _tables
            .map((record) => Map<String, Object?>.from(record.toJson()))
            .toList(growable: false);
      case 'Column':
        return _columns
            .map((record) => Map<String, Object?>.from(record.toJson()))
            .toList(growable: false);
      case 'Function':
        return _functions
            .map((record) => Map<String, Object?>.from(record.toJson()))
            .toList(growable: false);
      case 'Parameter':
        return _parameters
            .map((record) => Map<String, Object?>.from(record.toJson()))
            .toList(growable: false);
      default:
        throw ArgumentError.value(label, 'label', 'Unknown catalog');
    }
  }

  Map<String, Object?>? recordFor(String label, int id) {
    for (final record in rowsFor(label)) {
      if (_asInt(record['i'], fallback: 0) == id) {
        return record;
      }
    }
    return null;
  }

  int createRecord(String label, Map<String, Object?> draft) {
    switch (label) {
      case 'Entity':
        final id = _nextId(_entities.map((record) => record.i));
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: 'Entity $id',
          fallbackSlug: 'entity-$id',
        );
        values['t'] = _asInt(draft['t'], fallback: 0);
        values['tis'] = _normalizeIntList(
          draft['tis'],
          fallback: const <int>[0],
        );
        _entities.add(bschema.EntityModel.fromJson(values));
        return id;
      case 'Field':
        final id = _nextId(_fields.map((record) => record.i));
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: 'Field $id',
          fallbackSlug: 'field-$id',
        );
        values['ci'] = _asInt(draft['ci'], fallback: 0);
        values['t'] = _asInt(draft['t'], fallback: 0);
        _fields.add(bschema.FieldModel.fromJson(values));
        return id;
      case 'Table':
        final id = _nextId(_tables.map((record) => record.i));
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: 'Table $id',
          fallbackSlug: 'table-$id',
        );
        values['t'] = _asInt(draft['t'], fallback: 0);
        _tables.add(bschema.TableModel.fromJson(values));
        return id;
      case 'Column':
        final id = _nextId(_columns.map((record) => record.i));
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: 'Column $id',
          fallbackSlug: 'column-$id',
        );
        values['t'] = _asInt(draft['t'], fallback: 0);
        _columns.add(bschema.ColumnModel.fromJson(values));
        return id;
      case 'Function':
        final id = _nextId(_functions.map((record) => record.i));
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: 'Function $id',
          fallbackSlug: 'function-$id',
        );
        values['ei'] = _asInt(draft['ei'], fallback: 0);
        values['t'] = _asInt(draft['t'], fallback: bschema.FunctionType.bizGet);
        values['tis'] = _normalizeIntList(
          draft['tis'],
          fallback: const <int>[0],
        );
        _functions.add(bschema.FunctionModel.fromJson(values));
        return id;
      case 'Parameter':
        final id = _nextId(_parameters.map((record) => record.i));
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: 'Parameter $id',
          fallbackSlug: 'parameter-$id',
        );
        values['fi'] = _asInt(draft['fi'], fallback: 0);
        _parameters.add(bschema.ParameterModel.fromJson(values));
        return id;
      default:
        throw ArgumentError.value(label, 'label', 'Unknown catalog');
    }
  }

  void updateRecord(String label, int id, Map<String, Object?> draft) {
    switch (label) {
      case 'Entity':
        final index = _findIndexById(_entities, id, (record) => record.i);
        final current = _entities[index];
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: current.n,
          fallbackSlug: current.s,
          initial: current.toJson(),
        );
        values['t'] = _asInt(draft['t'] ?? current.t, fallback: current.t);
        values['tis'] = _normalizeIntList(
          draft['tis'] ?? current.tis,
          fallback: current.tis,
        );
        _entities[index] = bschema.EntityModel.fromJson(values);
        return;
      case 'Field':
        final index = _findIndexById(_fields, id, (record) => record.i);
        final current = _fields[index];
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: current.n,
          fallbackSlug: current.s,
          initial: current.toJson(),
        );
        values['ci'] = _asInt(draft['ci'] ?? current.ci, fallback: current.ci);
        values['t'] = _asInt(draft['t'] ?? current.t, fallback: current.t);
        _fields[index] = bschema.FieldModel.fromJson(values);
        return;
      case 'Table':
        final index = _findIndexById(_tables, id, (record) => record.i);
        final current = _tables[index];
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: current.n,
          fallbackSlug: current.s,
          initial: current.toJson(),
        );
        values['t'] = _asInt(draft['t'] ?? current.t, fallback: current.t);
        _tables[index] = bschema.TableModel.fromJson(values);
        return;
      case 'Column':
        final index = _findIndexById(_columns, id, (record) => record.i);
        final current = _columns[index];
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: current.n,
          fallbackSlug: current.s,
          initial: current.toJson(),
        );
        values['t'] = _asInt(draft['t'] ?? current.t, fallback: current.t);
        _columns[index] = bschema.ColumnModel.fromJson(values);
        return;
      case 'Function':
        final index = _findIndexById(_functions, id, (record) => record.i);
        final current = _functions[index];
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: current.n,
          fallbackSlug: current.s,
          initial: current.toJson(),
        );
        values['ei'] = _asInt(draft['ei'] ?? current.ei, fallback: current.ei);
        values['t'] = _asInt(draft['t'] ?? current.t, fallback: current.t);
        values['tis'] = _normalizeIntList(
          draft['tis'] ?? current.tis,
          fallback: current.tis,
        );
        _functions[index] = bschema.FunctionModel.fromJson(values);
        return;
      case 'Parameter':
        final index = _findIndexById(_parameters, id, (record) => record.i);
        final current = _parameters[index];
        final values = _commonRecordValues(
          draft,
          id: id,
          fallbackName: current.n,
          fallbackSlug: current.s,
          initial: current.toJson(),
        );
        values['fi'] = _asInt(draft['fi'] ?? current.fi, fallback: current.fi);
        _parameters[index] = bschema.ParameterModel.fromJson(values);
        return;
      default:
        throw ArgumentError.value(label, 'label', 'Unknown catalog');
    }
  }

  void deleteRecord(String label, int id) {
    switch (label) {
      case 'Entity':
        _entities.removeAt(_findIndexById(_entities, id, (record) => record.i));
        return;
      case 'Field':
        _fields.removeAt(_findIndexById(_fields, id, (record) => record.i));
        return;
      case 'Table':
        _tables.removeAt(_findIndexById(_tables, id, (record) => record.i));
        return;
      case 'Column':
        _columns.removeAt(_findIndexById(_columns, id, (record) => record.i));
        return;
      case 'Function':
        _functions.removeAt(
          _findIndexById(_functions, id, (record) => record.i),
        );
        return;
      case 'Parameter':
        _parameters.removeAt(
          _findIndexById(_parameters, id, (record) => record.i),
        );
        return;
      default:
        throw ArgumentError.value(label, 'label', 'Unknown catalog');
    }
  }

  Map<String, Object?> _commonRecordValues(
    Map<String, Object?> draft, {
    required int id,
    required String fallbackName,
    required String fallbackSlug,
    Map<String, dynamic> initial = const <String, dynamic>{},
  }) {
    final name = _asString(draft['n'] ?? initial['n'], fallback: fallbackName);
    final slug = _normalizeSlug(
      draft['s'],
      name: name,
      fallback: _asString(initial['s'], fallback: fallbackSlug),
    );
    return <String, Object?>{
      ...initial,
      'i': id,
      'a': _asBool(draft['a'] ?? initial['a'], fallback: true),
      'd': _now(),
      'e': _asInt(draft['e'] ?? initial['e'], fallback: 1),
      'n': name,
      's': slug,
    };
  }

  int _findIndexById<T>(
    List<T> records,
    int id,
    int Function(T record) idSelector,
  ) {
    final index = records.indexWhere((record) => idSelector(record) == id);
    if (index < 0) {
      throw ArgumentError.value(id, 'id', 'Unknown record id');
    }
    return index;
  }

  int _nextId(Iterable<int> ids) {
    var maxId = 0;
    for (final id in ids) {
      if (id > maxId) {
        maxId = id;
      }
    }
    return maxId + 1;
  }

  int _now() => DateTime.now().millisecondsSinceEpoch;

  bool _asBool(Object? value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'y') {
        return true;
      }
      if (normalized == 'false' ||
          normalized == '0' ||
          normalized == 'no' ||
          normalized == 'n') {
        return false;
      }
    }
    return fallback;
  }

  int _asInt(Object? value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback;
  }

  String _asString(Object? value, {required String fallback}) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return fallback;
  }

  List<int> _normalizeIntList(Object? value, {required List<int> fallback}) {
    if (value is List<int>) {
      return value.isEmpty ? fallback : List<int>.from(value);
    }
    if (value is List) {
      final parsed = value
          .map((item) => _asInt(item, fallback: 0))
          .toList(growable: false);
      return parsed.isEmpty ? fallback : parsed;
    }
    if (value is String) {
      final parts = value.split(',');
      final parsed = parts
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .map((part) => int.tryParse(part))
          .whereType<int>()
          .toList(growable: false);
      return parsed.isEmpty ? fallback : parsed;
    }
    return fallback;
  }

  String _normalizeSlug(
    Object? value, {
    required String name,
    required String fallback,
  }) {
    final provided = _asString(value, fallback: '');
    if (provided.isNotEmpty) {
      return _slugify(provided);
    }
    final named = _slugify(name);
    if (named.isNotEmpty) {
      return named;
    }
    return _slugify(fallback);
  }

  String _slugify(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }
    return normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
