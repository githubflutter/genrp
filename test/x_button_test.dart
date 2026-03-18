import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/autopilotgo.dart';
import 'package:genrp/core/model/ux/ux_button_model.dart';
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
  });
}
