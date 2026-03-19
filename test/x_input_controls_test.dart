import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aibook/autopilotgo.dart';
import 'package:genrp/core/model/uschema/ux_checkbox_model.dart';
import 'package:genrp/core/model/uschema/ux_text_box_model.dart';
import 'package:genrp/core/widgets/x_checkbox.dart';
import 'package:genrp/core/widgets/x_text_box.dart';

void main() {
  testWidgets('XTextBox renders from UxTextBoxModel', (tester) async {
    final autopilot = AutopilotGo()
      ..updateBinding('data.book.title', 'Initial');
    const model = UxTextBoxModel(
      i: 1,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 0,
      bodyId: 0,
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
    expect(find.byKey(const ValueKey('x-text-box-0-0-1')), findsOneWidget);
  });

  testWidgets('XTextBox adds highlight when selected identity matches', (
    tester,
  ) async {
    final autopilot = AutopilotGo()
      ..updateBinding('data.book.title', 'Initial')
      ..selectUxIdentity(hostId: 2, bodyId: 4, widgetId: 9, notify: false);
    const model = UxTextBoxModel(
      i: 9,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 2,
      bodyId: 4,
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

    final decoratedBox = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('x-text-box-2-4-9')),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(decoration.border, isNotNull);
  });

  testWidgets('XCheckBox renders from UxCheckBoxModel', (tester) async {
    final autopilot = AutopilotGo()..updateBinding('data.book.saved', true);
    const model = UxCheckBoxModel(
      i: 1,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 0,
      bodyId: 0,
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
    expect(find.byKey(const ValueKey('x-checkbox-0-0-1')), findsOneWidget);
  });

  testWidgets('XCheckBox adds highlight when selected identity matches', (
    tester,
  ) async {
    final autopilot = AutopilotGo()
      ..updateBinding('data.book.saved', true)
      ..selectUxIdentity(hostId: 5, bodyId: 6, widgetId: 7, notify: false);
    const model = UxCheckBoxModel(
      i: 7,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 5,
      bodyId: 6,
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

    final decoratedBox = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('x-checkbox-5-6-7')),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(decoration.border, isNotNull);
  });
}
