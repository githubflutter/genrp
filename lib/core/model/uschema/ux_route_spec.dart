import 'package:genrp/core/model/uschema/ux_app_spec.dart';
import 'package:genrp/core/model/uschema/ux_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

/// Lightweight route coordinates for parsing and generation.
class UxRouteHeaderSpec {
  const UxRouteHeaderSpec({
    required this.appName,
    required this.id,
    this.optionalId,
  });

  factory UxRouteHeaderSpec.fromJson(Map<String, dynamic> json) {
    return UxRouteHeaderSpec(
      appName: json['appName'] as String? ?? json['a'] as String? ?? '',
      id: (json['id'] as num?)?.toInt() ??
          (json['i'] as num?)?.toInt() ??
          (json['pageSpecId'] as num?)?.toInt() ??
          0,
      optionalId: json['optionalId'] as String? ?? json['o'] as String?,
    );
  }

  factory UxRouteHeaderSpec.parse(String raw) {
    final uri = Uri.parse(raw.startsWith('/') ? raw : '/$raw');
    final segments = uri.pathSegments;
    if (segments.length < 2) {
      throw const FormatException(
        'Route must follow /<appname>/<id>/<optionalid?>',
      );
    }

    final id = int.tryParse(segments[1]);
    if (id == null) {
      throw FormatException(
        'Route ID must be an integer: ${segments[1]}',
      );
    }

    return UxRouteHeaderSpec(
      appName: segments[0],
      id: id,
      optionalId: segments.length > 2 ? segments[2] : null,
    );
  }

  /// App Name
  final String appName;

  /// Top-level Template ID
  final int id;

  /// Optional Data ID
  final String? optionalId;

  String get path => '/$appName/$id${optionalId == null ? '' : '/$optionalId'}';

  String get scopeKey =>
      '$appName.$id${optionalId == null ? '' : '.$optionalId'}';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'appName': appName,
    'id': id,
    'optionalId': optionalId,
  };

  @override
  String toString() => path;
}

/// Typed route presentation metadata stored next to a unified `UxSpec`.
class UxRouteMeta {
  const UxRouteMeta({this.title = '', this.subtitle = ''});

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
/// current app identity and the parsed `UxRouteHeaderSpec`.
class UxRouteSpec {
  const UxRouteSpec({
    required this.app,
    required this.route,
    required this.spec,
    this.meta = const UxRouteMeta(),
  });

  /// App Spec
  final UxAppSpec app;

  /// Route Header Spec
  final UxRouteHeaderSpec route;

  /// UI Spec
  final UxSpec spec;

  /// Route Metadata
  final UxRouteMeta meta;

  String get appName => route.appName;

  int get id => route.id;

  String? get optionalId => route.optionalId;

  String get title => meta.title;

  String get subtitle => meta.subtitle;

  String get path => route.path;

  String get scopeKey => route.scopeKey;

  int get l => UxLayer.route.code;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'app': app.n,
    'route': route.toJson(),
    'meta': meta.toJson(),
    'spec': spec.toJson(),
  };

  factory UxRouteSpec.fromJson(Map<String, dynamic> json) {
    final routeData = UxRouteHeaderSpec.fromJson(
      (json['route'] as Map<dynamic, dynamic>?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          (json['r'] as Map<dynamic, dynamic>?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          const <String, dynamic>{},
    );
    return UxRouteSpec(
      app: UxAppSpecs.byName(
        json['app'] as String? ?? json['a'] as String? ?? routeData.appName,
      ),
      route: routeData,
      meta: UxRouteMeta.fromJson(
        (json['meta'] as Map<dynamic, dynamic>?)?.map(
              (key, value) => MapEntry(key.toString(), value),
            ) ??
            (json['m'] as Map<dynamic, dynamic>?)?.map(
              (key, value) => MapEntry(key.toString(), value),
            ) ??
            const <String, dynamic>{},
      ),
      spec: UxSpec.fromJson(
        (json['spec'] as Map<dynamic, dynamic>?)?.map(
              (key, value) => MapEntry(key.toString(), value),
            ) ??
            (json['s'] as Map<dynamic, dynamic>?)?.map(
              (key, value) => MapEntry(key.toString(), value),
            ) ??
            const <String, dynamic>{},
      ),
    );
  }
}
