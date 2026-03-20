import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/workspace/workspace.dart';

void main() {
  testWidgets(
    'workspace auto-sign-in shortcut opens the demo screen directly',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1600, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: WorkSpaceHome(
            initialRoutePath: '/workspace/10001/42',
            autoSignIn: true,
          ),
        ),
      );

      expect(find.text('WorkSpace Login'), findsNothing);
      expect(find.text('Loading workspace...'), findsOneWidget);

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Paperzero / 42'), findsWidgets);
      expect(find.text('Results: 3'), findsOneWidget);
      expect(find.text('Search'), findsNothing);
    },
  );

  testWidgets(
    'workspace beta flow signs in, selects a record, edits it, and replaces the route',
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

      expect(find.text('Mock credential: admin / admin'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Paperzero / 42'), findsWidgets);
      expect(find.text('No selection'), findsNothing);
      expect(find.text('Search'), findsNothing);
      expect(find.textContaining('Orchid Supply 42'), findsOneWidget);

      await tester.tap(find.byTooltip('Switch view (Table -> List)'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Orchid Supply 42').first);
      await tester.pumpAndSettle();

      expect(find.text('Active: Orchid Supply 42'), findsOneWidget);
      expect(find.text('Selected: 1'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.text('Properties'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit 42'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.text('Paperone / 42').first);
      await tester.pumpAndSettle();

      expect(find.text('Route: /workspace/10002/42'), findsOneWidget);
      expect(find.text('Paperone / 42'), findsWidgets);
      expect(find.text('No selection'), findsNothing);
    },
  );
}
