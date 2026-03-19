import 'package:flutter/material.dart';
import 'package:genrp/core/theme/genrp_theme.dart';
import 'package:genrp/core/widgets/hybrid_authoring_shell.dart';
import 'package:genrp/meta.dart';

class AIStudioApp extends StatelessWidget {
  const AIStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIStudio',
      theme: GenrpTheme.lightTheme(),
      darkTheme: GenrpTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: const AIStudioHome(),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Context', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const Text('Scope: UX/spec only'),
        const SizedBox(height: 8),
        Text('Selected catalog: $selectedCatalog'),
        const SizedBox(height: 8),
        const Text(
          'Data-model explorer and sensitive schema editing stay in AICodex.',
        ),
      ],
    );
  }

  Widget _buildMidPanel(HybridShellLayoutMode mode) {
    final toolbarHeight = GenrpTheme.toolbarHeightOf(context);
    return Container(
      color: GenrpTheme.workspaceColorOf(context),
      child: Column(
        children: [
          Container(
            height: toolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).cardTheme.color,
            width: double.infinity,
            child: Text(
              _selectedCatalog ?? 'UX/Spec Explorer',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(switch (mode) {
                HybridShellLayoutMode.single => 'Major Tab 1: Mid Panel',
                HybridShellLayoutMode.dual => 'Major Tab 2: Mid Panel',
                HybridShellLayoutMode.split => 'Major Tab 3: Mid Panel',
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(HybridShellLayoutMode mode) {
    return Container(
      color: GenrpTheme.workspaceAltColorOf(context),
      child: Center(
        child: Text(switch (mode) {
          HybridShellLayoutMode.single => 'Workspace',
          HybridShellLayoutMode.dual => 'Major Tab 2: Right Workspace',
          HybridShellLayoutMode.split => 'Major Tab 3: Right Workspace',
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AIStudio')),
      body: HybridAuthoringShell(
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
