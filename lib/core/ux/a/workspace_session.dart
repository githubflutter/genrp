import 'package:flutter/foundation.dart';
import 'package:genrp/core/ux/a/auth.dart';
import 'package:genrp/core/ux/a/bootstrap.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/a/route.dart';
import 'package:genrp/core/ux/a/workspace_specs.dart';
import 'package:genrp/core/ux/m/m.dart';

enum UxWorkspaceStage { login, loading, ready }

class UxWorkspaceSession extends ChangeNotifier {
  UxWorkspaceSession({
    required UxPilot pilot,
    this.initialRoutePath,
    this.currentUri,
    UxMockAuth auth = const UxMockAuth(),
  }) : _pilot = pilot,
       _auth = auth;

  final UxPilot _pilot;
  final UxMockAuth _auth;
  final String? initialRoutePath;
  final Uri? currentUri;

  UxWorkspaceStage _stage = UxWorkspaceStage.login;
  String? _errorMessage;
  List<UxRouteSpec> _presets = const <UxRouteSpec>[];
  String? _routePath;

  UxPilot get pilot => _pilot;
  UxWorkspaceStage get stage => _stage;
  String? get errorMessage => _errorMessage;
  List<UxRouteSpec> get presets => List<UxRouteSpec>.unmodifiable(_presets);
  String? get routePath => _routePath;

  UxRoute get route =>
      _pilot.currentRoute ??
      UxWorkspaceBootstrap.initialRoute(
        explicitPath: initialRoutePath,
        currentUri: currentUri,
        presets: _presets,
      );

  UxRouteSpec get spec => UxWorkspaceSpecs.resolve(route, presets: _presets);

  Future<bool> signInWithMockCredentials() {
    return signIn(username: UxMockAuth.username, password: UxMockAuth.password);
  }

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    final applied = _auth.applyToPilot(
      _pilot,
      username: username,
      password: password,
      notify: false,
    );
    if (!applied) {
      _errorMessage = 'Invalid credentials. Use admin / admin.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    _stage = UxWorkspaceStage.loading;
    notifyListeners();

    await Future<void>.delayed(Duration.zero);
    _presets = UxWorkspaceSpecs.presets();
    _routePath = UxWorkspaceBootstrap.initialPath(
      explicitPath: initialRoutePath,
      currentUri: currentUri,
      presets: _presets,
    );
    _pilot.navigate(_routePath!, notify: false);
    _stage = UxWorkspaceStage.ready;
    notifyListeners();
    return true;
  }

  void openRoute(String route) {
    if (_stage != UxWorkspaceStage.ready || _routePath == route) return;
    _pilot.navigate(route, notify: false);
    _routePath = route;
    notifyListeners();
  }

  @override
  void dispose() {
    _pilot.dispose();
    super.dispose();
  }
}
