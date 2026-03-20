import 'package:flutter/material.dart';
import 'package:genrp/core/ux/a/a.dart';
import 'package:genrp/core/ux/m/m.dart';
import 'package:genrp/core/ux/theme.dart';
import 'package:genrp/meta.dart';

class WorkSpaceApp extends StatelessWidget {
  const WorkSpaceApp({
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
      title: 'WorkSpace',
      theme: UxTheme.lightTheme(),
      darkTheme: UxTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: WorkSpaceHome(
        initialRoutePath: initialRoutePath,
        autoSignIn: autoSignIn,
      ),
    );
  }
}

class WorkSpaceHome extends StatefulWidget {
  const WorkSpaceHome({
    super.key,
    this.initialRoutePath,
    this.autoSignIn = false,
  });

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  State<WorkSpaceHome> createState() => _WorkSpaceHomeState();
}

class _WorkSpaceHomeState extends State<WorkSpaceHome> {
  late final UxWorkspaceSession _session;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _session = UxWorkspaceSession(
      pilot: UxPilot(v: '${AppMeta.v}', f: '${AppMeta.f}', c: '1'),
      initialRoutePath: widget.initialRoutePath,
      currentUri: Uri.base,
    );
    _usernameController = TextEditingController(text: UxMockAuth.username);
    _passwordController = TextEditingController(text: UxMockAuth.password);
    if (widget.autoSignIn) {
      _session.signInWithMockCredentials();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _session,
      builder: (BuildContext context, Widget? child) {
        return switch (_session.stage) {
          UxWorkspaceStage.login => _buildLogin(context),
          UxWorkspaceStage.loading => _buildLoading(context),
          UxWorkspaceStage.ready => _buildReady(context),
        };
      },
    );
  }

  Future<void> _signInWithControllers() {
    return _session.signIn(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
  }

  Widget _buildLogin(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('WorkSpace Login')),
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
                if (_session.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    _session.errorMessage!,
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

  Widget _buildLoading(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading workspace...'),
          ],
        ),
      ),
    );
  }

  Widget _buildReady(BuildContext context) {
    final route = _session.route;
    final spec = _session.spec;
    final presets = _session.presets;
    final selectedIndex = presets.indexWhere(
      (UxRouteSpec preset) => preset.path == route.path,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkSpace'),
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
              _session.openRoute(presets[index].path);
            },
            destinations: presets
                .map<NavigationRailDestination>(
                  (UxRouteSpec preset) => NavigationRailDestination(
                    icon: const Icon(Icons.folder_open_outlined),
                    selectedIcon: const Icon(Icons.folder_open),
                    label: Text(preset.title),
                  ),
                )
                .toList(growable: false),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Container(
              color: UxTheme.workspaceColor(context),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    decoration: UxTheme.softPanelDecoration(context),
                    padding: UxTheme.panelPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          spec.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          spec.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: UxRuntimeRenderer.buildPaper(
                      spec: spec.paper,
                      autopilot: _session.pilot,
                      optionalId: spec.optionalId,
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
            Text('WorkSpace:${AppMeta.workspace}/${AppMeta.f}/${AppMeta.v}'),
          ],
        ),
      ),
    );
  }
}
