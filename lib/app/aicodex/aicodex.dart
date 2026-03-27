import 'package:flutter/material.dart';
import 'package:genrp/app/aicodex/aicodex_mock_backend.dart';
import 'package:genrp/core/gen/explorer_state.dart';
import 'package:genrp/core/gen/uexplorer.dart';
import 'package:genrp/core/model/bschema/function_model.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/meta.dart';

class AICodexApp extends StatelessWidget {
  const AICodexApp({super.key, this.autoSignIn = false});

  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AICodex',
      theme: UxTheme.lightTheme(),
      darkTheme: UxTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: const AICodexHome(),
    );
  }
}

class AICodexHome extends StatefulWidget {
  const AICodexHome({super.key});

  static const List<UExplorerNode> _bschemaNodes = <UExplorerNode>[
    UExplorerNode(label: 'Entity'),
    UExplorerNode(label: 'Field'),
    UExplorerNode(label: 'Table'),
    UExplorerNode(label: 'Column'),
    UExplorerNode(label: 'Function'),
    UExplorerNode(label: 'Parameter'),
  ];

  @override
  State<AICodexHome> createState() => _AICodexHomeState();
}

class _AICodexHomeState extends State<AICodexHome> {
  late final AICodexMockBackend _backend;
  late final ExplorerState _explorerState;
  String _selectedCatalog = AICodexHome._bschemaNodes.first.label;
  int? _selectedId;

  AICodexCatalogSpec get _selectedSpec => _backend.specFor(_selectedCatalog);

  List<Map<String, Object?>> get _records => _backend.rowsFor(_selectedCatalog);

  Map<String, Object?>? get _selectedRecord {
    final selectedId = _selectedId;
    if (selectedId == null) {
      return null;
    }
    return _backend.recordFor(_selectedCatalog, selectedId);
  }

  @override
  void initState() {
    super.initState();
    _backend = AICodexMockBackend();
    _explorerState = ExplorerState(
      nodes: AICodexHome._bschemaNodes,
      title: 'Bschema',
      selectedMasterItem: _selectedCatalog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AICodex'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: const Text('Mock backend'),
              avatar: Icon(
                Icons.memory_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final compact = constraints.maxWidth < 980;
          if (compact) {
            return Column(
              children: <Widget>[
                SizedBox(height: 220, child: _buildExplorerPanel(context)),
                Expanded(child: _buildWorkArea(context, compact: true)),
              ],
            );
          }
          return Row(
            children: <Widget>[
              SizedBox(width: 220, child: _buildExplorerPanel(context)),
              Expanded(child: _buildWorkArea(context, compact: false)),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            Text(_statusText),
            const Spacer(),
            Text('AICodex:${AppMeta.aicodex}/${AppMeta.f}/${AppMeta.v}'),
          ],
        ),
      ),
    );
  }

  String get _statusText {
    final count = _records.length;
    final selectionLabel = _selectedId == null ? 'none' : '#$_selectedId';
    final suffix = count == 1 ? '' : 's';
    return 'Catalog: $_selectedCatalog | $count record$suffix | Selected: $selectionLabel';
  }

  Widget _buildExplorerPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      child: Container(
        decoration: UxTheme.softPanelDecoration(context),
        clipBehavior: Clip.antiAlias,
        child: UExplorer(
          state: _explorerState,
          onMasterTap: (UExplorerNode node) {
            _selectCatalog(node.label);
          },
          onViewTap: (UExplorerNode node) {
            _selectCatalog(node.label);
          },
        ),
      ),
    );
  }

  Widget _buildWorkArea(BuildContext context, {required bool compact}) {
    final inspector = _buildInspectorPanel(context);
    final grid = _buildGridPanel(context);
    if (compact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
        child: Column(
          children: <Widget>[
            _buildToolbarPanel(context),
            const SizedBox(height: 12),
            Expanded(child: grid),
            const SizedBox(height: 12),
            SizedBox(height: 240, child: inspector),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      child: Column(
        children: <Widget>[
          _buildToolbarPanel(context),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(flex: 3, child: grid),
                const SizedBox(width: 16),
                SizedBox(width: 320, child: inspector),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarPanel(BuildContext context) {
    final selectedId = _selectedId;
    return Container(
      decoration: UxTheme.panelDecoration(context),
      padding: UxTheme.panelPadding,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 220, maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_selectedCatalog, style: UxTheme.titleStyle(context)),
                const SizedBox(height: 4),
                Text(
                  '${_records.length} in-memory record${_records.length == 1 ? '' : 's'} ready for CRUD',
                  style: UxTheme.bodyStyle(context),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _createRecord,
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
              OutlinedButton.icon(
                onPressed: selectedId == null ? null : _editSelectedRecord,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: selectedId == null ? null : _deleteSelectedRecord,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
              TextButton.icon(
                onPressed: _selectedId == null
                    ? null
                    : () {
                        setState(() {
                          _selectedId = null;
                        });
                      },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridPanel(BuildContext context) {
    final records = _records;
    final spec = _selectedSpec;
    if (records.isEmpty) {
      return Container(
        decoration: UxTheme.softPanelDecoration(context),
        padding: UxTheme.panelPadding,
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(spec.emptyTitle, style: UxTheme.titleStyle(context)),
            const SizedBox(height: 8),
            Text(spec.emptyMessage, style: UxTheme.bodyStyle(context)),
          ],
        ),
      );
    }

    return Container(
      decoration: UxTheme.softPanelDecoration(context),
      padding: const EdgeInsets.all(12),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 40,
              columns: spec.columns
                  .map(
                    (String column) => DataColumn(
                      label: Text(column, style: UxTheme.keyStyle(context)),
                    ),
                  )
                  .toList(growable: false),
              rows: List<DataRow>.generate(records.length, (int index) {
                final record = records[index];
                final id = _recordId(record);
                return DataRow.byIndex(
                  index: index,
                  selected: id == _selectedId,
                  onSelectChanged: (_) {
                    setState(() {
                      _selectedId = id;
                    });
                  },
                  cells: spec.columns
                      .map(
                        (String column) => DataCell(
                          Text(_formatCellValue(column, record[column])),
                          onTap: () {
                            setState(() {
                              _selectedId = id;
                            });
                          },
                          onDoubleTap: _selectedId == id
                              ? _editSelectedRecord
                              : null,
                        ),
                      )
                      .toList(growable: false),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInspectorPanel(BuildContext context) {
    final record = _selectedRecord;
    return Container(
      decoration: UxTheme.panelDecoration(context),
      padding: UxTheme.panelPadding,
      child: record == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Inspector', style: UxTheme.titleStyle(context)),
                const SizedBox(height: 8),
                Text(
                  'Select a row to inspect it, then use Edit or Delete to exercise the mock CRUD backend.',
                  style: UxTheme.bodyStyle(context),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Inspector', style: UxTheme.titleStyle(context)),
                const SizedBox(height: 4),
                Text('ID #${record['i']}', style: UxTheme.bodyStyle(context)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: record.entries
                        .map(
                          (MapEntry<String, Object?> entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _InspectorRow(
                              label: entry.key,
                              value: _formatCellValue(entry.key, entry.value),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
    );
  }

  void _selectCatalog(String label) {
    setState(() {
      _selectedCatalog = label;
      _selectedId = null;
      _explorerState.setSelectedMasterItem(label);
    });
  }

  Future<void> _createRecord() async {
    final draft = await _showEditorDialog(
      context,
      spec: _selectedSpec,
      title: 'Create $_selectedCatalog',
    );
    if (!mounted || draft == null) {
      return;
    }
    final id = _backend.createRecord(_selectedCatalog, draft);
    setState(() {
      _selectedId = id;
    });
    _showMessage('Created $_selectedCatalog #$id');
  }

  Future<void> _editSelectedRecord() async {
    final selectedId = _selectedId;
    if (selectedId == null) {
      return;
    }
    final record = _selectedRecord;
    if (record == null) {
      return;
    }
    final draft = await _showEditorDialog(
      context,
      spec: _selectedSpec,
      title: 'Edit $_selectedCatalog #$selectedId',
      initialValues: record,
    );
    if (!mounted || draft == null) {
      return;
    }
    _backend.updateRecord(_selectedCatalog, selectedId, draft);
    setState(() {});
    _showMessage('Updated $_selectedCatalog #$selectedId');
  }

  Future<void> _deleteSelectedRecord() async {
    final selectedId = _selectedId;
    if (selectedId == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $_selectedCatalog #$selectedId?'),
          content: const Text(
            'This only affects the in-memory mock backend for the current session.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (!mounted || confirmed != true) {
      return;
    }
    _backend.deleteRecord(_selectedCatalog, selectedId);
    setState(() {
      _selectedId = null;
    });
    _showMessage('Deleted $_selectedCatalog #$selectedId');
  }

  Future<Map<String, Object?>?> _showEditorDialog(
    BuildContext context, {
    required AICodexCatalogSpec spec,
    required String title,
    Map<String, Object?>? initialValues,
  }) {
    return showDialog<Map<String, Object?>>(
      context: context,
      builder: (BuildContext context) {
        return _RecordEditorDialog(
          title: title,
          spec: spec,
          initialValues: initialValues,
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  int _recordId(Map<String, Object?> record) {
    final value = record['i'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  String _formatCellValue(String column, Object? value) {
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    if (value is List) {
      return '[${value.join(', ')}]';
    }
    if (column == 't' && _selectedCatalog == 'Function') {
      final id = value is num ? value.toInt() : int.tryParse('${value ?? 0}');
      final label = id == null ? null : FunctionType.labelById(id);
      if (label != null) {
        return '$id ($label)';
      }
    }
    return '${value ?? ''}';
  }
}

class _InspectorRow extends StatelessWidget {
  const _InspectorRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: UxTheme.softPanelDecoration(context, outlineAlpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: UxTheme.keyStyle(context)),
          const SizedBox(height: 4),
          Text(value, style: UxTheme.bodyStyle(context)),
        ],
      ),
    );
  }
}

class _RecordEditorDialog extends StatefulWidget {
  const _RecordEditorDialog({
    required this.title,
    required this.spec,
    this.initialValues,
  });

  final String title;
  final AICodexCatalogSpec spec;
  final Map<String, Object?>? initialValues;

  @override
  State<_RecordEditorDialog> createState() => _RecordEditorDialogState();
}

class _RecordEditorDialogState extends State<_RecordEditorDialog> {
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final Map<String, bool> _boolValues = <String, bool>{};
  String? _errorText;
  int? _selectedFunctionType;

  @override
  void initState() {
    super.initState();
    final initialValues = widget.initialValues ?? const <String, Object?>{};
    for (final field in widget.spec.formFields) {
      final initialValue = initialValues[field.key] ?? field.defaultValue;
      switch (field.kind) {
        case AICodexFieldKind.boolean:
          _boolValues[field.key] = _coerceBool(initialValue, fallback: true);
          break;
        case AICodexFieldKind.functionType:
          _selectedFunctionType = _coerceInt(
            initialValue,
            fallback: FunctionType.bizGet,
          );
          break;
        case AICodexFieldKind.integer:
        case AICodexFieldKind.integerList:
        case AICodexFieldKind.text:
          _controllers[field.key] = TextEditingController(
            text: _textValue(field, initialValue),
          );
          break;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (widget.initialValues case final Map<String, Object?> values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Editing record #${values['i']}',
                    style: UxTheme.bodyStyle(context),
                  ),
                ),
              ...widget.spec.formFields.map(_buildField),
              if (_errorText case final String error) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  Widget _buildField(AICodexFieldSpec field) {
    switch (field.kind) {
      case AICodexFieldKind.boolean:
        return SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(field.label),
          subtitle: field.hint.isEmpty ? null : Text(field.hint),
          value: _boolValues[field.key] ?? true,
          onChanged: (bool value) {
            setState(() {
              _boolValues[field.key] = value;
            });
          },
        );
      case AICodexFieldKind.functionType:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedFunctionType,
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.hint.isEmpty ? null : field.hint,
            ),
            items: FunctionType.labelsById.entries
                .map(
                  (MapEntry<int, String> entry) => DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text('${entry.key} (${entry.value})'),
                  ),
                )
                .toList(growable: false),
            onChanged: (int? value) {
              setState(() {
                _selectedFunctionType = value;
              });
            },
          ),
        );
      case AICodexFieldKind.integer:
      case AICodexFieldKind.integerList:
      case AICodexFieldKind.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _controllers[field.key],
            keyboardType: field.kind == AICodexFieldKind.text
                ? TextInputType.text
                : TextInputType.number,
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.hint.isEmpty ? null : field.hint,
            ),
          ),
        );
    }
  }

  void _submit() {
    try {
      final draft = <String, Object?>{};
      for (final field in widget.spec.formFields) {
        switch (field.kind) {
          case AICodexFieldKind.boolean:
            draft[field.key] = _boolValues[field.key] ?? true;
            break;
          case AICodexFieldKind.integer:
            draft[field.key] = _parseIntField(
              _controllers[field.key]?.text ?? '',
              field.label,
            );
            break;
          case AICodexFieldKind.integerList:
            draft[field.key] = _parseIntListField(
              _controllers[field.key]?.text ?? '',
              field.label,
            );
            break;
          case AICodexFieldKind.text:
            draft[field.key] = (_controllers[field.key]?.text ?? '').trim();
            break;
          case AICodexFieldKind.functionType:
            draft[field.key] = _selectedFunctionType ?? FunctionType.bizGet;
            break;
        }
      }
      Navigator.of(context).pop(draft);
    } on FormatException catch (error) {
      setState(() {
        _errorText = error.message;
      });
    }
  }

  String _textValue(AICodexFieldSpec field, Object? value) {
    if (value is List) {
      return value.join(', ');
    }
    if (value == null) {
      return field.defaultValue?.toString() ?? '';
    }
    return '$value';
  }

  bool _coerceBool(Object? value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    return fallback;
  }

  int _coerceInt(Object? value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  int _parseIntField(String raw, String label) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      throw FormatException('$label must be a whole number.');
    }
    return parsed;
  }

  List<int> _parseIntListField(String raw, String label) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const <int>[];
    }
    final result = <int>[];
    for (final part in trimmed.split(',')) {
      final candidate = part.trim();
      if (candidate.isEmpty) {
        continue;
      }
      final parsed = int.tryParse(candidate);
      if (parsed == null) {
        throw FormatException(
          '$label must contain only comma-separated integers.',
        );
      }
      result.add(parsed);
    }
    return result;
  }
}
