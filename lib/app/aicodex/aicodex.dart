import 'package:flutter/material.dart';
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
  // ignore: unused_field
  int? _selectedRowId;

  void _onModelTypeTapped(String modelType) {
    setState(() {
      _selectedModelType = modelType;
      _selectedRowId = null;
    });
  }

  Widget _buildNavItem(String title) {
    final isSelected = _selectedModelType == title;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
      onTap: () => _onModelTypeTapped(title),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text(
                      'Schema Source',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  _buildNavItem('Entity'),
                  _buildNavItem('Field'),
                  _buildNavItem('Relation'),
                  _buildNavItem('Function'),
                  _buildNavItem('Parameter'),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Schema Target',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
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
