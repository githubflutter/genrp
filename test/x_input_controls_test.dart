import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aibook/autopilotgo.dart';
import 'package:genrp/core/model/uschema/ux_template_spec.dart';
import 'package:genrp/core/widgets/x_checkbox.dart';
import 'package:genrp/core/widgets/x_text_box.dart';

void main() {
  testWidgets('XTextBox renders from UxNodeSpec', (tester) async {
    final autopilot = AutopilotGo()
      ..updateBinding('data.book.title', 'Initial');
    const node = UxNodeSpec(
      widgetId: 1,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 0,
      bodyId: 0,
      typeId: 3,
      type: 'textField',
      n: '',
      s: '',
      text: '',
      label: 'Book Title',
      bind: 'data.book.title',
      src: null,
      fieldId: null,
      actionId: 0,
      prefix: '',
      suffix: '',
      style: '',
      height: null,
      props: <String, dynamic>{},
      children: <UxNodeSpec>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: XTextBox(node: node, autopilot: autopilot),
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
    const node = UxNodeSpec(
      widgetId: 9,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 2,
      bodyId: 4,
      typeId: 3,
      type: 'textField',
      n: '',
      s: '',
      text: '',
      label: 'Book Title',
      bind: 'data.book.title',
      src: null,
      fieldId: null,
      actionId: 0,
      prefix: '',
      suffix: '',
      style: '',
      height: null,
      props: <String, dynamic>{},
      children: <UxNodeSpec>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: XTextBox(node: node, autopilot: autopilot),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('x-text-box-2-4-9')),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(decoration.border, isNotNull);
  });

  testWidgets('XCheckBox renders from UxNodeSpec', (tester) async {
    final autopilot = AutopilotGo()..updateBinding('data.book.saved', true);
    const node = UxNodeSpec(
      widgetId: 1,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 0,
      bodyId: 0,
      typeId: 6,
      type: 'checkbox',
      n: '',
      s: '',
      text: '',
      label: 'Saved',
      bind: 'data.book.saved',
      src: null,
      fieldId: null,
      actionId: 0,
      prefix: '',
      suffix: '',
      style: '',
      height: null,
      props: <String, dynamic>{},
      children: <UxNodeSpec>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: XCheckBox(node: node, autopilot: autopilot),
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
    const node = UxNodeSpec(
      widgetId: 7,
      a: true,
      d: 0,
      e: 0,
      t: 0,
      hostId: 5,
      bodyId: 6,
      typeId: 6,
      type: 'checkbox',
      n: '',
      s: '',
      text: '',
      label: 'Saved',
      bind: 'data.book.saved',
      src: null,
      fieldId: null,
      actionId: 0,
      prefix: '',
      suffix: '',
      style: '',
      height: null,
      props: <String, dynamic>{},
      children: <UxNodeSpec>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: XCheckBox(node: node, autopilot: autopilot),
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
