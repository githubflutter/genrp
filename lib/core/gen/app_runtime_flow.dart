import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/gen/uschema_compiled.dart';
import 'package:genrp/core/gen/uschema_runtime.dart';
import 'package:genrp/core/model/uschema/uschema.dart';

typedef RouteResolver =
    UxRouteSpec Function(UxRouteHeaderSpec route, {List<UxRouteSpec> presets});

typedef InitialRouteResolver =
    UxRouteHeaderSpec Function({
      String? explicitPath,
      Uri? currentUri,
      List<UxRouteSpec> presets,
    });

class AppRuntimeBootstrap {
  const AppRuntimeBootstrap({required this.presets, required this.routePath});

  final List<UxRouteSpec> presets;
  final String routePath;
}

/// Shared route/bootstrap runtime flow for app home shells.
class AppRuntimeFlow {
  AppRuntimeFlow({required this.autopilot, UschemaRuntime? uschemaRuntime})
    : uschemaRuntime = uschemaRuntime ?? UschemaRuntime();

  final Autopilot autopilot;
  final UschemaRuntime uschemaRuntime;

  List<UxRouteSpec> presets = const <UxRouteSpec>[];
  String? routePath;

  UxRouteHeaderSpec route({
    required InitialRouteResolver initialRoute,
    String? explicitPath,
    Uri? currentUri,
  }) {
    final current = autopilot.currentRoute;
    if (current != null) {
      return current.route;
    }
    return initialRoute(
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
    this.presets = presets;
    final headerRoute = initialRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
      presets: presets,
    );
    final resolvedPath = headerRoute.path;
    final resolvedRouteSpec = resolve(headerRoute, presets: presets);
    autopilot.mountRoute(resolvedRouteSpec, notify: false);
    uschemaRuntime.refresh(resolvedRouteSpec.spec);
    routePath = resolvedPath;
    return AppRuntimeBootstrap(presets: presets, routePath: resolvedPath);
  }

  bool openRoute(String nextRoute, {required RouteResolver resolve}) {
    if (routePath == nextRoute) {
      return false;
    }
    final headerRoute = UxRouteHeaderSpec.parse(nextRoute);
    final resolvedRouteSpec = resolve(headerRoute, presets: presets);
    autopilot.mountRoute(resolvedRouteSpec, notify: false);
    uschemaRuntime.refresh(resolvedRouteSpec.spec);
    routePath = nextRoute;
    return true;
  }
}
