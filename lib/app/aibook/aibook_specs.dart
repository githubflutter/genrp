import 'package:genrp/core/agent/copilot_route.dart';
import 'package:genrp/core/model/uschema/ux_specs.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/meta.dart';

class AIBookSpecs {
  AIBookSpecs._();

  static const String appName = 'aibook';
  static const String title = 'AIBook';
  static const int appMeta = AppMeta.aibook;
  static const int paperZeroSpecId = 20001;
  static const int paperOneSpecId = 20002;

  static const UxAppSpec appSpec = UxAppSpecs.aibook;

  static List<UxRouteSpec> presets() => <UxRouteSpec>[
    buildRouteSpec(
      const CopilotRoute(
        appName: appName,
        pageSpecId: paperZeroSpecId,
        optionalId: '42',
      ),
    ),
    buildRouteSpec(
      const CopilotRoute(
        appName: appName,
        pageSpecId: paperOneSpecId,
        optionalId: '42',
      ),
    ),
  ];

  static CopilotRoute? directRoute({String? explicitPath, Uri? currentUri}) {
    final candidates = <String?>[
      explicitPath,
      currentUri?.path,
      currentUri == null ? Uri.base.path : null,
    ];
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

  static String? directPath({String? explicitPath, Uri? currentUri}) =>
      directRoute(explicitPath: explicitPath, currentUri: currentUri)?.path;

  static CopilotRoute initialRoute({
    String? explicitPath,
    Uri? currentUri,
    List<UxRouteSpec> presets = const <UxRouteSpec>[],
  }) {
    final direct = directRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
    );
    if (direct != null) {
      return direct;
    }
    if (presets.isNotEmpty) {
      return presets.first.route;
    }
    return const CopilotRoute(
      appName: appName,
      pageSpecId: paperZeroSpecId,
      optionalId: '42',
    );
  }

  static String initialPath({
    String? explicitPath,
    Uri? currentUri,
    List<UxRouteSpec> presets = const <UxRouteSpec>[],
  }) {
    return initialRoute(
      explicitPath: explicitPath,
      currentUri: currentUri,
      presets: presets,
    ).path;
  }

  static UxRouteSpec resolve(
    CopilotRoute route, {
    List<UxRouteSpec> presets = const <UxRouteSpec>[],
  }) {
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
    final name = 'Atlas Volume $seed';
    final owner = seed.isEven ? 'Mia' : 'Ethan';
    final status = seed.isEven ? 'Open' : 'Closed';

    return UxRouteSpec(
      app: appSpec,
      route: route,
      meta: UxRouteMeta(
        title: isPaperZero
            ? 'Paperzero / ${route.optionalId ?? '-'}'
            : 'Paperone / ${route.optionalId ?? '-'}',
        subtitle: isPaperZero
            ? 'Mobile client host for AIBook'
            : 'Scrollable client host for AIBook',
      ),
      spec: UxSpec.paper(
        i: route.pageSpecId,
        n: pid == 0 ? 'paperzero' : 'paperone',
        t: pid,
        m: const <String, dynamic>{},
        s: const <String, dynamic>{},
        uxzones: <String, List<UxSpec>>{
          UxZone.content: <UxSpec>[
            UxSpec.template(
            i: 21001,
            n: 'tworkspace',
            t: 1,
            m: UxWorkspaceMeta(
              collectionTitle: 'Books',
              collectionColumns: const <String>['ID', 'Name', 'Status'],
              collectionViewModes: const <int>[1, 3],
              collectionRows: <List<Object?>>[
                <Object?>[seed, name, status],
                <Object?>[seed + 1, 'Pocket Guide ${seed + 1}', 'Pending'],
                <Object?>[seed + 2, 'Field Notes ${seed + 2}', 'Open'],
              ],
              properties: <String, Object?>{
                'id': seed,
                'name': name,
                'status': status,
                'owner': owner,
                'route': route.path,
                'app': title,
              },
              formFields: <UxFieldSpec>[
                UxFieldSpec(label: 'Title', hint: name),
                UxFieldSpec(label: 'Status', hint: status),
                UxFieldSpec(label: 'Owner', hint: owner),
              ],
              summaryText: 'app=$appName, owner=$owner, status=$status',
            ).toJson(),
            s: const <String, dynamic>{},
            uxzones: <String, List<UxSpec>>{
              UxZone.header: <UxSpec>[
                UxSpec.uwidget(i: 1, n: 'toolbar', t: 4),
                UxSpec.uwidget(i: 2, n: 'toolbar', t: 4),
              ],
              UxZone.collection: <UxSpec>[
                UxSpec.uwidget(i: 10, n: 'collection', t: 12),
              ],
              UxZone.detail: <UxSpec>[
                UxSpec.uwidget(i: 12, n: 'plist', t: 6),
                UxSpec.uwidget(i: 13, n: 'form', t: 5),
              ],
              UxZone.feedback: <UxSpec>[
                UxSpec.uwidget(i: 11, n: 'empty', t: 9),
                UxSpec.uwidget(i: 14, n: 'alert', t: 11),
              ],
              UxZone.footer: <UxSpec>[
                UxSpec.uwidget(i: 3, n: 'toolbar', t: 4),
              ],
            },
          ),
          ],
        },
      ),
    );
  }
}
