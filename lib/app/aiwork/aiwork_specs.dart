import 'package:genrp/core/model/uschema/uschema.dart';
import 'package:genrp/core/ux/mixins.dart';
import 'package:genrp/meta.dart';

class AIWorkSpecs {
  AIWorkSpecs._();

  static const String appName = 'aiwork';
  static const String title = 'AIWork';
  static const int appMeta = AppMeta.aiwork;
  static const int routeZeroSpecId = 10001;
  static const int routeOneSpecId = 10002;

  static const UxAppSpec appSpec = UxAppSpecs.aiwork;

  static List<UxRouteSpec> presets() => <UxRouteSpec>[
    buildRouteSpec(
      const UxRouteHeaderSpec(
        appName: appName,
        id: routeZeroSpecId,
        optionalId: '42',
      ),
    ),
    buildRouteSpec(
      const UxRouteHeaderSpec(
        appName: appName,
        id: routeOneSpecId,
        optionalId: '42',
      ),
    ),
    buildRouteSpec(
      const UxRouteHeaderSpec(
        appName: appName,
        id: routeOneSpecId,
        optionalId: '84',
      ),
    ),
  ];

  static UxRouteHeaderSpec? directRoute({
    String? explicitPath,
    Uri? currentUri,
  }) {
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
        final route = UxRouteHeaderSpec.parse(candidate);
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

  static UxRouteHeaderSpec initialRoute({
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

    return const UxRouteHeaderSpec(
      appName: appName,
      id: routeZeroSpecId,
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
    UxRouteHeaderSpec route, {
    List<UxRouteSpec> presets = const <UxRouteSpec>[],
  }) {
    for (final preset in presets) {
      if (preset.path == route.path) {
        return preset;
      }
    }
    return buildRouteSpec(route);
  }

  static UxRouteSpec buildRouteSpec(UxRouteHeaderSpec header) {
    final seed = int.tryParse(header.optionalId ?? '42') ?? 42;
    final isRouteZero = header.id == routeZeroSpecId;
    final name = 'Orchid Supply $seed';
    final owner = seed.isEven ? 'Mia' : 'Ethan';
    final status = seed.isEven ? 'Open' : 'Closed';

    return UxRouteSpec(
      app: appSpec,
      route: header,
      meta: UxRouteMeta(
        title: 'Workspace / ${header.optionalId ?? '-'}',
        subtitle: isRouteZero
            ? 'Root template host for AIWork'
            : header.optionalId == '84'
            ? 'Replace-only route change for AIWork'
            : 'Scrollable root template with the same AIWork flow',
      ),
      spec: UxSpec.rootTemplate(
        i: header.id,
        n: 'tworkspace',
        t: 1,
        frame: isRouteZero
            ? const UxFrameMeta(scroll: 'none')
            : const UxFrameMeta(scroll: 'vertical'),
        m: UxWorkspaceMeta(
          collectionTitle: 'Accounts',
          collectionColumns: const <String>['ID', 'Name', 'Status'],
          collectionViewModes: const <int>[1, 2, 3],
          collectionRows: <List<Object?>>[
            <Object?>[seed, name, status],
            <Object?>[seed + 1, 'Blue Harbor ${seed + 1}', 'Pending'],
            <Object?>[seed + 2, 'Silverline ${seed + 2}', 'Open'],
          ],
          properties: <String, Object?>{
            'id': seed,
            'name': name,
            'status': status,
            'owner': owner,
            'route': header.path,
            'app': title,
          },
          formFields: <UxFieldSpec>[
            UxFieldSpec(label: 'Name', hint: name),
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
          UxZone.footer: <UxSpec>[UxSpec.uwidget(i: 3, n: 'toolbar', t: 4)],
        },
      ),
    );
  }
}
