import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/a/route.dart';

void main() {
  test('UxRoute parses app, page spec id, and optional id', () {
    final route = UxRoute.parse('/workspace/10012/345');

    expect(route.appName, 'workspace');
    expect(route.pageSpecId, 10012);
    expect(route.optionalId, '345');
    expect(route.path, '/workspace/10012/345');
    expect(route.scopeKey, 'workspace.10012.345');
  });

  test('UxPilot clears paper and template scopes on route replace', () {
    final pilot = UxPilot();

    pilot.mountRoute(
      const UxRoute(appName: 'workspace', pageSpecId: 10001),
      notify: false,
    );
    final paperScope = pilot.mountPaper(
      paperI: 101,
      initialState: const <String, dynamic>{'mode': 'browse'},
      notify: false,
    );
    final templateScope = pilot.mountTemplate(
      paperI: 101,
      templateI: 201,
      initialState: const <String, dynamic>{'selection': 5},
      notify: false,
    );

    expect(pilot.paperState<String>(paperScope, 'mode'), 'browse');
    expect(pilot.templateState<int>(templateScope, 'selection'), 5);

    pilot.mountRoute(
      const UxRoute(appName: 'workspace', pageSpecId: 10002, optionalId: '9'),
      notify: false,
    );

    expect(pilot.paperState<String>(paperScope, 'mode'), isNull);
    expect(pilot.templateState<int>(templateScope, 'selection'), isNull);
    expect(pilot.currentRoute?.path, '/workspace/10002/9');
    expect(pilot.currentTemplateScopes, isEmpty);
    expect(pilot.currentPaperScope, isNull);
  });

  test('UxPilot action registry runs registered actions', () async {
    final pilot = UxPilot();
    pilot.actions.register(7, (
      UxPilot pilot, {
      Map<String, dynamic> context = const <String, dynamic>{},
    }) {
      pilot.setData('action.result', context['value'], notify: false);
    });

    await pilot.actions.run(
      7,
      pilot,
      context: const <String, dynamic>{'value': 'done'},
    );

    expect(pilot.data('action.result'), 'done');
  });
}
