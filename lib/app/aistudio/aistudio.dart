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
                              ListTile(title: const Text('Entity'), onTap: () => _onCatalogTapped('Entity')),
                              ListTile(title: const Text('Field'), onTap: () => _onCatalogTapped('Field')),
                              ListTile(title: const Text('Relation'), onTap: () => _onCatalogTapped('Relation')),
                              ListTile(title: const Text('Action'), onTap: () => _onCatalogTapped('Action')),
                              ListTile(title: const Text('Function'), onTap: () => _onCatalogTapped('Function')),
                            ],
                          ),
                          ListView(
                            children: [
                              ListTile(title: const Text('Host'), onTap: () => _onCatalogTapped('Host')),
                              ListTile(title: const Text('Body'), onTap: () => _onCatalogTapped('Body')),
                              ListTile(title: const Text('Template'), onTap: () => _onCatalogTapped('Template')),
                              ListTile(title: const Text('Type'), onTap: () => _onCatalogTapped('Type')),
                              ListTile(title: const Text('Widget'), onTap: () => _onCatalogTapped('Widget')),
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
