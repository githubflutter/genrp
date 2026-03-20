import 'package:flutter/material.dart';
import 'package:genrp/app/aiwork/aiwork_specs.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/model/uschema/ux_specs.dart';
import 'package:genrp/core/theme/theme.dart';
import 'package:genrp/core/gen/genux.dart';
import 'package:genrp/meta.dart';

class AIWorkApp extends StatelessWidget {
  const AIWorkApp({super.key, this.initialRoutePath, this.autoSignIn = false});

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AIWorkSpecs.title,
      theme: UxTheme.lightTheme(),
      darkTheme: UxTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: AIWorkHome(
        initialRoutePath: initialRoutePath,
        autoSignIn: autoSignIn,
      ),
    );
  }
}

class AIWorkHome extends StatefulWidget {
  const AIWorkHome({super.key, this.initialRoutePath, this.autoSignIn = false});

  final String? initialRoutePath;
  final bool autoSignIn;

  @override
  State<AIWorkHome> createState() => _AIWorkHomeState();
}

enum _AIWorkStage { login, loading, ready }

class _AIWorkHomeState extends State<AIWorkHome> {
  late final Autopilot _pilot;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  _AIWorkStage _stage = _AIWorkStage.login;
  String? _errorMessage;
  List<UxRouteSpec> _presets = const <UxRouteSpec>[];
  String? _routePath;

  CopilotRoute get _route =>
      _pilot.currentRoute ??
      AIWorkSpecs.initialRoute(
        explicitPath: widget.initialRoutePath,
        currentUri: Uri.base,
        presets: _presets,
      );

  UxRouteSpec get _spec => AIWorkSpecs.resolve(_route, presets: _presets);

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
      _AIWorkStage.login => _buildLogin(context),
      _AIWorkStage.loading => _buildLoading(),
      _AIWorkStage.ready => _buildReady(context),
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
        _stage = _AIWorkStage.loading;
      });
    }

    await Future<void>.delayed(Duration.zero);
    final presets = AIWorkSpecs.presets();
    final routePath = AIWorkSpecs.initialPath(
      explicitPath: widget.initialRoutePath,
      currentUri: Uri.base,
      presets: presets,
    );
    _pilot.navigate(routePath, notify: false);

    if (!mounted) return true;
    setState(() {
      _presets = presets;
      _routePath = routePath;
      _stage = _AIWorkStage.ready;
    });
    return true;
  }

  void _openRoute(String route) {
    if (_stage != _AIWorkStage.ready || _routePath == route) {
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
      appBar: AppBar(title: const Text('AIWork Login')),
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
            Text('Loading aiwork...'),
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
        title: const Text('AIWork'),
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
            Text('AIWork:${AIWorkSpecs.appMeta}/${AppMeta.f}/${AppMeta.v}'),
          ],
        ),
      ),
    );
  }
}
