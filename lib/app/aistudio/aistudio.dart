import 'package:flutter/material.dart';
import 'package:genrp/core/db/sqlite_store.dart';
import 'package:genrp/core/theme/genrp_theme.dart';
import 'package:genrp/core/widgets/hybrid_authoring_shell.dart';
import 'package:genrp/meta.dart';

class AIStudioApp extends StatelessWidget {
  const AIStudioApp({super.key, this.store});

  final SqliteStore? store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIStudio',
      theme: GenrpTheme.lightTheme(),
      darkTheme: GenrpTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: AIStudioHome(store: store),
    );
  }
}

class AIStudioHome extends StatefulWidget {
  const AIStudioHome({super.key, this.store});

  final SqliteStore? store;

  @override
  State<AIStudioHome> createState() => _AIStudioHomeState();
}

class _AIStudioHomeState extends State<AIStudioHome> {
  static const List<String> _uxCatalogs = <String>[
    'Host',
    'Body',
    'Template',
    'Type',
    'Widget',
    'UX Action',
    'FieldBinding',
    'Body Spec Node',
  ];

  String? _selectedCatalog;
  int? _selectedRowId;
  String _searchText = '';
  bool _isStoreReady = false;
  bool _isLoadingRows = false;
  String? _loadError;
  List<SqliteCatalogRow> _rows = const <SqliteCatalogRow>[];
  SqliteCatalogRow? _draftRow;
  final TextEditingController _searchController = TextEditingController();

  SqliteStore get _store => widget.store ?? SqliteStore.instance;

  @override
  void initState() {
    super.initState();
    _initializeStore();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      if (_selectedCatalog != null) {
        await _loadRows();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load SQLite store.';
      });
    }
  }

  void _onCatalogTapped(String catalog) {
    setState(() {
      _selectedCatalog = catalog;
      _selectedRowId = null;
      _searchText = '';
      _draftRow = null;
    });
    _searchController.clear();
    _loadRows();
  }

  Future<void> _loadRows() async {
    final catalog = _selectedCatalog;
    if (catalog == null) {
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
      final rows = await _store.listRows(catalog);
      if (!mounted || catalog != _selectedCatalog) return;
      setState(() {
        _rows = rows;
        _isLoadingRows = false;
      });
    } catch (_) {
      if (!mounted || catalog != _selectedCatalog) return;
      setState(() {
        _rows = const <SqliteCatalogRow>[];
        _isLoadingRows = false;
        _loadError = 'Failed to load rows.';
      });
    }
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
  }

  String _toSnakeCase(String value) {
    final normalized = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return normalized.toLowerCase();
  }

  Future<void> _createDraftRow() async {
    final catalog = _selectedCatalog;
    if (catalog == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final draftRow = SqliteCatalogRow(
      catalog: catalog,
      i: 0,
      a: true,
      d: now,
      e: 0,
      t: 0,
      n: 'New $catalog',
      s: _toSnakeCase('New $catalog'),
      updatedAt: 0,
    );

    setState(() {
      _draftRow = draftRow;
      _selectedRowId = 0;
    });
  }

  bool _matchesSearch(SqliteCatalogRow row) {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    return row.n.toLowerCase().contains(query);
  }

  List<SqliteCatalogRow> get _filteredRows {
    if (_searchText.trim().isEmpty) {
      return _rows;
    }
    return _rows.where(_matchesSearch).toList(growable: false);
  }

  List<SqliteCatalogRow> get _visibleRows {
    final draftRow = _draftRow;
    if (draftRow == null ||
        draftRow.catalog != _selectedCatalog ||
        !_matchesSearch(draftRow)) {
      return _filteredRows;
    }
    return <SqliteCatalogRow>[draftRow, ..._filteredRows];
  }

  Widget _buildCatalogItem(String catalog) {
    final isSelected = _selectedCatalog == catalog;
    final titleStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedColor = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 0.14);
    return ListTile(
      title: Text(
        catalog,
        style: titleStyle?.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: selectedColor,
      onTap: () => _onCatalogTapped(catalog),
    );
  }

  Widget _buildCatalogsTab() {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('UX/Spec', style: labelStyle),
        ),
        Expanded(
          child: ListView(
            children: _uxCatalogs
                .map<Widget>(_buildCatalogItem)
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _buildContextTab() {
    final selectedCatalog = _selectedCatalog ?? 'None';
    final selectedRow = _selectedRowId == null
        ? 'None'
        : _selectedRowId == 0
        ? '0 (draft)'
        : _selectedRowId.toString();
    final storeStatus = _isStoreReady ? 'Ready' : 'Loading';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Context', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const Text('Scope: UX/spec only'),
        const SizedBox(height: 8),
        Text('Selected catalog: $selectedCatalog'),
        const SizedBox(height: 8),
        Text('Selected row: $selectedRow'),
        const SizedBox(height: 8),
        Text('Store: $storeStatus'),
        if (_loadError != null) ...[
          const SizedBox(height: 8),
          Text('Error: $_loadError'),
        ],
        const SizedBox(height: 8),
        const Text(
          'Data-model explorer and sensitive schema editing stay in AICodex.',
        ),
      ],
    );
  }

  Widget _buildMasterHeader() {
    final toolbarHeight = GenrpTheme.toolbarHeightOf(context);
    final canCreateDraft =
        _selectedCatalog != null && _isStoreReady && !_isLoadingRows;
    return Container(
      height: toolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      color: Theme.of(context).cardTheme.color,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedCatalog ?? 'UX/Spec Explorer',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            key: const ValueKey<String>('aistudio_add_button'),
            tooltip: 'New draft',
            onPressed: canCreateDraft ? _createDraftRow : null,
            icon: const Icon(Icons.add),
          ),
        ],
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
    if (_selectedCatalog == null) {
      return const Center(child: Text('Select a UX/spec catalog.'));
    }
    if (_isLoadingRows) {
      return const Center(child: CircularProgressIndicator());
    }

    final rows = _visibleRows;
    if (rows.isEmpty) {
      return const Center(
        child: Text('No rows', key: ValueKey<String>('aistudio_rows_empty')),
      );
    }

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        final isSelected = row.i == _selectedRowId;
        final subtitle = row.i == 0 ? 'id: 0 (draft)' : 'id: ${row.i}';
        return ListTile(
          key: ValueKey<String>('aistudio_row_${row.catalog}_${row.i}'),
          title: Text(row.n.isEmpty ? '(Unnamed)' : row.n),
          subtitle: Text(subtitle),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              key: const ValueKey<String>('aistudio_search_field'),
              controller: _searchController,
              enabled: _selectedCatalog != null && _isStoreReady,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child: _buildMasterBody()),
        ],
      ),
    );
  }

  Widget _buildRightPanel(HybridShellLayoutMode mode) {
    final selectedCatalog = _selectedCatalog;
    final selectedRowId = _selectedRowId;
    if (selectedCatalog == null) {
      return Container(
        color: GenrpTheme.workspaceAltColorOf(context),
        child: const Center(
          child: Text(
            'Select a UX/spec catalog.',
            key: ValueKey<String>('aistudio_right_empty'),
          ),
        ),
      );
    }

    if (selectedRowId == null) {
      return Container(
        color: GenrpTheme.workspaceAltColorOf(context),
        child: const Center(
          child: Text(
            'Select or create a row.',
            key: ValueKey<String>('aistudio_right_unselected'),
          ),
        ),
      );
    }

    if (selectedRowId == 0 && _draftRow != null) {
      return Container(
        color: GenrpTheme.workspaceAltColorOf(context),
        child: Center(
          child: Text(
            'Draft row ready. Generic editor comes in Step 4.',
            key: const ValueKey<String>('aistudio_right_draft'),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      color: GenrpTheme.workspaceAltColorOf(context),
      child: Center(
        child: Text(
          'Selected row: $selectedRowId\nGeneric editor comes in Step 4.',
          key: const ValueKey<String>('aistudio_right_selected'),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AIStudio')),
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
            Text('AIStudio:${AppMeta.aistudio}/${AppMeta.f}/${AppMeta.v}'),
          ],
        ),
      ),
    );
  }
}
