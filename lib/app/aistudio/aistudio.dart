import 'package:flutter/material.dart';
import 'package:genrp/meta.dart';

class AIStudioApp extends StatelessWidget {
  const AIStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIStudio',
      home: AIStudioHome(),
    );
  }
}

class AIStudioHome extends StatefulWidget {
  const AIStudioHome({super.key});

  @override
  State<AIStudioHome> createState() => _AIStudioHomeState();
}

class _AIStudioHomeState extends State<AIStudioHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;
  String? _selectedCatalog;
  // ignore: unused_field
  int? _selectedRowId;
  // ignore: unused_field
  final String _searchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _activeTab != _tabController.index) {
        setState(() {
          _activeTab = _tabController.index;
          _selectedCatalog = null;
          _selectedRowId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCatalogTapped(String catalog) {
    setState(() {
      _selectedCatalog = catalog;
      _selectedRowId = null;
    });
  }

  Widget _buildNavItem(String title) {
    final isSelected = _selectedCatalog == title;
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
      onTap: () => _onCatalogTapped(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AIStudio')),
      body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: const [
                        Tab(text: 'Data'),
                        Tab(text: 'UX/Spec'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          ListView(
                            children: [
                              _buildNavItem('Entity'),
                              _buildNavItem('Field'),
                              _buildNavItem('Relation'),
                              _buildNavItem('Action'),
                              _buildNavItem('Function'),
                              _buildNavItem('Parameter'),
                              _buildNavItem('Table'),
                              _buildNavItem('Column'),
                              _buildNavItem('System'),
                              _buildNavItem('User'),
                            ],
                          ),
                          ListView(
                            children: [
                              _buildNavItem('Host'),
                              _buildNavItem('Body'),
                              _buildNavItem('Template'),
                              _buildNavItem('Type'),
                              _buildNavItem('Widget'),
                              _buildNavItem('FieldBinding'),
                              _buildNavItem('UX Action'),
                              _buildNavItem('Body Spec Node'),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                        _selectedCatalog ?? 'Master/Main Editor',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Expanded(
                      child: Center(child: Text('Master/Main Editor')),
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
          child: const Icon(Icons.edit),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Spacer(),
                Text('AIStudio:${AppMeta.aistudio}/${AppMeta.f}/${AppMeta.v}'),
              ],
            ),
          ),
        ),
    );
  }
}
