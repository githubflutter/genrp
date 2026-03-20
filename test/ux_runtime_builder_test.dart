import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/workspace/workspace.dart';
import 'package:genrp/core/ux/a/a.dart';
import 'package:genrp/core/ux/m/m.dart';
import 'package:genrp/core/ux/p/pone.dart';
import 'package:genrp/core/ux/p/pzero.dart';
import 'package:genrp/core/ux/t/tcrud.dart';

void main() {
  test(
    'workspace specs provide stable demo presets and fallback route specs',
    () {
      final presets = UxWorkspaceSpecs.presets();

      expect(presets, hasLength(3));
      expect(presets.first.path, '/workspace/10001/42');
      expect(presets[1].path, '/workspace/10002/42');

      final fallback = UxWorkspaceSpecs.resolve(
        const UxRoute(
          appName: 'workspace',
          pageSpecId: 10002,
          optionalId: '999',
        ),
        presets: presets,
      );

      expect(fallback.path, '/workspace/10002/999');
      expect(fallback.paper.pid, 1);
      expect(fallback.paper.i, 10002);
      expect(fallback.paper.template, isA<UxCrudTemplateSpec>());
    },
  );

  test('workspace bootstrap resolves explicit and URI-based startup paths', () {
    final presets = UxWorkspaceSpecs.presets();

    expect(
      UxWorkspaceBootstrap.initialPath(
        explicitPath: '/workspace/10002/84',
        presets: presets,
      ),
      '/workspace/10002/84',
    );

    expect(
      UxWorkspaceBootstrap.initialPath(
        currentUri: Uri.parse('https://example.com/workspace/10002/999'),
        presets: presets,
      ),
      '/workspace/10002/999',
    );

    expect(
      UxWorkspaceBootstrap.initialPath(
        currentUri: Uri.parse('https://example.com/aibook/1/2'),
        presets: presets,
      ),
      presets.first.path,
    );

    expect(
      UxWorkspaceBootstrap.directPath(
        currentUri: Uri.parse('https://example.com/workspace/10002/84'),
      ),
      '/workspace/10002/84',
    );

    expect(
      UxWorkspaceBootstrap.directPath(
        currentUri: Uri.parse('https://example.com/aibook/1/2'),
      ),
      isNull,
    );
  });

  test('mock auth accepts admin/admin and applies usr/user with i = 0', () {
    const auth = UxMockAuth();
    final pilot = UxPilot();

    final session = auth.signIn(username: 'admin', password: 'admin');

    expect(session, isNotNull);
    expect(session!.usr.i, 0);
    expect(session.user.i, 0);
    expect(session.usr.u, 'admin');
    expect(session.user.u, 'admin');

    final applied = auth.applyToPilot(pilot, notify: false);

    expect(applied, isTrue);
    expect((pilot.usr as dynamic).i, 0);
    expect((pilot.user as dynamic).i, 0);
  });

  test(
    'runtime renderer maps specs to the current paper and template widgets',
    () {
      final pilot = UxPilot();

      final paperZero = UxPaperSpec(
        pid: 0,
        i: 10001,
        template: const UxCrudTemplateSpec(i: 20001),
      );
      final zeroWidget = UxRuntimeRenderer.buildPaper(
        spec: paperZero,
        autopilot: pilot,
        optionalId: '42',
      );

      expect(zeroWidget, isA<Pzero>());

      final paperOne = UxPaperSpec(
        pid: 1,
        i: 10002,
        template: const UxCrudTemplateSpec(i: 20001),
      );
      final oneWidget = UxRuntimeRenderer.buildPaper(
        spec: paperOne,
        autopilot: pilot,
        optionalId: '42',
      );

      expect(oneWidget, isA<Pone>());

      final templateWidget = UxRuntimeRenderer.buildTemplate(
        spec: const UxCrudTemplateSpec(i: 20001),
        autopilot: pilot,
        optionalId: '42',
      );

      expect(templateWidget, isA<Tcrud>());
      expect(templateWidget, isA<StatelessWidget>());
    },
  );

  testWidgets(
    'workspace route changes switch the ready shell to the next page spec',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1600, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: WorkSpaceHome(initialRoutePath: '/workspace/10001/42'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Paperone / 42').first);
      await tester.pumpAndSettle();

      expect(find.text('Route: /workspace/10002/42'), findsOneWidget);
      expect(find.text('Paperone / 42'), findsWidgets);
    },
  );
}
