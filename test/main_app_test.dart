import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/main.dart';

void main() {
  testWidgets('main launcher opens AICodex in one direction', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Choose App'), findsOneWidget);
    expect(find.text('WorkSpace Demo'), findsOneWidget);
    expect(find.text('WorkSpace'), findsOneWidget);
    expect(find.text('AIBook'), findsOneWidget);
    expect(find.text('AICodex'), findsOneWidget);
    expect(find.text('AIStudio'), findsOneWidget);

    await tester.tap(find.text('AICodex'));
    await tester.pump();

    expect(find.text('Schema Source'), findsOneWidget);
    expect(find.text('Master/Main Editor'), findsOneWidget);
    expect(find.text('Choose App'), findsNothing);
    expect(find.text('AIBook'), findsNothing);
    expect(find.text('AIStudio'), findsNothing);
  });

  testWidgets(
    'main launcher opens WorkSpace Demo in one tap to the concept screen',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1600, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MainApp());

      expect(find.text('Choose App'), findsOneWidget);
      expect(find.text('WorkSpace Demo'), findsOneWidget);

      await tester.tap(find.text('WorkSpace Demo'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Choose App'), findsNothing);
      expect(find.text('Paperzero / 42'), findsWidgets);
      expect(find.text('Results: 3'), findsOneWidget);
    },
  );
}
