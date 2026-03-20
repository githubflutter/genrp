import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/model/uschema/ux_field_spec.dart';
import 'package:genrp/core/model/uschema/ux_paper_spec.dart';
import 'package:genrp/core/model/uschema/ux_route_spec.dart';
import 'package:genrp/core/model/uschema/uxm_template_spec.dart';
import 'package:genrp/meta.dart';

class AICodexSpecs {
  AICodexSpecs._();

  static const String appName = 'aicodex';
  static const String title = 'AICodex';
  static const int appMeta = AppMeta.aicodex;
  static const int paperZeroSpecId = 30001;
  static const int paperOneSpecId = 30002;

  static List<UxRouteSpec> presets() => <UxRouteSpec>[
    buildRouteSpec(const CopilotRoute(appName: appName, pageSpecId: paperZeroSpecId, optionalId: '42')),
    buildRouteSpec(const CopilotRoute(appName: appName, pageSpecId: paperOneSpecId, optionalId: '42')),
  ];

  static CopilotRoute? directRoute({String? explicitPath, Uri? currentUri}) {
    final candidates = <String?>[explicitPath, currentUri?.path, currentUri == null ? Uri.base.path : null];
    for (final candidate in candidates) {
      if (candidate == null || candidate.trim().isEmpty || candidate == '/') {
        continue;
      }
      try {
        final route = CopilotRoute.parse(candidate);
        if (route.appName == appName) {
          return route;
        }
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  static String? directPath({String? explicitPath, Uri? currentUri}) => directRoute(explicitPath: explicitPath, currentUri: currentUri)?.path;

  static CopilotRoute initialRoute({String? explicitPath, Uri? currentUri, List<UxRouteSpec> presets = const <UxRouteSpec>[]}) {
    final direct = directRoute(explicitPath: explicitPath, currentUri: currentUri);
    if (direct != null) {
      return direct;
    }
    if (presets.isNotEmpty) {
      return presets.first.route;
    }
    return const CopilotRoute(appName: appName, pageSpecId: paperZeroSpecId, optionalId: '42');
  }

  static String initialPath({String? explicitPath, Uri? currentUri, List<UxRouteSpec> presets = const <UxRouteSpec>[]}) {
    return initialRoute(explicitPath: explicitPath, currentUri: currentUri, presets: presets).path;
  }

  static UxRouteSpec resolve(CopilotRoute route, {List<UxRouteSpec> presets = const <UxRouteSpec>[]}) {
    for (final preset in presets) {
      if (preset.path == route.path) {
        return preset;
      }
    }
    return buildRouteSpec(route);
  }

  static UxRouteSpec buildRouteSpec(CopilotRoute route) {
    final seed = int.tryParse(route.optionalId ?? '42') ?? 42;
    final pid = route.pageSpecId == paperZeroSpecId ? 0 : 1;
    final isPaperZero = pid == 0;
    final name = 'Prompt Pack $seed';
    final owner = seed.isEven ? 'Mia' : 'Ethan';
    final status = seed.isEven ? 'Open' : 'Closed';

    return UxRouteSpec(
      appName: route.appName,
      pageSpecId: route.pageSpecId,
      optionalId: route.optionalId,
      title: isPaperZero ? 'Paperzero / ${route.optionalId ?? '-'}' : 'Paperone / ${route.optionalId ?? '-'}',
      subtitle: isPaperZero ? 'Schema/config host for AICodex' : 'Scrollable schema/config host for AICodex',
      paper: UxPaperSpec(
        pid: pid,
        i: route.pageSpecId,
        template: UxCrudTemplateSpec(
          i: 31001,
          collectionTitle: 'Prompts',
          collectionColumns: const <String>['ID', 'Name', 'Status'],
          collectionViewModes: const <int>[1, 2, 3],
          collectionRows: <List<Object?>>[
            <Object?>[seed, name, status],
            <Object?>[seed + 1, 'DDL Spec ${seed + 1}', 'Pending'],
            <Object?>[seed + 2, 'Function Plan ${seed + 2}', 'Open'],
          ],
          properties: <String, Object?>{'id': seed, 'name': name, 'status': status, 'owner': owner, 'route': route.path, 'app': title},
          formFields: <UxFieldSpec>[
            UxFieldSpec(label: 'Name', hint: name),
            UxFieldSpec(label: 'Status', hint: status),
            UxFieldSpec(label: 'Owner', hint: owner),
          ],
          summaryText: 'app=$appName, owner=$owner, status=$status',
        ),
      ),
    );
  }
}
