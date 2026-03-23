import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/model/uschema/ux_app_spec.dart';
import 'package:genrp/core/model/uschema/ux_spec.dart';
import 'package:genrp/core/ux/mixins.dart';

class UxRouteMeta {
  const UxRouteMeta({
    this.title = '',
    this.subtitle = '',
  });

  final String title;
  final String subtitle;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'subtitle': subtitle,
  };
}

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
}
