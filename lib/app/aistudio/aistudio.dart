import 'package:flutter/material.dart';
import 'package:genrp/app/aistudio/aistudio_specs.dart';
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

class AIStudioApp extends StatelessWidget {
  const AIStudioApp({
    super.key,
    this.initialRoutePath,
    this.autoSignIn = false,
  });

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AIStudioSpecs.title,
      theme: UxTheme.lightTheme(),
      darkTheme: UxTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: AIStudioHome(
        initialRoutePath: initialRoutePath,
        autoSignIn: autoSignIn,
      ),
    );
  }
}

class AIStudioHome extends StatefulWidget {
  const AIStudioHome({
    super.key,
    this.initialRoutePath,
    this.autoSignIn = false,
  });

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  State<AIStudioHome> createState() => _AIStudioHomeState();
}

enum _AIStudioStage { login, loading, ready }

class _AIStudioCatalog {
  const _AIStudioCatalog({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  List<Object?> get row => <Object?>[name, subtitle];
}

class _AIStudioRow {
  const _AIStudioRow({
    required this.id,
    required this.name,
    required this.status,
    required this.owner,
    required this.notes,
  });

  final int id;
  final String name;
  final String status;
  final String owner;
  final String notes;

  List<Object?> get cells => <Object?>[id, name, status, owner];
}

class _AIStudioHomeState extends State<AIStudioHome> {
  static const List<String> _minorLabels = <String>['Core', 'Flow'];
  static const List<String> _majorLabels = <String>['List', 'Editor', 'Split'];
  static const List<String> _rowColumns = <String>[
    'ID',
    'Name',
    'Status',
    'Owner',
  ];

  late final Autopilot _pilot;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  _AIStudioStage _stage = _AIStudioStage.login;
  String? _errorMessage;
  List<AIStudioSection> _presets = const <AIStudioSection>[];
  String? _routePath;
  int _minorTabIndex = 0;
  int _majorTabIndex = 1;
  String _selectedCatalog = 'Host';
  int _selectedRowIndex = 0;

  CopilotRoute get _route =>
      _pilot.currentRoute ??
      AIStudioSpecs.initialRoute(
        explicitPath: widget.initialRoutePath,
        currentUri: Uri.base,
        presets: _presets,
      );

  AIStudioSection get _section =>
      AIStudioSpecs.resolve(_route, presets: _presets);

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
      _AIStudioStage.login => _buildLogin(context),
      _AIStudioStage.loading => _buildLoading(),
      _AIStudioStage.ready => _buildReady(context),
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
        _stage = _AIStudioStage.loading;
      });
    }

    await Future<void>.delayed(Duration.zero);
    final presets = AIStudioSpecs.presets();
    final route = AIStudioSpecs.initialRoute(
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
      _stage = _AIStudioStage.ready;
    });
    return true;
  }

  void _openRoute(String route) {
    if (_stage != _AIStudioStage.ready || _routePath == route) {
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
    final defaultCatalog = route.pageSpecId == AIStudioSpecs.paperOneSpecId
        ? 'UX Action'
        : 'Host';
    _selectedCatalog = defaultCatalog;
    _minorTabIndex = _tabIndexForCatalog(defaultCatalog);
    _majorTabIndex = 1;
    _selectedRowIndex = 0;
  }

  Widget _buildLogin(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AIStudio Login')),
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
            Text('Loading aistudio...'),
          ],
        ),
      ),
    );
  }

  Widget _buildReady(BuildContext context) {
    final route = _route;
    final section = _section;
    final presets = _presets;
    final catalogs = _catalogsForSection(section);
    final selectedCatalog = catalogs.firstWhere(
      (_AIStudioCatalog catalog) => catalog.name == _selectedCatalog,
      orElse: () => catalogs.first,
    );
    final rows = _rowsForCatalog(selectedCatalog.name, route);
    final selectedRowIndex = _resolveIndex(
      requestedIndex: _selectedRowIndex,
      length: rows.length,
    );
    final selectedRow = selectedRowIndex == null
        ? null
        : rows[selectedRowIndex];
    final selectedIndex = presets.indexWhere(
      (AIStudioSection preset) => preset.path == route.path,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIStudio'),
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
                  (AIStudioSection preset) => NavigationRailDestination(
                    icon: const Icon(Icons.design_services_outlined),
                    selectedIcon: const Icon(Icons.design_services),
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
                            final minorPanel = _buildMinorPanel(
                              section: section,
                            );
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
            Text('AIStudio:${AIStudioSpecs.appMeta}/${AppMeta.f}/${AppMeta.v}'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required AIStudioSection section,
    required CopilotRoute route,
    required _AIStudioCatalog selectedCatalog,
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
            i: 40101,
            autopilot: _pilot,
            s: 30,
            leftChildren: chips
                .map<Widget>((String chip) => Chip(label: Text(chip)))
                .toList(growable: false),
            rightChildren: <Widget>[
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.rule_folder_outlined),
                label: const Text('Validate'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Draft'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'AIStudio stays editor-first. Live preview from raw Ux* mutations is intentionally avoided in favor of a hard-coded authoring shell.',
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

  Widget _buildMinorPanel({required AIStudioSection section}) {
    return UwTab(
      i: 40110,
      autopilot: _pilot,
      s: 10,
      activeIndex: _minorTabIndex,
      labels: _minorLabels,
      onChanged: (int index) {
        final catalogs = _catalogsForTab(section: section, tabIndex: index);
        setState(() {
          _minorTabIndex = index;
          if (!catalogs.any(
            (_AIStudioCatalog catalog) => catalog.name == _selectedCatalog,
          )) {
            _selectedCatalog = catalogs.first.name;
            _selectedRowIndex = 0;
          }
        });
      },
      children: <Widget>[
        _buildCatalogList(
          title: 'UX Core',
          catalogs: _catalogsForTab(section: section, tabIndex: 0),
        ),
        _buildCatalogList(
          title: 'UX Flow',
          catalogs: _catalogsForTab(section: section, tabIndex: 1),
        ),
      ],
    );
  }

  Widget _buildCatalogList({
    required String title,
    required List<_AIStudioCatalog> catalogs,
  }) {
    final selectedIndex = catalogs.indexWhere(
      (_AIStudioCatalog catalog) => catalog.name == _selectedCatalog,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        UwToolbar(
          i: 40111,
          autopilot: _pilot,
          s: 20,
          leftChildren: <Widget>[Text(title)],
          rightChildren: const <Widget>[Chip(label: Text('2 tabs'))],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: UwCollection(
            i: 40112,
            autopilot: _pilot,
            s: 1,
            p: title,
            rows: catalogs
                .map<List<Object?>>((_AIStudioCatalog catalog) => catalog.row)
                .toList(growable: false),
            selectedIndex: selectedIndex < 0 ? null : selectedIndex,
            onSelectIndex: (int index) {
              setState(() {
                _selectedCatalog = catalogs[index].name;
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
    required AIStudioSection section,
    required _AIStudioCatalog selectedCatalog,
    required List<_AIStudioRow> rows,
    required int? selectedRowIndex,
    required _AIStudioRow? selectedRow,
  }) {
    return UwTab(
      i: 40120,
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
    required List<_AIStudioRow> rows,
    required int? selectedRowIndex,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        UwToolbar(
          i: 40121,
          autopilot: _pilot,
          s: 20,
          leftChildren: <Widget>[Text(title)],
          rightChildren: <Widget>[
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('New'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: UwCollection(
            i: 40122,
            autopilot: _pilot,
            s: 3,
            p: title,
            columns: _rowColumns,
            rows: rows
                .map<List<Object?>>((_AIStudioRow row) => row.cells)
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
    required AIStudioSection section,
    required _AIStudioCatalog selectedCatalog,
    required List<_AIStudioRow> rows,
    required int? selectedRowIndex,
    required _AIStudioRow? selectedRow,
    required int leftFlex,
    required int rightFlex,
  }) {
    final list = _buildRowList(
      title: '${selectedCatalog.name} Rows',
      rows: rows,
      selectedRowIndex: selectedRowIndex,
    );
    final detail = _buildEditorStack(
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

  Widget _buildEditorStack({
    required BuildContext context,
    required CopilotRoute route,
    required AIStudioSection section,
    required _AIStudioCatalog selectedCatalog,
    required _AIStudioRow? selectedRow,
  }) {
    final properties = _propertiesForRow(
      route: route,
      section: section,
      selectedCatalog: selectedCatalog,
      selectedRow: selectedRow,
    );
    final selectedName = selectedRow?.name ?? 'No Selection';
    return Column(
      children: <Widget>[
        Expanded(
          child: UwCard(
            i: 40130,
            autopilot: _pilot,
            title: 'Inspector',
            child: SingleChildScrollView(
              child: UwPList(
                i: 40131,
                autopilot: _pilot,
                properties: properties,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: UwCard(
            i: 40132,
            autopilot: _pilot,
            title: 'Editor',
            child: SingleChildScrollView(
              child: UwFrom(
                i: 40133,
                autopilot: _pilot,
                p: '$selectedName Form',
                footer: Wrap(
                  spacing: 8,
                  children: <Widget>[
                    FilledButton(onPressed: () {}, child: const Text('Save')),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Duplicate'),
                    ),
                  ],
                ),
                children: _formFields(
                  selectedCatalog: selectedCatalog,
                  selectedRow: selectedRow,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<_AIStudioCatalog> _catalogsForSection(AIStudioSection section) {
    return <_AIStudioCatalog>[
      ..._catalogsForTab(section: section, tabIndex: 0),
      ..._catalogsForTab(section: section, tabIndex: 1),
    ];
  }

  List<_AIStudioCatalog> _catalogsForTab({
    required AIStudioSection section,
    required int tabIndex,
  }) {
    final reviewMode = section.route.pageSpecId == AIStudioSpecs.paperOneSpecId;
    if (tabIndex == 0) {
      return <_AIStudioCatalog>[
        _AIStudioCatalog(
          name: 'Host',
          subtitle: reviewMode
              ? 'Review host surfaces and release titles'
              : 'App-level entry hosts and route owners',
        ),
        const _AIStudioCatalog(
          name: 'Body',
          subtitle: 'Paper/body structure and layout identity',
        ),
        const _AIStudioCatalog(
          name: 'Template',
          subtitle: 'Reusable template surfaces and composition',
        ),
        const _AIStudioCatalog(
          name: 'Type',
          subtitle: 'Typed node families and render contracts',
        ),
        const _AIStudioCatalog(
          name: 'Widget',
          subtitle: 'Widget registrations and UX view mapping',
        ),
      ];
    }
    return <_AIStudioCatalog>[
      const _AIStudioCatalog(
        name: 'UX Action',
        subtitle: 'Actions, handlers, and tool commands',
      ),
      const _AIStudioCatalog(
        name: 'FieldBinding',
        subtitle: 'Bindings between fields, slots, and paths',
      ),
      const _AIStudioCatalog(
        name: 'Body Spec Node',
        subtitle: 'Tree nodes, nesting, and local behavior',
      ),
    ];
  }

  List<_AIStudioRow> _rowsForCatalog(String catalog, CopilotRoute route) {
    final seed = int.tryParse(route.optionalId ?? '42') ?? 42;
    switch (catalog) {
      case 'Host':
        return <_AIStudioRow>[
          _AIStudioRow(
            id: seed,
            name: 'main_host',
            status: 'Ready',
            owner: 'Mia',
            notes: 'Primary shell host for AIStudio entry.',
          ),
          _AIStudioRow(
            id: seed + 1,
            name: 'publish_host',
            status: 'Draft',
            owner: 'Ethan',
            notes: 'Release review host for publish checks.',
          ),
        ];
      case 'Body':
        return <_AIStudioRow>[
          _AIStudioRow(
            id: seed + 10,
            name: 'ux_catalog_body',
            status: 'Ready',
            owner: 'Mia',
            notes: 'Catalog browser body for left-to-right authoring.',
          ),
          _AIStudioRow(
            id: seed + 11,
            name: 'ux_editor_body',
            status: 'Review',
            owner: 'Ethan',
            notes: 'Editor body for row detail and bindings.',
          ),
        ];
      case 'Template':
        return <_AIStudioRow>[
          _AIStudioRow(
            id: seed + 20,
            name: 'tcrud_studio',
            status: 'Ready',
            owner: 'Mia',
            notes: 'CRUD-oriented studio template for authoring.',
          ),
          _AIStudioRow(
            id: seed + 21,
            name: 'treview_lane',
            status: 'Draft',
            owner: 'Ethan',
            notes: 'Review lane template for publish prep.',
          ),
        ];
      case 'Type':
        return <_AIStudioRow>[
          _AIStudioRow(
            id: seed + 30,
            name: 'column',
            status: 'Stable',
            owner: 'Mia',
            notes: 'Vertical composition type.',
          ),
          _AIStudioRow(
            id: seed + 31,
            name: 'toolbar',
            status: 'Stable',
            owner: 'Ethan',
            notes: 'Toolbar type for command chrome.',
          ),
        ];
      case 'Widget':
        return <_AIStudioRow>[
          _AIStudioRow(
            id: seed + 40,
            name: 'toolbar',
            status: 'Ready',
            owner: 'Mia',
            notes: 'Shared toolbar widget used in authoring shells.',
          ),
          _AIStudioRow(
            id: seed + 41,
            name: 'plist',
            status: 'Ready',
            owner: 'Ethan',
            notes: 'Property list widget for inspectors.',
          ),
        ];
      case 'UX Action':
        return <_AIStudioRow>[
          _AIStudioRow(
            id: seed + 50,
            name: 'publish_spec',
            status: 'Draft',
            owner: 'Mia',
            notes: 'Publish current draft with validation.',
          ),
          _AIStudioRow(
            id: seed + 51,
            name: 'clone_spec',
            status: 'Ready',
            owner: 'Ethan',
            notes: 'Duplicate selected UX row into a draft.',
          ),
        ];
      case 'FieldBinding':
        return <_AIStudioRow>[
          _AIStudioRow(
            id: seed + 60,
            name: 'title -> paper.title',
            status: 'Ready',
            owner: 'Mia',
            notes: 'Maps title form input to paper title.',
          ),
          _AIStudioRow(
            id: seed + 61,
            name: 'owner -> template.summary',
            status: 'Review',
            owner: 'Ethan',
            notes: 'Maps owner field into summary slot.',
          ),
        ];
      case 'Body Spec Node':
      default:
        return <_AIStudioRow>[
          _AIStudioRow(
            id: seed + 70,
            name: 'body.root.column',
            status: 'Ready',
            owner: 'Mia',
            notes: 'Root column node for AIStudio page.',
          ),
          _AIStudioRow(
            id: seed + 71,
            name: 'detail.toolbar',
            status: 'Draft',
            owner: 'Ethan',
            notes: 'Toolbar node for detail editor actions.',
          ),
        ];
    }
  }

  Map<String, Object?> _propertiesForRow({
    required CopilotRoute route,
    required AIStudioSection section,
    required _AIStudioCatalog selectedCatalog,
    required _AIStudioRow? selectedRow,
  }) {
    return <String, Object?>{
      'app': AIStudioSpecs.title,
      'surface': section.title,
      'catalog': selectedCatalog.name,
      'route': route.path,
      'row_name': selectedRow?.name ?? '',
      'row_status': selectedRow?.status ?? '',
      'owner': selectedRow?.owner ?? '',
      'back_stack': 'disabled',
      'web_support': 'disabled',
      'preview_mode': 'hard-coded editor shell',
      'notes': selectedRow?.notes ?? 'Select a row to inspect details.',
    };
  }

  List<Widget> _formFields({
    required _AIStudioCatalog selectedCatalog,
    required _AIStudioRow? selectedRow,
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
        initialValue: selectedRow?.owner ?? 'admin',
        decoration: const InputDecoration(labelText: 'Owner'),
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

  int _tabIndexForCatalog(String catalog) {
    switch (catalog) {
      case 'Host':
      case 'Body':
      case 'Template':
      case 'Type':
      case 'Widget':
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
