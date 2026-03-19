import 'package:flutter/material.dart';
import 'package:genrp/core/db/sqlite_store.dart';
import 'package:genrp/meta.dart';

class AICodexApp extends StatelessWidget {
  const AICodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AICodex',
      home: AICodexHome(),
    );
  }
}

class AICodexHome extends StatefulWidget {
  const AICodexHome({super.key});

  @override
  State<AICodexHome> createState() => _AICodexHomeState();
}

class _AICodexHomeState extends State<AICodexHome> {
  String? _selectedModelType;
  int? _selectedRowId;
  List<SqliteCatalogRow> _rows = [];
  String _searchText = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRows(String modelType) async {
    final rows = await SqliteStore.instance.listRows(modelType);
    setState(() {
      _rows = rows;
    });
  }

  void _onModelTypeTapped(String modelType) {
    setState(() {
      _selectedModelType = modelType;
      _selectedRowId = null;
      _searchText = '';
      _searchController.clear();
    });
    _loadRows(modelType);
  }

  Widget _buildNavItem(String title) {
    final isSelected = _selectedModelType == title;
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
      onTap: () => _onModelTypeTapped(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _rows.where((row) {
      if (_searchText.isEmpty) return true;
      return row.n.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();

    return Scaffold(
        appBar: AppBar(title: const Text('AICodex')),
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey.shade100,
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Schema Source', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    _buildNavItem('Entity'),
                    _buildNavItem('Field'),
                    _buildNavItem('Relation'),
                    _buildNavItem('Action'),
                    _buildNavItem('Function'),
                    _buildNavItem('Parameter'),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Schema Target', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    _buildNavItem('Table'),
                    _buildNavItem('Column'),
                    _buildNavItem('System'),
                    _buildNavItem('User'),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey.shade200,
                      width: double.infinity,
                      child: Text(
                        _selectedModelType ?? 'Master/Main Editor',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_selectedModelType != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchText = value;
                            });
                          },
                        ),
                      ),
                    Expanded(
                      child: _selectedModelType == null
                          ? const Center(child: Text('Master/Main Editor'))
                          : filteredRows.isEmpty
                              ? const Center(child: Text('No rows'))
                              : ListView.builder(
                                  itemCount: filteredRows.length,
                                  itemBuilder: (context, index) {
                                    final row = filteredRows[index];
                                    final isSelected = row.i == _selectedRowId;
                                    return ListTile(
                                      title: Text(row.n.isNotEmpty ? row.n : 'Unnamed'),
                                      subtitle: Text('ID: ${row.i}'),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: row.a ? Colors.green.shade100 : Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          row.a ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            color: row.a ? Colors.green.shade800 : Colors.red.shade800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                                      onTap: () {
                                        setState(() {
                                          _selectedRowId = row.i;
                                        });
                                      },
                                    );
                                  },
                                ),
                    )
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey.shade100,
                child: const Center(child: Text('Property Editor')),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Spacer(),
                Text('AICodex:${AppMeta.aicode}/${AppMeta.f}/${AppMeta.v}'),
              ],
            ),
          ),
        ),
    );
  }
}
