import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/model/uschema/ux_paper_spec.dart';

class UxRouteSpec {
  const UxRouteSpec({
    required this.appName,
    required this.pageSpecId,
    required this.title,
    required this.subtitle,
    required this.paper,
    this.optionalId,
  });

  final String appName;
  final int pageSpecId;
  final String? optionalId;
  final String title;
  final String subtitle;
  final UxPaperSpec paper;

  CopilotRoute get route => CopilotRoute(
    appName: appName,
    pageSpecId: pageSpecId,
    optionalId: optionalId,
  );

  String get path => route.path;

  String get scopeKey => route.scopeKey;
}
