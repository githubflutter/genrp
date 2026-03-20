import 'package:flutter/material.dart';
import 'package:genrp/app/aicodex/aicodex_specs.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/uwidget/uwcard.dart';
import 'package:genrp/core/ux/uwidget/uwcollection.dart';
import 'package:genrp/core/ux/uwidget/uwfrom.dart';
import 'package:genrp/core/ux/uwidget/uwplist.dart';
import 'package:genrp/core/ux/uwidget/uwtab.dart';
import 'package:genrp/core/ux/uwidget/uwtoolbar.dart';
import 'package:genrp/meta.dart';

class AICodexApp extends StatelessWidget {
  const AICodexApp({super.key, this.initialRoutePath, this.autoSignIn = false});

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AICodexSpecs.title,
      theme: UxTheme.lightTheme(),
      darkTheme: UxTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: AICodexHome(
        initialRoutePath: initialRoutePath,
        autoSignIn: autoSignIn,
      ),
    );
  }
}

class AICodexHome extends StatefulWidget {
  const AICodexHome({
    super.key,
    this.initialRoutePath,
    this.autoSignIn = false,
  });

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  State<AICodexHome> createState() => _AICodexHomeState();
}

enum _AICodexStage { login, loading, ready }

class _AICodexCatalog {
  const _AICodexCatalog({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  List<Object?> get row => <Object?>[name, subtitle];
}

class _AICodexRow {
  const _AICodexRow({
    required this.id,
    required this.name,
    required this.status,
    required this.scope,
    required this.notes,
  });

  final int id;
  final String name;
  final String status;
  final String scope;
  final String notes;

  List<Object?> get cells => <Object?>[id, name, status, scope];
}

class _AICodexHomeState extends State<AICodexHome> {
  static const List<String> _minorLabels = <String>['Source', 'Target'];
  static const List<String> _majorLabels = <String>['List', 'Editor', 'Split'];
  static const List<String> _rowColumns = <String>[
    'ID',
    'Name',
    'Status',
    'Scope',
  ];

  late final Autopilot _pilot;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  _AICodexStage _stage = _AICodexStage.login;
  String? _errorMessage;
  List<AICodexSection> _presets = const <AICodexSection>[];
  String? _routePath;
  int _minorTabIndex = 0;
  int _majorTabIndex = 1;
  String _selectedModelType = 'Entity';
  int _selectedRowIndex = 0;

  CopilotRoute get _route =>
      _pilot.currentRoute ??
      AICodexSpecs.initialRoute(
        explicitPath: widget.initialRoutePath,
        currentUri: Uri.base,
        presets: _presets,
      );

  AICodexSection get _section =>
      AICodexSpecs.resolve(route: _route, presets: _presets);

  @override
  void initState() {
    super.initState();
    _pilot = Autopilot(v: '${AppMeta.v}', f: '${AppMeta.f}', c: '1');
    _usernameController = TextEditingController(text: Autopilot.mockUsername);
    _passwordController = TextEditingController(text: Autopilot.mockPassword);
    if (widget.autoSignIn) {
      _signInWithMockCredentials();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pilot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _AICodexStage.login => _buildLogin(context),
      _AICodexStage.loading => _buildLoading(),
      _AICodexStage.ready => _buildReady(context),
    };
  }

  Future<void> _signInWithControllers() {
    return _signIn(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<bool> _signInWithMockCredentials() {
    return _signIn(
      username: Autopilot.mockUsername,
      password: Autopilot.mockPassword,
    );
  }

  Future<bool> _signIn({
    required String username,
    required String password,
  }) async {
    final applied = _pilot.applyMockAuth(
      username: username,
      password: password,
      notify: false,
    );
    if (!applied) {
      if (!mounted) return false;
      setState(() {
        _errorMessage = 'Invalid credentials. Use admin / admin.';
      });
      return false;
    }

    if (mounted) {
      setState(() {
        _errorMessage = null;
        _stage = _AICodexStage.loading;
      });
    }

    await Future<void>.delayed(Duration.zero);
    final presets = AICodexSpecs.presets();
    final route = AICodexSpecs.initialRoute(
      explicitPath: widget.initialRoutePath,
      currentUri: Uri.base,
      presets: presets,
    );
    _pilot.navigate(route.path, notify: false);

    if (!mounted) return true;
    setState(() {
      _presets = presets;
      _routePath = route.path;
      _applySectionDefaults(route);
      _stage = _AICodexStage.ready;
    });
    return true;
  }

  void _openRoute(String route) {
    if (_stage != _AICodexStage.ready || _routePath == route) {
      return;
    }
    _pilot.navigate(route, notify: false);
    final nextRoute = CopilotRoute.parse(route);
    setState(() {
      _routePath = route;
      _applySectionDefaults(nextRoute);
    });
  }

  void _applySectionDefaults(CopilotRoute route) {
    final defaultType = route.pageSpecId == AICodexSpecs.paperOneSpecId
        ? 'Function'
        : 'Entity';
    _selectedModelType = defaultType;
    _minorTabIndex = _tabIndexForModel(defaultType);
    _majorTabIndex = 1;
    _selectedRowIndex = 0;
  }

  Widget _buildLogin(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AICodex Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Sign In',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Mock credential: admin / admin',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                if (_errorMessage != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _signInWithControllers,
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading aicodex...'),
          ],
        ),
      ),
    );
  }

  Widget _buildReady(BuildContext context) {
    final route = _route;
    final section = _section;
    final presets = _presets;
    final catalogs = _catalogsForSection();
    final selectedCatalog = catalogs.firstWhere(
      (_AICodexCatalog catalog) => catalog.name == _selectedModelType,
      orElse: () => catalogs.first,
    );
    final rows = _rowsForModel(selectedCatalog.name, route);
    final selectedRowIndex = _resolveIndex(
      requestedIndex: _selectedRowIndex,
      length: rows.length,
    );
    final selectedRow = selectedRowIndex == null
        ? null
        : rows[selectedRowIndex];
    final selectedIndex = presets.indexWhere(
      (AICodexSection preset) => preset.path == route.path,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('AICodex'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(child: Text(route.path)),
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (int index) {
              _openRoute(presets[index].path);
            },
            destinations: presets
                .map<NavigationRailDestination>(
                  (AICodexSection preset) => NavigationRailDestination(
                    icon: const Icon(Icons.account_tree_outlined),
                    selectedIcon: const Icon(Icons.account_tree),
                    label: Text(preset.title),
                  ),
                )
                .toList(growable: false),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Container(
              color: UxTheme.appChromeColor(context),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildHeader(
                    context: context,
                    section: section,
                    route: route,
                    selectedCatalog: selectedCatalog,
                    rowCount: rows.length,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final stacked = constraints.maxWidth < 1100;
                            final minorPanel = _buildMinorPanel();
                            final majorPanel = _buildMajorPanel(
                              context: context,
                              route: route,
                              section: section,
                              selectedCatalog: selectedCatalog,
                              rows: rows,
                              selectedRowIndex: selectedRowIndex,
                              selectedRow: selectedRow,
                            );
                            if (stacked) {
                              return Column(
                                children: <Widget>[
                                  SizedBox(height: 260, child: minorPanel),
                                  const SizedBox(height: 16),
                                  Expanded(child: majorPanel),
                                ],
                              );
                            }
                            return Row(
                              children: <Widget>[
                                SizedBox(width: 280, child: minorPanel),
                                const SizedBox(width: 16),
                                Expanded(child: majorPanel),
                              ],
                            );
                          },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            Text('Route: ${route.path}'),
            const Spacer(),
            Text('AICodex:${AICodexSpecs.appMeta}/${AppMeta.f}/${AppMeta.v}'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required AICodexSection section,
    required CopilotRoute route,
    required _AICodexCatalog selectedCatalog,
    required int rowCount,
  }) {
    final chips = <String>[
      'Catalog: ${selectedCatalog.name}',
      'Rows: $rowCount',
      'Back Stack: Off',
      'Web Support: Off',
    ];
    return Container(
      decoration: UxTheme.softPanelDecoration(context),
      padding: UxTheme.panelPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(section.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(section.subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          UwToolbar(
            i: 30101,
            autopilot: _pilot,
            s: 30,
            leftChildren: chips
                .map<Widget>((String chip) => Chip(label: Text(chip)))
                .toList(growable: false),
            rightChildren: <Widget>[
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.data_object_outlined),
                label: const Text('Preview DDL'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'AICodex stays admin-first. Schema, function, and script work run inside a hard-coded master-detail shell instead of a generic live UX preview.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Current route: ${route.path}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildMinorPanel() {
    return UwTab(
      i: 30110,
      autopilot: _pilot,
      s: 10,
      activeIndex: _minorTabIndex,
      labels: _minorLabels,
      onChanged: (int index) {
        final catalogs = _catalogsForTab(index);
        setState(() {
          _minorTabIndex = index;
          if (!catalogs.any(
            (_AICodexCatalog catalog) => catalog.name == _selectedModelType,
          )) {
            _selectedModelType = catalogs.first.name;
            _selectedRowIndex = 0;
          }
        });
      },
      children: <Widget>[
        _buildCatalogList(title: 'Schema Source', catalogs: _catalogsForTab(0)),
        _buildCatalogList(title: 'Schema Target', catalogs: _catalogsForTab(1)),
      ],
    );
  }

  Widget _buildCatalogList({
    required String title,
    required List<_AICodexCatalog> catalogs,
  }) {
    final selectedIndex = catalogs.indexWhere(
      (_AICodexCatalog catalog) => catalog.name == _selectedModelType,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        UwToolbar(
          i: 30111,
          autopilot: _pilot,
          s: 20,
          leftChildren: <Widget>[Text(title)],
          rightChildren: const <Widget>[Chip(label: Text('2 tabs'))],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: UwCollection(
            i: 30112,
            autopilot: _pilot,
            s: 1,
            p: title,
            rows: catalogs
                .map<List<Object?>>((_AICodexCatalog catalog) => catalog.row)
                .toList(growable: false),
            selectedIndex: selectedIndex < 0 ? null : selectedIndex,
            onSelectIndex: (int index) {
              setState(() {
                _selectedModelType = catalogs[index].name;
                _selectedRowIndex = 0;
                _majorTabIndex = 1;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMajorPanel({
    required BuildContext context,
    required CopilotRoute route,
    required AICodexSection section,
    required _AICodexCatalog selectedCatalog,
    required List<_AICodexRow> rows,
    required int? selectedRowIndex,
    required _AICodexRow? selectedRow,
  }) {
    return UwTab(
      i: 30120,
      autopilot: _pilot,
      s: 10,
      activeIndex: _majorTabIndex,
      labels: _majorLabels,
      onChanged: (int index) {
        setState(() {
          _majorTabIndex = index;
        });
      },
      children: <Widget>[
        _buildRowList(
          title: '${selectedCatalog.name} Rows',
          rows: rows,
          selectedRowIndex: selectedRowIndex,
        ),
        _buildEditorLayout(
          context: context,
          route: route,
          section: section,
          selectedCatalog: selectedCatalog,
          rows: rows,
          selectedRowIndex: selectedRowIndex,
          selectedRow: selectedRow,
          leftFlex: 3,
          rightFlex: 2,
        ),
        _buildEditorLayout(
          context: context,
          route: route,
          section: section,
          selectedCatalog: selectedCatalog,
          rows: rows,
          selectedRowIndex: selectedRowIndex,
          selectedRow: selectedRow,
          leftFlex: 1,
          rightFlex: 1,
        ),
      ],
    );
  }

  Widget _buildRowList({
    required String title,
    required List<_AICodexRow> rows,
    required int? selectedRowIndex,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        UwToolbar(
          i: 30121,
          autopilot: _pilot,
          s: 20,
          leftChildren: <Widget>[Text(title)],
          rightChildren: <Widget>[
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.addchart_outlined),
              label: const Text('New'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: UwCollection(
            i: 30122,
            autopilot: _pilot,
            s: 3,
            p: title,
            columns: _rowColumns,
            rows: rows
                .map<List<Object?>>((_AICodexRow row) => row.cells)
                .toList(growable: false),
            selectedIndex: selectedRowIndex,
            onSelectIndex: (int index) {
              setState(() {
                _selectedRowIndex = index;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditorLayout({
    required BuildContext context,
    required CopilotRoute route,
    required AICodexSection section,
    required _AICodexCatalog selectedCatalog,
    required List<_AICodexRow> rows,
    required int? selectedRowIndex,
    required _AICodexRow? selectedRow,
    required int leftFlex,
    required int rightFlex,
  }) {
    final list = _buildRowList(
      title: '${selectedCatalog.name} Rows',
      rows: rows,
      selectedRowIndex: selectedRowIndex,
    );
    final detail = _buildDetailStack(
      context: context,
      route: route,
      section: section,
      selectedCatalog: selectedCatalog,
      selectedRow: selectedRow,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 920) {
          return Column(
            children: <Widget>[
              Expanded(child: list),
              const SizedBox(height: 16),
              Expanded(child: detail),
            ],
          );
        }
        return Row(
          children: <Widget>[
            Expanded(flex: leftFlex, child: list),
            const SizedBox(width: 16),
            Expanded(flex: rightFlex, child: detail),
          ],
        );
      },
    );
  }

  Widget _buildDetailStack({
    required BuildContext context,
    required CopilotRoute route,
    required AICodexSection section,
    required _AICodexCatalog selectedCatalog,
    required _AICodexRow? selectedRow,
  }) {
    final properties = _propertiesForRow(
      route: route,
      section: section,
      selectedCatalog: selectedCatalog,
      selectedRow: selectedRow,
    );
    final sqlPreview = _sqlPreview(
      selectedCatalog: selectedCatalog,
      selectedRow: selectedRow,
    );
    return Column(
      children: <Widget>[
        Expanded(
          child: UwCard(
            i: 30130,
            autopilot: _pilot,
            title: 'Inspector',
            child: SingleChildScrollView(
              child: UwPList(
                i: 30131,
                autopilot: _pilot,
                properties: properties,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: UwCard(
            i: 30132,
            autopilot: _pilot,
            title: 'Editor + DDL',
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  UwFrom(
                    i: 30133,
                    autopilot: _pilot,
                    p: '${selectedCatalog.name} Form',
                    footer: Wrap(
                      spacing: 8,
                      children: <Widget>[
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Save'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Generate'),
                        ),
                      ],
                    ),
                    children: _formFields(
                      selectedCatalog: selectedCatalog,
                      selectedRow: selectedRow,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DDL / Function Preview',
                    style: UxTheme.titleStyle(context),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: UxTheme.softPanelDecoration(context),
                    padding: UxTheme.panelPadding,
                    child: SelectableText(
                      sqlPreview,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<_AICodexCatalog> _catalogsForSection() {
    return <_AICodexCatalog>[..._catalogsForTab(0), ..._catalogsForTab(1)];
  }

  List<_AICodexCatalog> _catalogsForTab(int tabIndex) {
    if (tabIndex == 0) {
      return const <_AICodexCatalog>[
        _AICodexCatalog(
          name: 'Entity',
          subtitle: 'App-facing entity definitions',
        ),
        _AICodexCatalog(
          name: 'Field',
          subtitle: 'Business field definitions and labels',
        ),
        _AICodexCatalog(
          name: 'Relation',
          subtitle: 'Entity relation maps and ownership',
        ),
        _AICodexCatalog(
          name: 'Function',
          subtitle: 'Function definitions and contracts',
        ),
        _AICodexCatalog(
          name: 'Parameter',
          subtitle: 'Function parameter rows and defaults',
        ),
      ];
    }
    return const <_AICodexCatalog>[
      _AICodexCatalog(
        name: 'Table',
        subtitle: 'Physical table generation targets',
      ),
      _AICodexCatalog(name: 'Column', subtitle: 'Generated column definitions'),
      _AICodexCatalog(
        name: 'System',
        subtitle: 'Base system rows and metadata',
      ),
      _AICodexCatalog(
        name: 'User',
        subtitle: 'Base user rows and auth ownership',
      ),
    ];
  }

  List<_AICodexRow> _rowsForModel(String modelType, CopilotRoute route) {
    final seed = int.tryParse(route.optionalId ?? '42') ?? 42;
    switch (modelType) {
      case 'Entity':
        return <_AICodexRow>[
          _AICodexRow(
            id: seed,
            name: 'usr',
            status: 'Ready',
            scope: 'foundation',
            notes: 'Primary runtime user entity.',
          ),
          _AICodexRow(
            id: seed + 1,
            name: 'project',
            status: 'Draft',
            scope: 'business',
            notes: 'Project entity for workspace ownership.',
          ),
        ];
      case 'Field':
        return <_AICodexRow>[
          _AICodexRow(
            id: seed + 10,
            name: 'usr.name',
            status: 'Ready',
            scope: 'foundation',
            notes: 'Display name field for users.',
          ),
          _AICodexRow(
            id: seed + 11,
            name: 'project.status',
            status: 'Review',
            scope: 'business',
            notes: 'Lifecycle status field for project rows.',
          ),
        ];
      case 'Relation':
        return <_AICodexRow>[
          _AICodexRow(
            id: seed + 20,
            name: 'project -> usr',
            status: 'Ready',
            scope: 'business',
            notes: 'Project ownership relation.',
          ),
          _AICodexRow(
            id: seed + 21,
            name: 'task -> project',
            status: 'Draft',
            scope: 'business',
            notes: 'Task linkage to parent project.',
          ),
        ];
      case 'Function':
        return <_AICodexRow>[
          _AICodexRow(
            id: seed + 30,
            name: 'copilot_sync',
            status: 'Ready',
            scope: 'router',
            notes: 'Envelope function for copilot work.',
          ),
          _AICodexRow(
            id: seed + 31,
            name: 'catalog_seed',
            status: 'Draft',
            scope: 'admin',
            notes: 'Seed function for admin-side catalogs.',
          ),
        ];
      case 'Parameter':
        return <_AICodexRow>[
          _AICodexRow(
            id: seed + 40,
            name: 'p_payload',
            status: 'Ready',
            scope: 'router',
            notes: 'JSON payload parameter.',
          ),
          _AICodexRow(
            id: seed + 41,
            name: 'p_usr_id',
            status: 'Review',
            scope: 'security',
            notes: 'Current user id parameter.',
          ),
        ];
      case 'Table':
        return <_AICodexRow>[
          _AICodexRow(
            id: seed + 50,
            name: 't_usr',
            status: 'Ready',
            scope: 'foundation',
            notes: 'User table target.',
          ),
          _AICodexRow(
            id: seed + 51,
            name: 't_project',
            status: 'Draft',
            scope: 'business',
            notes: 'Project table target.',
          ),
        ];
      case 'Column':
        return <_AICodexRow>[
          _AICodexRow(
            id: seed + 60,
            name: 't_usr.n',
            status: 'Ready',
            scope: 'foundation',
            notes: 'Name column for user table.',
          ),
          _AICodexRow(
            id: seed + 61,
            name: 't_project.s',
            status: 'Review',
            scope: 'business',
            notes: 'System name column for project table.',
          ),
        ];
      case 'System':
        return <_AICodexRow>[
          _AICodexRow(
            id: 1,
            name: 'GenRP',
            status: 'Ready',
            scope: 'base',
            notes: 'Base system metadata row.',
          ),
        ];
      case 'User':
      default:
        return <_AICodexRow>[
          _AICodexRow(
            id: seed + 70,
            name: 'admin',
            status: 'Ready',
            scope: 'auth',
            notes: 'Single-user admin account for model editing.',
          ),
          _AICodexRow(
            id: seed + 71,
            name: 'operator',
            status: 'Draft',
            scope: 'auth',
            notes: 'Secondary operator identity.',
          ),
        ];
    }
  }

  Map<String, Object?> _propertiesForRow({
    required CopilotRoute route,
    required AICodexSection section,
    required _AICodexCatalog selectedCatalog,
    required _AICodexRow? selectedRow,
  }) {
    return <String, Object?>{
      'app': AICodexSpecs.title,
      'surface': section.title,
      'catalog': selectedCatalog.name,
      'route': route.path,
      'row_name': selectedRow?.name ?? '',
      'row_status': selectedRow?.status ?? '',
      'scope': selectedRow?.scope ?? '',
      'back_stack': 'disabled',
      'web_support': 'disabled',
      'notes': selectedRow?.notes ?? 'Select a row to inspect details.',
    };
  }

  List<Widget> _formFields({
    required _AICodexCatalog selectedCatalog,
    required _AICodexRow? selectedRow,
  }) {
    return <Widget>[
      TextFormField(
        initialValue: selectedRow?.name ?? '',
        decoration: InputDecoration(labelText: '${selectedCatalog.name} Name'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        initialValue: selectedRow?.status ?? 'Draft',
        decoration: const InputDecoration(labelText: 'Status'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        initialValue: selectedRow?.scope ?? 'admin',
        decoration: const InputDecoration(labelText: 'Scope'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        initialValue: selectedRow?.notes ?? '',
        minLines: 3,
        maxLines: 5,
        decoration: const InputDecoration(labelText: 'Notes'),
      ),
    ];
  }

  String _sqlPreview({
    required _AICodexCatalog selectedCatalog,
    required _AICodexRow? selectedRow,
  }) {
    final name = selectedRow?.name ?? selectedCatalog.name.toLowerCase();
    switch (selectedCatalog.name) {
      case 'Function':
      case 'Parameter':
        return '''
create or replace function $name(p_payload jsonb)
returns jsonb
language plpgsql
as \$\$
begin
  return jsonb_build_object('status', 'ok');
end;
\$\$;
''';
      default:
        return '''
create table if not exists $name (
  i int4 not null,
  n text not null,
  s text not null,
  d bigint not null,
  e int4 not null,
  primary key (i)
);
''';
    }
  }

  int _tabIndexForModel(String modelType) {
    switch (modelType) {
      case 'Entity':
      case 'Field':
      case 'Relation':
      case 'Function':
      case 'Parameter':
        return 0;
      default:
        return 1;
    }
  }

  int? _resolveIndex({required int requestedIndex, required int length}) {
    if (length <= 0) {
      return null;
    }
    if (requestedIndex < 0) {
      return 0;
    }
    if (requestedIndex >= length) {
      return length - 1;
    }
    return requestedIndex;
  }
}
