import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/ux/a/pilot.dart';
import 'package:genrp/core/ux/a/route.dart';
import 'package:genrp/core/ux/p/pzero.dart';
import 'package:genrp/core/ux/t/tcrud.dart';

void main() {
  testWidgets(
    'Pzero and Tcrud mount scopes, update view mode, and clear on dispose',
    (WidgetTester tester) async {
      final pilot = UxPilot();
      pilot.mountRoute(
        const UxRoute(
          appName: 'workspace',
          pageSpecId: 10002,
          optionalId: '42',
        ),
        notify: false,
      );

      const paperI = 101;
      const templateI = 201;
      final paperScope = pilot.paperScopeFor(paperI);
      final templateScope = pilot.templateScopeFor(
        paperI: paperI,
        templateI: templateI,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Pzero(
              i: paperI,
              autopilot: pilot,
              child: Tcrud(
                i: templateI,
                autopilot: pilot,
                collectionColumns: const <String>['Name'],
                collectionRows: const <List<Object?>>[
                  <Object?>['Alpha'],
                  <Object?>['Beta'],
                ],
                collectionViewModes: const <int>[1, 2, 3],
                properties: const <String, Object?>{'name': 'Alpha'},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(pilot.currentPaperScope, paperScope);
      expect(pilot.currentPaperI, paperI);
      expect(pilot.currentTemplateScopes, contains(templateScope));
      expect(pilot.templateState<String>(templateScope, 'mode'), 'browse');
      expect(pilot.templateState<int>(templateScope, 'viewMode'), 3);
      expect(find.text('Results: 2'), findsOneWidget);

      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();

      expect(pilot.templateState<String>(templateScope, 'mode'), 'inspect');
      expect(pilot.templateState<int>(templateScope, 'activeIndex'), 0);
      expect(pilot.templateState<Object?>(templateScope, 'activeId'), 'Alpha');
      expect(
        pilot.templateState<List<dynamic>>(templateScope, 'selectedIds'),
        <Object?>['Alpha'],
      );
      expect(find.text('Selected: 1'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(pilot.templateState<String>(templateScope, 'mode'), 'browse');
      expect(pilot.templateState<int?>(templateScope, 'activeIndex'), isNull);
      expect(pilot.templateState<Object?>(templateScope, 'activeId'), isNull);
      expect(
        pilot.templateState<List<dynamic>>(templateScope, 'selectedIds'),
        isEmpty,
      );
      expect(find.byTooltip('Switch view (Table -> List)'), findsOneWidget);

      await tester.tap(find.byTooltip('Switch view (Table -> List)'));
      await tester.pumpAndSettle();

      expect(pilot.templateState<int>(templateScope, 'viewMode'), 1);

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pumpAndSettle();

      expect(pilot.currentPaperScope, isNull);
      expect(pilot.currentTemplateScopes, isEmpty);
      expect(pilot.paperState<dynamic>(paperScope, 'mode'), isNull);
      expect(pilot.templateState<dynamic>(templateScope, 'viewMode'), isNull);
    },
  );

  testWidgets('mounted paper and template remount onto the next route scope', (
    WidgetTester tester,
  ) async {
    final pilot = UxPilot();
    pilot.mountRoute(
      const UxRoute(appName: 'workspace', pageSpecId: 10002, optionalId: '42'),
      notify: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Pzero(
            i: 101,
            autopilot: pilot,
            child: Tcrud(
              i: 201,
              autopilot: pilot,
              collectionColumns: const <String>['Name'],
              collectionRows: const <List<Object?>>[
                <Object?>['Alpha'],
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstPaperScope = pilot.currentPaperScope!;
    final firstTemplateScope = pilot.currentTemplateScopes.single;

    pilot.navigate('/workspace/10002/99', notify: false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Pzero(
            i: 101,
            autopilot: pilot,
            child: Tcrud(
              i: 201,
              autopilot: pilot,
              collectionColumns: const <String>['Name'],
              collectionRows: const <List<Object?>>[
                <Object?>['Alpha'],
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(pilot.currentPaperScope, isNot(firstPaperScope));
    expect(pilot.currentTemplateScopes.single, isNot(firstTemplateScope));
    expect(pilot.currentPaperScope, 'paper.workspace.10002.99.101');
    expect(
      pilot.currentTemplateScopes.single,
      'template.workspace.10002.99.101.201',
    );
    expect(pilot.paperState<dynamic>(firstPaperScope, 'mode'), isNull);
    expect(
      pilot.templateState<dynamic>(firstTemplateScope, 'viewMode'),
      isNull,
    );
  });
}
