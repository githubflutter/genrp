import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aibook/autopilotgo.dart';
import 'package:genrp/core/generator/boilerplate_generator.dart';
import 'package:genrp/core/template/checkbox_form_template.dart';
import 'package:genrp/core/template/collection_template.dart';
import 'package:genrp/core/template/detail_template.dart';
import 'package:genrp/core/template/form_template.dart';
import 'package:genrp/core/widgets/x_checkbox.dart';
import 'package:genrp/core/widgets/x_text_box.dart';
import 'package:provider/provider.dart';

void main() {
  group('DynamicSpecBody boilerplate generator', () {
    testWidgets('routes numeric bodyId first', (tester) async {
      final spec = {
        'initialBody': 1,
        'bodies': {
          'wrongString': {'bodyId': 2, 'type': 'text', 'text': 'Wrong Body'},
          'correctBody': {'bodyId': 1, 'type': 'text', 'text': 'Correct Numeric Body'},
        },
        'registry': {
          'bodies': [
            {'id': 1, 'name': 'correctBody'},
            {'id': 2, 'name': 'wrongString'},
          ]
        }
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo()..configureSpec(spec),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Correct Numeric Body'), findsOneWidget);
      expect(find.text('Wrong Body'), findsNothing);
    });

    testWidgets('routes to form template', (tester) async {
      final spec = {
        'initialBody': 'test',
        'bodies': {
          'test': {'template': 'form', 'type': 'text', 'text': 'Form Body'},
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FormTemplate), findsOneWidget);
      expect(find.text('Form Body'), findsOneWidget);
    });

    testWidgets('routes to checkbox form template', (tester) async {
      final spec = {
        'initialBody': 'test',
        'initialData': {'book.saved': true},
        'bodies': {
          'test': {
            'template': 'checkboxForm',
            'checkbox': {'label': 'Saved', 'bind': 'data.book.saved'},
            'type': 'text',
            'text': 'Checkbox Body',
          },
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo()..configureSpec(spec),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CheckboxFormTemplate), findsOneWidget);
      expect(find.byType(XCheckBox), findsOneWidget);
      expect(find.text('Checkbox Body'), findsOneWidget);
    });

    testWidgets('checkbox form template updates bound value on tap', (
      tester,
    ) async {
      final spec = {
        'initialBody': 'test',
        'initialData': {'book.saved': false},
        'bodies': {
          'test': {
            'template': 'checkboxForm',
            'checkbox': {'label': 'Saved', 'bind': 'data.book.saved'},
            'type': 'text',
            'prefix': 'Saved Flag: ',
            'bind': 'data.book.saved',
          },
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo()..configureSpec(spec),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Saved Flag: false'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(find.text('Saved Flag: true'), findsOneWidget);
    });

    testWidgets('routes to detail template', (tester) async {
      final spec = {
        'initialBody': 'test',
        'bodies': {
          'test': {'template': 'detail', 'type': 'text', 'text': 'Detail Body'},
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DetailTemplate), findsOneWidget);
      expect(find.text('Detail Body'), findsOneWidget);
    });

    testWidgets('routes to collection template', (tester) async {
      final spec = {
        'initialBody': 'test',
        'bodies': {
          'test': {
            'template': 'collection',
            'title': 'Library',
            'type': 'text',
            'text': 'Collection Body',
          },
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CollectionTemplate), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Collection Body'), findsOneWidget);
    });

    testWidgets('renders text widget from spec', (tester) async {
      final spec = {
        'initialBody': 'test',
        'bodies': {
          'test': {'type': 'text', 'text': 'Hello World'},
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('renders text with headline style', (tester) async {
      final spec = {
        'initialBody': 'test',
        'bodies': {
          'test': {'type': 'text', 'text': 'Headline', 'style': 'headline'},
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Headline'));
      expect(textWidget.style?.fontSize, 20);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('renders text with bound value', (tester) async {
      final spec = {
        'initialBody': 'test',
        'initialData': {'test.value': 'Bound Value'},
        'bodies': {
          'test': {
            'type': 'text',
            'prefix': 'Value: ',
            'bind': 'data.test.value',
          },
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo()..configureSpec(spec),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Value: Bound Value'), findsOneWidget);
    });

    testWidgets('renders spacer with custom height', (tester) async {
      final spec = {
        'initialBody': 'test',
        'bodies': {
          'test': {
            'type': 'column',
            'children': [
              {'type': 'text', 'text': 'Before'},
              {'type': 'spacer', 'height': 24},
              {'type': 'text', 'text': 'After'},
            ],
          },
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      final spacer = find.byType(SizedBox);
      expect(spacer, findsOneWidget);
      final sizeBox = tester.widget<SizedBox>(spacer);
      expect(sizeBox.height, 24);
    });

    testWidgets('renders button with action trigger', (tester) async {
      final spec = {
        'initialBody': 'test',
        'actions': [
          {
            'id': 101,
            'name': 'testAction',
            'todos': [
              {
                'id': 'todo-set-flag',
                'type': 'data',
                'operation': 'set',
                'path': 'action.triggered',
                'value': true,
              },
            ],
          },
        ],
        'bodies': {
          'test': {
            'type': 'column',
            'children': [
              {'type': 'text', 'text': 'Button Test'},
              {'type': 'button', 'text': 'Click Me', 'action': 'testAction'},
            ],
          },
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo()..configureSpec(spec),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(find.text('Button Test'), findsOneWidget);
    });

    testWidgets('renders bound text field', (tester) async {
      final spec = {
        'initialBody': 'test',
        'initialData': {'form.input': 'Initial'},
        'bodies': {
          'test': {
            'type': 'column',
            'children': [
              {
                'type': 'textField',
                'label': 'Input',
                'bind': 'data.form.input',
              },
            ],
          },
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => AutopilotGo()..configureSpec(spec),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final autopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(spec: spec, autopilot: autopilot);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(XTextBox), findsOneWidget);
      expect(find.text('Input'), findsOneWidget);
    });
  });
}
