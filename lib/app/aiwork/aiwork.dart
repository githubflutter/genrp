import 'package:flutter/material.dart';
import 'package:genrp/app/aiwork/aiwork_specs.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/mockauth.dart';
import 'package:genrp/core/gen/app_runtime_flow.dart';
import 'package:genrp/core/gen/genux.dart';
import 'package:genrp/core/gen/uschema_compiled.dart';
import 'package:genrp/core/model/uschema/uschema.dart';
import 'package:genrp/core/theme/theme.dart';
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
  late final AppRuntimeFlow _runtimeFlow;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  _AIWorkStage _stage = _AIWorkStage.login;
  String? _errorMessage;

  UxRouteHeaderSpec get _route => _runtimeFlow.route(
    initialRoute: AIWorkSpecs.initialRoute,
    explicitPath: widget.initialRoutePath,
    currentUri: Uri.base,
  );

  UxRouteSpec get _spec => _runtimeFlow.spec(
    resolve: AIWorkSpecs.resolve,
    initialRoute: AIWorkSpecs.initialRoute,
    explicitPath: widget.initialRoutePath,
    currentUri: Uri.base,
  );

  UschemaCompiled get _compiledSpec => _runtimeFlow.compiled(
    resolve: AIWorkSpecs.resolve,
    initialRoute: AIWorkSpecs.initialRoute,
    explicitPath: widget.initialRoutePath,
    currentUri: Uri.base,
  );

  @override
  void initState() {
    super.initState();
    _pilot = Autopilot(v: '${AppMeta.v}', f: '${AppMeta.f}', c: '1');
    _runtimeFlow = AppRuntimeFlow(autopilot: _pilot);
    _usernameController = TextEditingController(text: MockAuth.username);
    _passwordController = TextEditingController(text: MockAuth.password);
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
    return _signIn(username: MockAuth.username, password: MockAuth.password);
  }

  Future<bool> _signIn({
    required String username,
    required String password,
  }) async {
    final applied = MockAuth.apply(
      _pilot,
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
    _runtimeFlow.bootstrap(
      presets: AIWorkSpecs.presets(),
      initialRoute: AIWorkSpecs.initialRoute,
      resolve: AIWorkSpecs.resolve,
      explicitPath: widget.initialRoutePath,
      currentUri: Uri.base,
    );

    if (!mounted) return true;
    setState(() {
      _stage = _AIWorkStage.ready;
    });
    return true;
  }

  void _openRoute(String route) {
    if (_stage != _AIWorkStage.ready) {
      return;
    }
    final changed = _runtimeFlow.openRoute(route, resolve: AIWorkSpecs.resolve);
    if (!changed) return;
    setState(() {});
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
    final presets = _runtimeFlow.presets;
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
                    child: GenUx.build(
                      compiled: _compiledSpec,
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
