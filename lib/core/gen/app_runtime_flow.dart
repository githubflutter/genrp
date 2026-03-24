import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/gen/uschema_compiled.dart';
import 'package:genrp/core/gen/uschema_runtime.dart';
import 'package:genrp/core/model/uschema/ux_specs.dart';

typedef RouteResolver =
    UxRouteSpec Function(
      CopilotRoute route, {
      List<UxRouteSpec> presets,
    });

typedef InitialRouteResolver =
    CopilotRoute Function({
      String? explicitPath,
      Uri? currentUri,
      List<UxRouteSpec> presets,
    });

class AppRuntimeBootstrap {
  const AppRuntimeBootstrap({
    required this.presets,
    required this.routePath,
  });

  final List<UxRouteSpec> presets;
  final String routePath;
}

/// Shared route/bootstrap runtime flow for app home shells.
class AppRuntimeFlow {
  AppRuntimeFlow({
    required this.autopilot,
    UschemaRuntime? uschemaRuntime,
  }) : uschemaRuntime = uschemaRuntime ?? UschemaRuntime();

  final Autopilot autopilot;
  final UschemaRuntime uschemaRuntime;

  List<UxRouteSpec> presets = const <UxRouteSpec>[];
  String? routePath;

  CopilotRoute route({
    required InitialRouteResolver initialRoute,
    String? explicitPath,
    Uri? currentUri,
  }) {
    return autopilot.currentRoute ??
        initialRoute(
          explicitPath: explicitPath,
          currentUri: currentUri,
          presets: presets,
        );
  }

  UxRouteSpec spec({
    required RouteResolver resolve,
    required InitialRouteResolver initialRoute,
    String? explicitPath,
    Uri? currentUri,
  }) {
    return resolve(
      route(
        initialRoute: initialRoute,
        explicitPath: explicitPath,
        currentUri: currentUri,
      ),
      presets: presets,
    );
  }

  UschemaCompiled compiled({
    required RouteResolver resolve,
    required InitialRouteResolver initialRoute,
    String? explicitPath,
    Uri? currentUri,
  }) {
    return uschemaRuntime.compiled(
      spec(
        resolve: resolve,
        initialRoute: initialRoute,
        explicitPath: explicitPath,
        currentUri: currentUri,
      ).spec,
    );
  }

  AppRuntimeBootstrap bootstrap({
    required List<UxRouteSpec> presets,
    required InitialRouteResolver initialRoute,
    required RouteResolver resolve,
    String? explicitPath,
    Uri? currentUri,
  }) {
    final resolvedRoute = initialRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
      presets: presets,
    );
    final resolvedPath = resolvedRoute.path;
    autopilot.navigate(resolvedPath, notify: false);
    uschemaRuntime.refreshResolved(
      resolvedPath,
      presets: presets,
      resolve: resolve,
    );
    this.presets = presets;
    routePath = resolvedPath;
    return AppRuntimeBootstrap(
      presets: presets,
      routePath: resolvedPath,
    );
  }

  bool openRoute(
    String nextRoute, {
    required RouteResolver resolve,
  }) {
    if (routePath == nextRoute) {
      return false;
    }
    autopilot.navigate(nextRoute, notify: false);
    uschemaRuntime.refreshResolved(
      nextRoute,
      presets: presets,
      resolve: resolve,
    );
    routePath = nextRoute;
    return true;
  }
}
