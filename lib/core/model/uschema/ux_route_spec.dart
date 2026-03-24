import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/model/uschema/ux_app_spec.dart';
import 'package:genrp/core/model/uschema/ux_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

/// Typed route presentation metadata stored next to a unified `UxSpec`.
class UxRouteMeta {
  const UxRouteMeta({
    this.title = '',
    this.subtitle = '',
  });

  factory UxRouteMeta.fromJson(Map<String, dynamic> json) {
    return UxRouteMeta(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
    );
  }

  final String title;
  final String subtitle;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'subtitle': subtitle,
  };
}

/// Route wrapper for the unified UX schema tree.
///
/// `UxSpec` is the primary structural schema. This wrapper still exists
/// because routing concerns have a small amount of non-structural context:
/// current app identity and the parsed `CopilotRoute`.
class UxRouteSpec {
  const UxRouteSpec({
    required this.app,
    required this.route,
    required this.spec,
    this.meta = const UxRouteMeta(),
  });

  final UxAppSpec app;
  final CopilotRoute route;
  final UxSpec spec;
  final UxRouteMeta meta;

  String get appName => route.appName;

  int get pageSpecId => route.pageSpecId;

  String? get optionalId => route.optionalId;

  String get title => meta.title;

  String get subtitle => meta.subtitle;

  String get path => route.path;

  String get scopeKey => route.scopeKey;

  int get l => UxLayer.route.code;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'appName': app.n,
    'route': route.toJson(),
    'meta': meta.toJson(),
    'spec': spec.toJson(),
  };

  factory UxRouteSpec.fromJson(Map<String, dynamic> json) {
    final route = CopilotRoute.fromJson(
      (json['route'] as Map<dynamic, dynamic>?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          const <String, dynamic>{},
    );
    return UxRouteSpec(
      app: UxAppSpecs.byName(json['appName'] as String? ?? route.appName),
      route: route,
      meta: UxRouteMeta.fromJson(
        (json['meta'] as Map<dynamic, dynamic>?)?.map(
              (key, value) => MapEntry(key.toString(), value),
            ) ??
            const <String, dynamic>{},
      ),
      spec: UxSpec.fromJson(
        (json['spec'] as Map<dynamic, dynamic>?)?.map(
              (key, value) => MapEntry(key.toString(), value),
            ) ??
            const <String, dynamic>{},
      ),
    );
  }
}
