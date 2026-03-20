import 'package:flutter/material.dart';
import 'package:genrp/app/aibook/aibook_specs.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/model/uschema/ux.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/ux/genux.dart';
import 'package:genrp/meta.dart';

class AIBookApp extends StatelessWidget {
  const AIBookApp({super.key, this.initialRoutePath, this.autoSignIn = false});

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AIBookSpecs.title,
      theme: UxTheme.lightTheme(),
      darkTheme: UxTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: AIBookHome(
        initialRoutePath: initialRoutePath,
        autoSignIn: autoSignIn,
      ),
    );
  }
}

class AIBookHome extends StatefulWidget {
  const AIBookHome({super.key, this.initialRoutePath, this.autoSignIn = false});

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  State<AIBookHome> createState() => _AIBookHomeState();
}

enum _AIBookStage { login, loading, ready }

class _AIBookHomeState extends State<AIBookHome> {
  late final Autopilot _pilot;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  _AIBookStage _stage = _AIBookStage.login;
  String? _errorMessage;
  List<UxRouteSpec> _presets = const <UxRouteSpec>[];
  String? _routePath;

  CopilotRoute get _route =>
      _pilot.currentRoute ??
      AIBookSpecs.initialRoute(
        explicitPath: widget.initialRoutePath,
        currentUri: Uri.base,
        presets: _presets,
      );

  UxRouteSpec get _spec => AIBookSpecs.resolve(_route, presets: _presets);

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
      _AIBookStage.login => _buildLogin(context),
      _AIBookStage.loading => _buildLoading(),
      _AIBookStage.ready => _buildReady(context),
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
        _stage = _AIBookStage.loading;
      });
    }

    await Future<void>.delayed(Duration.zero);
    final presets = AIBookSpecs.presets();
    final routePath = AIBookSpecs.initialPath(
      explicitPath: widget.initialRoutePath,
      currentUri: Uri.base,
      presets: presets,
    );
    _pilot.navigate(routePath, notify: false);

    if (!mounted) return true;
    setState(() {
      _presets = presets;
      _routePath = routePath;
      _stage = _AIBookStage.ready;
    });
    return true;
  }

  void _openRoute(String route) {
    if (_stage != _AIBookStage.ready || _routePath == route) {
      return;
    }
    _pilot.navigate(route, notify: false);
    setState(() {
      _routePath = route;
    });
  }

  Widget _buildLogin(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AIBook Login')),
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
            Text('Loading aibook...'),
          ],
        ),
      ),
    );
  }

  Widget _buildReady(BuildContext context) {
    final route = _route;
    final spec = _spec;
    final presets = _presets;
    final selectedIndex = presets.indexWhere(
      (UxRouteSpec preset) => preset.path == route.path,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIBook'),
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
              color: UxTheme.appChromeColor(context),
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
                    child: GenUx.buildPaper(
                      spec: spec.paper,
                      autopilot: _pilot,
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
            Text('AIBook:${AIBookSpecs.appMeta}/${AppMeta.f}/${AppMeta.v}'),
          ],
        ),
      ),
    );
  }
}
