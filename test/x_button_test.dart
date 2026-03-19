import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aibook/autopilotgo.dart';
import 'package:genrp/core/model/uschema/ux_button_model.dart';
import 'package:genrp/core/widgets/x_button.dart';

void main() {
  testWidgets('XButton renders from UxButtonModel', (tester) async {
    final autopilot = AutopilotGo();
    const model = UxButtonModel(
      i: 1,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 0,
      bodyId: 0,
      n: 'Save',
      s: '',
      actionId: 1001,
      actionName: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: XButton(model: model, autopilot: autopilot),
        ),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byKey(const ValueKey('x-button-0-0-1')), findsOneWidget);
  });

  testWidgets('XButton adds highlight when selected identity matches', (
    tester,
  ) async {
    final autopilot = AutopilotGo()
      ..selectUxIdentity(hostId: 3, bodyId: 7, widgetId: 11, notify: false);
    const model = UxButtonModel(
      i: 11,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 3,
      bodyId: 7,
      n: 'Preview',
      s: '',
      actionId: 0,
      actionName: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: XButton(model: model, autopilot: autopilot),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('x-button-3-7-11')),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(decoration.border, isNotNull);
  });
}
