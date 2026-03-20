import 'package:genrp/core/ux/a/route.dart';
import 'package:genrp/core/ux/a/workspace_specs.dart';
import 'package:genrp/core/ux/m/m.dart';

class UxWorkspaceBootstrap {
  UxWorkspaceBootstrap._();

  static const String appName = 'workspace';

  static String initialPath({
    String? explicitPath,
    Uri? currentUri,
    List<UxRouteSpec> presets = const <UxRouteSpec>[],
  }) {
    final resolvedRoute = initialRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
      presets: presets,
    );
    return resolvedRoute.path;
  }

  static String? directPath({String? explicitPath, Uri? currentUri}) {
    final route = directRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
    );
    return route?.path;
  }

  static UxRoute? directRoute({String? explicitPath, Uri? currentUri}) {
    final candidates = <String?>[
      explicitPath,
      currentUri?.path,
      currentUri == null ? Uri.base.path : null,
    ];

    for (final candidate in candidates) {
      final route = _tryParseWorkspaceRoute(candidate);
      if (route != null) {
        return route;
      }
    }

    return null;
  }

  static UxRoute initialRoute({
    String? explicitPath,
    Uri? currentUri,
    List<UxRouteSpec> presets = const <UxRouteSpec>[],
  }) {
    final fallback = presets.isNotEmpty
        ? presets.first.route
        : UxWorkspaceSpecs.buildRouteSpec(
            const UxRoute(
              appName: appName,
              pageSpecId: UxWorkspaceSpecs.paperZeroSpecId,
              optionalId: '42',
            ),
          ).route;

    final direct = directRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
    );
    if (direct != null) {
      return direct;
    }

    return fallback;
  }

  static UxRouteSpec initialSpec({
    String? explicitPath,
    Uri? currentUri,
    List<UxRouteSpec> presets = const <UxRouteSpec>[],
  }) {
    final route = initialRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
      presets: presets,
    );
    return UxWorkspaceSpecs.resolve(route, presets: presets);
  }

  static UxRoute? _tryParseWorkspaceRoute(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw == '/') {
      return null;
    }
    try {
      final route = UxRoute.parse(raw);
      if (route.appName != appName) {
        return null;
      }
      return route;
    } on FormatException {
      return null;
    }
  }
}
