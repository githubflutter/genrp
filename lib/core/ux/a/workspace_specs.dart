import 'package:genrp/core/ux/a/route.dart';
import 'package:genrp/core/ux/m/m.dart';

class UxWorkspaceSpecs {
  UxWorkspaceSpecs._();

  static const int paperZeroSpecId = 10001;
  static const int paperOneSpecId = 10002;

  static List<UxRouteSpec> presets() => <UxRouteSpec>[
    buildRouteSpec(
      const UxRoute(
        appName: 'workspace',
        pageSpecId: paperZeroSpecId,
        optionalId: '42',
      ),
    ),
    buildRouteSpec(
      const UxRoute(
        appName: 'workspace',
        pageSpecId: paperOneSpecId,
        optionalId: '42',
      ),
    ),
    buildRouteSpec(
      const UxRoute(
        appName: 'workspace',
        pageSpecId: paperOneSpecId,
        optionalId: '84',
      ),
    ),
  ];

  static UxRouteSpec resolve(
    UxRoute route, {
    List<UxRouteSpec> presets = const <UxRouteSpec>[],
  }) {
    for (final preset in presets) {
      if (preset.path == route.path) {
        return preset;
      }
    }
    return buildRouteSpec(route);
  }

  static UxRouteSpec buildRouteSpec(UxRoute route) {
    final seed = int.tryParse(route.optionalId ?? '42') ?? 42;
    final pid = _paperTypeFor(route.pageSpecId);
    final paperSpecId = route.pageSpecId;
    final isPaperZero = pid == 0;
    final name = isPaperZero ? 'Orchid Supply' : 'Northwind Fabric';
    final owner = seed.isEven ? 'Mia' : 'Ethan';
    final status = seed.isEven ? 'Open' : 'Closed';

    return UxRouteSpec(
      appName: route.appName,
      pageSpecId: paperSpecId,
      optionalId: route.optionalId,
      title: isPaperZero
          ? 'Paperzero / ${route.optionalId ?? '-'}'
          : 'Paperone / ${route.optionalId ?? '-'}',
      subtitle: isPaperZero
          ? 'Bare container host with CRUD workspace'
          : route.optionalId == '84'
          ? 'Replace-only route change with another record set'
          : 'Scroll host with the same CRUD workspace',
      paper: UxPaperSpec(
        pid: pid,
        i: paperSpecId,
        template: UxCrudTemplateSpec(
          i: 20001,
          collectionTitle: 'Accounts',
          collectionColumns: const <String>['ID', 'Name', 'Status'],
          collectionViewModes: const <int>[1, 2, 3],
          collectionRows: <List<Object?>>[
            <Object?>[seed, '$name $seed', status],
            <Object?>[seed + 1, 'Blue Harbor ${seed + 1}', 'Pending'],
            <Object?>[seed + 2, 'Silverline ${seed + 2}', 'Open'],
          ],
          properties: <String, Object?>{
            'id': seed,
            'name': '$name $seed',
            'status': status,
            'owner': owner,
            'route': route.path,
          },
          formFields: <UxFieldSpec>[
            UxFieldSpec(label: 'Name', hint: '$name $seed'),
            UxFieldSpec(label: 'Status', hint: status),
            UxFieldSpec(label: 'Owner', hint: owner),
          ],
          summaryText: 'owner=$owner, status=$status',
        ),
      ),
    );
  }

  static int _paperTypeFor(int pageSpecId) {
    if (pageSpecId == paperZeroSpecId) {
      return 0;
    }
    return 1;
  }
}
