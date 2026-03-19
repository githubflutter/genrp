import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:genrp/core/db/sqlite_store.dart';
import 'package:genrp/core/generator/ddl_generator.dart';
import 'package:genrp/core/theme/genrp_theme.dart';
import 'package:genrp/core/widgets/hybrid_authoring_shell.dart';
import 'package:genrp/meta.dart';

class AICodexApp extends StatelessWidget {
  const AICodexApp({super.key, this.store});

  final SqliteStore? store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AICodex',
      theme: GenrpTheme.lightTheme(),
      darkTheme: GenrpTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: AICodexHome(store: store),
    );
  }
}

class AICodexHome extends StatefulWidget {
  const AICodexHome({super.key, this.store});

  final SqliteStore? store;

  @override
  State<AICodexHome> createState() => _AICodexHomeState();
}

class _AICodexHomeState extends State<AICodexHome> {
  static const List<String> _schemaSourceModels = <String>[
    'Entity',
    'Field',
    'Relation',
    'Function',
    'Parameter',
  ];
  static const List<String> _schemaTargetModels = <String>[
    'Table',
    'Column',
    'System',
    'User',
  ];

  String? _selectedModelType;
  int? _selectedRowId;
  String _searchText = '';
  bool _isStoreReady = false;
  bool _isLoadingRows = false;
  bool _isLoadingDetail = false;
  bool _isSavingDetail = false;
  String? _loadError;
  String? _detailError;
  List<SqliteCatalogRow> _rows = const <SqliteCatalogRow>[];
  SqliteCatalogRow? _selectedRow;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _detailNameController = TextEditingController();
  final TextEditingController _detailSystemNameController =
      TextEditingController();
  final TextEditingController _detailPayloadController =
      TextEditingController();
  bool _detailActive = true;
  String? _generatedScript;

  static const JsonEncoder _prettyJsonEncoder = JsonEncoder.withIndent('  ');

  SqliteStore get _store => widget.store ?? SqliteStore.instance;

  @override
  void initState() {
    super.initState();
    _initializeStore();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _detailNameController.dispose();
    _detailSystemNameController.dispose();
    _detailPayloadController.dispose();
    super.dispose();
  }

  Future<void> _initializeStore() async {
    try {
      await _store.database;
      if (!mounted) return;
      setState(() {
        _isStoreReady = true;
        _loadError = null;
      });
      if (_selectedModelType != null) {
        await _loadRows();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load SQLite store.';
      });
    }
  }

  void _onModelTypeTapped(String modelType) {
    setState(() {
      _selectedModelType = modelType;
      _selectedRowId = null;
      _searchText = '';
      _selectedRow = null;
      _detailError = null;
      _isLoadingDetail = false;
      _generatedScript = null;
    });
    _searchController.clear();
    _clearDetailEditors();
    _loadRows();
  }

  Future<void> _loadRows() async {
    final modelType = _selectedModelType;
    if (modelType == null) {
      setState(() {
        _rows = const <SqliteCatalogRow>[];
        _isLoadingRows = false;
        _loadError = null;
      });
      return;
    }

    setState(() {
      _isLoadingRows = true;
      _loadError = null;
    });

    try {
      final rows = await _store.listRows(modelType);
      if (!mounted || modelType != _selectedModelType) return;
      setState(() {
        _rows = rows;
        _isLoadingRows = false;
      });
    } catch (_) {
      if (!mounted || modelType != _selectedModelType) return;
      setState(() {
        _rows = const <SqliteCatalogRow>[];
        _isLoadingRows = false;
        _loadError = 'Failed to load rows.';
      });
    }
  }

  Future<void> _addRow() async {
    final modelType = _selectedModelType;
    if (modelType == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final draftRow = SqliteCatalogRow(
      catalog: modelType,
      i: 0,
      a: true,
      d: now,
      e: 0,
      t: 0,
      n: 'New $modelType',
      s: _toSnakeCase('New $modelType'),
      updatedAt: 0,
    );

    setState(() {
      _selectedRowId = 0;
      _selectedRow = draftRow;
      _detailError = null;
      _isLoadingDetail = false;
    });
    _applyDetailEditors(draftRow);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value;
    });
  }

  void _onRowTapped(int rowId) {
    setState(() {
      _selectedRowId = rowId;
    });
    _loadSelectedRow();
  }

  List<SqliteCatalogRow> get _filteredRows {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) {
      return _rows;
    }
    return _rows.where((row) => row.n.toLowerCase().contains(query)).toList();
  }

  String _toSnakeCase(String value) {
    final normalized = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return normalized.toLowerCase();
  }

  void _clearDetailEditors() {
    _detailNameController.clear();
    _detailSystemNameController.clear();
    _detailPayloadController.text = '{}';
    _detailActive = true;
    _generatedScript = null;
  }

  String _formatPayload(Map<String, dynamic> payload) {
    if (payload.isEmpty) return '{}';
    return _prettyJsonEncoder.convert(payload);
  }

  void _applyDetailEditors(SqliteCatalogRow row) {
    _detailNameController.text = row.n;
    _detailSystemNameController.text = row.s;
    _detailPayloadController.text = _formatPayload(row.payload);
    _detailActive = row.a;
  }

  Future<void> _loadSelectedRow() async {
    final modelType = _selectedModelType;
    final rowId = _selectedRowId;
    if (modelType == null || rowId == null) {
      if (!mounted) return;
      setState(() {
        _selectedRow = null;
        _detailError = null;
        _isLoadingDetail = false;
      });
      _clearDetailEditors();
      return;
    }

    if (rowId == 0 && _selectedRow?.i == 0) {
      final draftRow = _selectedRow!;
      _applyDetailEditors(draftRow);
      setState(() {
        _detailError = null;
        _isLoadingDetail = false;
      });
      return;
    }

    setState(() {
      _isLoadingDetail = true;
      _detailError = null;
    });

    try {
      final row = await _store.getRow(modelType, rowId);
      if (!mounted ||
          modelType != _selectedModelType ||
          rowId != _selectedRowId) {
        return;
      }

      if (row == null) {
        _clearDetailEditors();
        setState(() {
          _selectedRow = null;
          _isLoadingDetail = false;
          _detailError = 'Selected row not found.';
        });
        return;
      }

      _applyDetailEditors(row);

      setState(() {
        _selectedRow = row;
        _isLoadingDetail = false;
      });
    } catch (_) {
      if (!mounted ||
          modelType != _selectedModelType ||
          rowId != _selectedRowId) {
        return;
      }
      _clearDetailEditors();
      setState(() {
        _selectedRow = null;
        _isLoadingDetail = false;
        _detailError = 'Failed to load selected row.';
      });
    }
  }

  Map<String, dynamic> _parsePayload() {
    final raw = _detailPayloadController.text.trim();
    if (raw.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Payload must be a JSON object.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _saveSelectedRow() async {
    final modelType = _selectedModelType;
    final selectedRow = _selectedRow;
    if (modelType == null || selectedRow == null) return;

    Map<String, dynamic> payload;
    try {
      payload = _parsePayload();
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _detailError = error.message;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detailError = 'Payload must be valid JSON.';
      });
      return;
    }

    final normalizedName = _detailNameController.text.trim();
    final systemInput = _detailSystemNameController.text.trim();
    final normalizedSystemName = _toSnakeCase(
      systemInput.isEmpty ? normalizedName : systemInput,
    );

    setState(() {
      _isSavingDetail = true;
      _detailError = null;
    });

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      var updatedRow = selectedRow.copyWith(
        a: _detailActive,
        d: now,
        n: normalizedName,
        s: normalizedSystemName,
        payload: payload,
        updatedAt: 0,
      );
      if (updatedRow.i == 0) {
        final nextId = await _store.nextRowId(modelType);
        updatedRow = updatedRow.copyWith(i: nextId);
      }
      await _store.upsertRow(updatedRow);
      await _loadRows();
      if (!mounted) return;
      setState(() {
        _selectedRowId = updatedRow.i;
        _selectedRow = updatedRow;
      });
      await _loadSelectedRow();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Row saved.')));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detailError = 'Failed to save row.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDetail = false;
        });
      }
    }
  }

  Future<void> _deleteSelectedRow() async {
    final modelType = _selectedModelType;
    final rowId = _selectedRowId;
    if (modelType == null || rowId == null) return;

    if (rowId == 0 || _selectedRow?.i == 0) {
      _clearDetailEditors();
      setState(() {
        _selectedRowId = null;
        _selectedRow = null;
        _detailError = null;
        _isLoadingDetail = false;
        _generatedScript = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Draft discarded.')));
      return;
    }

    setState(() {
      _isSavingDetail = true;
      _detailError = null;
    });

    try {
      await _store.deleteRow(modelType, rowId);
      await _loadRows();
      if (!mounted) return;
      _clearDetailEditors();
      setState(() {
        _selectedRowId = null;
        _selectedRow = null;
        _detailError = null;
        _generatedScript = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Row deleted.')));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detailError = 'Failed to delete row.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDetail = false;
        });
      }
    }
  }

  Future<void> _generateCreateTable() async {
    final row = _selectedRow;
    if (row == null || _selectedModelType != 'Entity') return;
    try {
      // Basic generation; ideally we would fetch fields from store for this entity
      final sql = DdlGenerator.generateCreate(row, []);
      setState(() {
        _generatedScript = sql;
      });
    } catch (e) {
      setState(() {
        _detailError = 'Failed to generate Create Table SQL: $e';
      });
    }
  }

  Future<void> _generateDropTable() async {
    final row = _selectedRow;
    if (row == null || _selectedModelType != 'Entity') return;
    setState(() {
      _generatedScript = DdlGenerator.generateDrop(row);
    });
  }

  Future<void> _generateCreateFunction() async {
    final row = _selectedRow;
    if (row == null || _selectedModelType != 'Function') return;
    try {
      // Basic generation; ideally we would fetch params from store for this function
      final sql = DdlGenerator.generateCreateFunction(row, []);
      setState(() {
        _generatedScript = sql;
      });
    } catch (e) {
      setState(() {
        _detailError = 'Failed to generate Create Function SQL: $e';
      });
    }
  }

  Future<void> _generateVirtualFun() async {
    final row = _selectedRow;
    if (row == null || _selectedModelType != 'Function') return;
    setState(() {
      _generatedScript = DdlGenerator.generateVirtualFun(row, _detailPayloadController.text);
    });
  }

  void _copyScript() {
    if (_generatedScript == null) return;
    Clipboard.setData(ClipboardData(text: _generatedScript!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Script copied to clipboard.')),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    Key? key,
  }) {
    return InputDecorator(
      key: key,
      decoration: InputDecoration(labelText: label),
      child: SelectableText(value),
    );
  }

  Widget _buildNavItem(String title) {
    final isSelected = _selectedModelType == title;
    final titleStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedColor = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 0.14);
    return ListTile(
      title: Text(
        title,
        style: titleStyle?.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: selectedColor,
      onTap: () => _onModelTypeTapped(title),
    );
  }

  Widget _buildCatalogsTab() {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
    );
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Schema Source', style: labelStyle),
        ),
        ..._schemaSourceModels.map(_buildNavItem),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Schema Target', style: labelStyle),
        ),
        ..._schemaTargetModels.map(_buildNavItem),
      ],
    );
  }

  Widget _buildContextTab() {
    final selectedModel = _selectedModelType ?? 'None';
    final selectedRow = _selectedRowId?.toString() ?? 'None';
    final storeStatus = _isStoreReady ? 'Ready' : 'Loading';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Context', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text('Selected model: $selectedModel'),
        const SizedBox(height: 8),
        Text('Selected row: $selectedRow'),
        const SizedBox(height: 8),
        Text('Store: $storeStatus'),
        if (_loadError != null) ...[
          const SizedBox(height: 8),
          Text('Error: $_loadError'),
        ],
      ],
    );
  }

  Widget _buildMasterHeader() {
    final canAdd =
        _selectedModelType != null && _isStoreReady && !_isLoadingRows;
    final toolbarHeight = GenrpTheme.toolbarHeightOf(context);
    return Column(
      children: [
        Container(
          height: toolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Theme.of(context).cardTheme.color,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedModelType ?? 'Master/Main Editor',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                key: const ValueKey<String>('aicodex_add_button'),
                tooltip: 'New draft',
                onPressed: canAdd ? _addRow : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            key: const ValueKey<String>('aicodex_search_field'),
            controller: _searchController,
            enabled: _selectedModelType != null && _isStoreReady,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              labelText: 'Search by name',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveBadge(bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isActive
        ? colorScheme.secondaryContainer
        : colorScheme.errorContainer;
    final foregroundColor = isActive
        ? colorScheme.onSecondaryContainer
        : colorScheme.onErrorContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
      ),
    );
  }

  Widget _buildMasterBody() {
    if (_loadError != null) {
      return Center(child: Text(_loadError!));
    }
    if (!_isStoreReady) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_selectedModelType == null) {
      return const Center(child: Text('Select a model type.'));
    }
    if (_isLoadingRows) {
      return const Center(child: CircularProgressIndicator());
    }

    final rows = _filteredRows;
    if (rows.isEmpty) {
      return const Center(child: Text('No rows'));
    }

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        final isSelected = row.i == _selectedRowId;
        return ListTile(
          key: ValueKey<String>('aicodex_row_${row.catalog}_${row.i}'),
          title: Text(row.n.isEmpty ? '(Unnamed)' : row.n),
          subtitle: Text('id: ${row.i}'),
          trailing: _buildActiveBadge(row.a),
          selected: isSelected,
          selectedTileColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.1),
          onTap: () => _onRowTapped(row.i),
        );
      },
    );
  }

  Widget _buildMidPanel(HybridShellLayoutMode mode) {
    return Container(
      color: GenrpTheme.workspaceColorOf(context),
      child: Column(
        children: [
          _buildMasterHeader(),
          Expanded(child: _buildMasterBody()),
        ],
      ),
    );
  }

  Widget _buildRightPanel(HybridShellLayoutMode mode) {
    if (_isLoadingDetail) {
      return Container(
        color: GenrpTheme.workspaceAltColorOf(context),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_selectedModelType == null ||
        _selectedRowId == null ||
        _selectedRow == null) {
      return Container(
        color: GenrpTheme.workspaceAltColorOf(context),
        child: const Center(
          child: Text(
            'No row selected',
            key: ValueKey<String>('aicodex_detail_empty'),
          ),
        ),
      );
    }

    final row = _selectedRow!;
    final relationNote = switch (_selectedModelType) {
      'Entity' =>
        'Field summary is deferred until explicit entity link metadata is finalized.',
      'Table' =>
        'Column summary is deferred until explicit table link metadata is finalized.',
      _ => null,
    };

    return Container(
      color: GenrpTheme.workspaceAltColorOf(context),
      child: ListView(
        key: const ValueKey<String>('aicodex_detail_scroll'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${_selectedModelType!} Detail',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildReadOnlyField(
            key: const ValueKey<String>('aicodex_detail_id_field'),
            label: 'ID',
            value: row.i == 0 ? '0 (draft)' : row.i.toString(),
          ),
          const SizedBox(height: 12),
          _buildReadOnlyField(label: 'Last date', value: row.d.toString()),
          const SizedBox(height: 12),
          _buildReadOnlyField(label: 'Last editor', value: row.e.toString()),
          const SizedBox(height: 12),
          _buildReadOnlyField(label: 'Type', value: row.t.toString()),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey<String>('aicodex_detail_name_field'),
            controller: _detailNameController,
            decoration: const InputDecoration(labelText: 'Readable name'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey<String>('aicodex_detail_system_field'),
            controller: _detailSystemNameController,
            decoration: const InputDecoration(
              labelText: 'System name',
              helperText: 'Saved as lower snake_case.',
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            key: const ValueKey<String>('aicodex_detail_active_switch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Active'),
            value: _detailActive,
            onChanged: _isSavingDetail
                ? null
                : (value) {
                    setState(() {
                      _detailActive = value;
                    });
                  },
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey<String>('aicodex_detail_payload_field'),
            controller: _detailPayloadController,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(labelText: 'Payload JSON'),
          ),
          if (relationNote != null) ...[
            const SizedBox(height: 12),
            Text(
              relationNote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
          if (_detailError != null) ...[
            const SizedBox(height: 12),
            Text(
              _detailError!,
              key: const ValueKey<String>('aicodex_detail_error'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                key: const ValueKey<String>('aicodex_detail_save_button'),
                onPressed: _isSavingDetail ? null : _saveSelectedRow,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
              OutlinedButton.icon(
                key: const ValueKey<String>('aicodex_detail_delete_button'),
                onPressed: _isSavingDetail ? null : _deleteSelectedRow,
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
              ),
            ],
          ),
          if (_isSavingDetail) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_selectedModelType == 'Entity' && row.i != 0) ...[
            const Divider(height: 32),
            Text('Schema Actions', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: _generateCreateTable,
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Create Table'),
                ),
                OutlinedButton.icon(
                  onPressed: _generateDropTable,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Drop Table'),
                ),
              ],
            ),
          ],
          if (_selectedModelType == 'Function' && row.i != 0) ...[
            const Divider(height: 32),
            Text('Schema Actions', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: _generateCreateFunction,
                  icon: const Icon(Icons.functions),
                  label: const Text('Create Function'),
                ),
                OutlinedButton.icon(
                  onPressed: _generateVirtualFun,
                  icon: const Icon(Icons.memory),
                  label: const Text('SQLite vfun'),
                ),
              ],
            ),
          ],
          if (_generatedScript != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _generatedScript!,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _copyScript,
                icon: const Icon(Icons.copy),
                label: const Text('Copy Script'),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(switch (mode) {
            HybridShellLayoutMode.single => 'Single workspace mode',
            HybridShellLayoutMode.dual => 'Dual workspace mode',
            HybridShellLayoutMode.split => 'Equal workspace mode',
          }, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AICodex')),
      body: HybridAuthoringShell(
        initialMajorTabIndex: 1,
        minorTabs: <HybridShellTab>[
          HybridShellTab(label: 'Catalogs', child: _buildCatalogsTab()),
          HybridShellTab(label: 'Context', child: _buildContextTab()),
        ],
        majorTabs: const <HybridShellMajorTab>[
          HybridShellMajorTab(
            label: 'Single',
            layoutMode: HybridShellLayoutMode.single,
          ),
          HybridShellMajorTab(
            label: 'Dual',
            layoutMode: HybridShellLayoutMode.dual,
          ),
          HybridShellMajorTab(
            label: 'Equal',
            layoutMode: HybridShellLayoutMode.split,
          ),
        ],
        buildMidPanel: (_, mode) => _buildMidPanel(mode),
        buildRightPanel: (_, mode) => _buildRightPanel(mode),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            const Spacer(),
            Text('AICodex:${AppMeta.aicode}/${AppMeta.f}/${AppMeta.v}'),
          ],
        ),
      ),
    );
  }
}
