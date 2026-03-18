import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/autopilotgo.dart';
import 'package:genrp/core/model/ux/ux_checkbox_model.dart';
import 'package:genrp/core/model/ux/ux_text_box_model.dart';
import 'package:genrp/core/widgets/x_checkbox.dart';
import 'package:genrp/core/widgets/x_text_box.dart';

void main() {
  testWidgets('XTextBox renders from UxTextBoxModel', (tester) async {
    final autopilot = AutopilotGo()..updateBinding('data.book.title', 'Initial');
    const model = UxTextBoxModel(
      i: 1,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      n: 'Book Title',
      s: '',
      bind: 'data.book.title',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: XTextBox(model: model, autopilot: autopilot),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Book Title'), findsOneWidget);
  });

  testWidgets('XCheckBox renders from UxCheckBoxModel', (tester) async {
    final autopilot = AutopilotGo()..updateBinding('data.book.saved', true);
    const model = UxCheckBoxModel(
      i: 1,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      n: 'Saved',
      s: '',
      bind: 'data.book.saved',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: XCheckBox(model: model, autopilot: autopilot),
        ),
      ),
    );

    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });
}
