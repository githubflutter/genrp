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
  // ignore: unused_field
  int? _selectedRowId;

  void _onCatalogTapped(String catalog) {
    setState(() {
      _selectedCatalog = catalog;
      _selectedRowId = null;
    });
  }

  Widget _buildCatalogItem(String catalog) {
    final isSelected = _selectedCatalog == catalog;
    return ListTile(
      title: Text(
        catalog,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
      onTap: () => _onCatalogTapped(catalog),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'UX/Spec',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: _uxCatalogs
                          .map<Widget>(_buildCatalogItem)
                          .toList(growable: false),
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
                      _selectedCatalog ?? 'UX/Spec Explorer',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(child: Text('Master/Main Editor')),
                  ),
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
