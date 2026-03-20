import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aibook/autopilotgo.dart';
import 'package:genrp/core/generator/boilerplate_generator.dart';
import 'package:genrp/core/template/checkbox_form_template.dart';
import 'package:genrp/core/template/collection_template.dart';
import 'package:genrp/core/template/detail_template.dart';
import 'package:genrp/core/template/form_template.dart';
import 'package:genrp/core/theme/genrp_theme.dart';
import 'package:genrp/core/widgets/x_checkbox.dart';
import 'package:genrp/core/widgets/x_text_box.dart';
import 'package:provider/provider.dart';

void main() {
  group('DynamicSpecBody boilerplate generator', () {
    testWidgets('routes numeric bodyId first', (tester) async {
      final spec = {
        'initialBody': 1,
        'bodies': {
          'wrongString': {
            'bodyId': 2,
            't': 4,
            'type': 'text',
            'text': 'Wrong Body',
          },
          'correctBody': {
            'bodyId': 1,
            't': 4,
            'type': 'text',
            'text': 'Correct Numeric Body',
          },
        },
        'registry': {
          'bodies': [
            {'id': 1, 'name': 'correctBody'},
            {'id': 2, 'name': 'wrongString'},
          ],
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

      expect(find.text('Correct Numeric Body'), findsOneWidget);
      expect(find.text('Wrong Body'), findsNothing);
    });

    testWidgets('routes to form template', (tester) async {
      final spec = {
        'initialBody': 'test',
        'bodies': {
          'test': {'t': 4, 'type': 'text', 'text': 'Form Body'},
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
            't': 1,
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
            't': 1,
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
          'test': {'t': 3, 'type': 'text', 'text': 'Detail Body'},
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
            't': 2,
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

    testWidgets('collection switches between list, grid, and table modes', (
      tester,
    ) async {
      final spec = {
        'initialBody': 'collection',
        'initialState': {'mode.0.1': 1},
        'bodies': {
          'collection': {
            'bodyId': 1,
            't': 2,
            'm': [1, 2, 3],
            'title': 'Library',
            'items': ['A', 'B', 'C'],
            'type': 'text',
            'text': 'fallback',
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

      expect(
        find.byKey(const ValueKey('collection_view_list')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('collection_mode_2')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('collection_view_grid')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('collection_mode_3')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('collection_view_table')),
        findsOneWidget,
      );
    });

    testWidgets('collection shows error panel for unsupported active mode', (
      tester,
    ) async {
      final spec = {
        'initialBody': 'collection',
        'initialState': {'mode.0.1': 3},
        'bodies': {
          'collection': {
            'bodyId': 1,
            't': 2,
            'm': [1, 2],
            'items': ['A'],
            'type': 'text',
            'text': 'fallback',
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

      expect(
        find.byKey(const ValueKey('collection_error_panel')),
        findsOneWidget,
      );
    });

    testWidgets(
      'collection stores scoped selection and dispatches selection actions',
      (tester) async {
        final autopilot = AutopilotGo();
        final spec = {
          'initialBody': 'collection',
          'actions': [
            {
              'id': 301,
              'n': 'Use Selected',
              'name': 'useSelected',
              'todos': [
                {
                  'id': 'todo-selected-status',
                  'type': 'ux',
                  'operation': 'set',
                  'path': 'status',
                  'value': {'payload': 'label'},
                },
              ],
            },
          ],
          'bodies': {
            'collection': {
              'bodyId': 1,
              't': 2,
              'm': [1, 2],
              'title': 'Library',
              'items': [
                {'label': 'Alpha', 'code': 11},
                {'label': 'Beta', 'code': 22},
              ],
              'actionCenters': {
                'selection': {
                  'label': 'Selected Actions',
                  'selection': true,
                  'actionIds': [301],
                },
              },
              'type': 'text',
              'text': 'fallback',
            },
          },
        };

        await tester.pumpWidget(
          ChangeNotifierProvider<AutopilotGo>(
            create: (_) => autopilot..configureSpec(spec),
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final currentAutopilot = Provider.of<AutopilotGo>(context);
                    return DynamicSpecBody(
                      spec: spec,
                      autopilot: currentAutopilot,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(
          find.byKey(const ValueKey('collection_selected_label')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('selection-action-center-selection-301')),
          findsNothing,
        );

        await tester.tap(find.byKey(const ValueKey('collection_item_1_1_1')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('collection_selected_label')),
          findsOneWidget,
        );
        expect(find.text('Selected: Beta'), findsOneWidget);
        expect(autopilot.selectedIndexFor(hostId: 0, bodyId: 1), equals(1));
        expect(
          find.byKey(const ValueKey('selection-action-center-selection-301')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const ValueKey('collection_mode_2')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('collection_view_grid')),
          findsOneWidget,
        );
        expect(find.text('Selected: Beta'), findsOneWidget);
        expect(autopilot.selectedIndexFor(hostId: 0, bodyId: 1), equals(1));

        await tester.tap(
          find.byKey(const ValueKey('selection-action-center-selection-301')),
        );
        await tester.pumpAndSettle();

        expect(autopilot.resolve('ux.status'), equals('Beta'));
      },
    );

    testWidgets('collection supports multi-select bulk actions', (
      tester,
    ) async {
      final autopilot = AutopilotGo();
      final spec = {
        'initialBody': 'collection',
        'actions': [
          {
            'id': 401,
            'n': 'Apply Bulk',
            'name': 'applyBulk',
            'todos': [
              {
                'id': 'todo-bulk-status',
                'type': 'ux',
                'operation': 'set',
                'path': 'status',
                'value': {'payload': 'count'},
              },
            ],
          },
        ],
        'bodies': {
          'collection': {
            'bodyId': 1,
            't': 2,
            'm': [1, 2],
            'sm': 2,
            'title': 'Bulk Library',
            'items': [
              {'label': 'Alpha'},
              {'label': 'Beta'},
              {'label': 'Gamma'},
            ],
            'actionCenters': {
              'selection': {
                'label': 'Bulk Actions',
                'selection': true,
                'actionIds': [401],
              },
            },
            'type': 'text',
            'text': 'fallback',
          },
        },
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<AutopilotGo>(
          create: (_) => autopilot..configureSpec(spec),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final currentAutopilot = Provider.of<AutopilotGo>(context);
                  return DynamicSpecBody(
                    spec: spec,
                    autopilot: currentAutopilot,
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('collection_item_1_1_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('collection_item_1_1_2')));
      await tester.pumpAndSettle();

      expect(find.text('Selected: 2 items'), findsOneWidget);
      expect(
        autopilot.selectedIndexesFor(hostId: 0, bodyId: 1),
        equals([0, 2]),
      );
      expect(
        find.byKey(const ValueKey('selection-action-center-selection-401')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('collection_mode_2')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('collection_view_grid')),
        findsOneWidget,
      );
      expect(find.text('Selected: 2 items'), findsOneWidget);
      expect(
        autopilot.selectedIndexesFor(hostId: 0, bodyId: 1),
        equals([0, 2]),
      );

      await tester.tap(
        find.byKey(const ValueKey('selection-action-center-selection-401')),
      );
      await tester.pumpAndSettle();

      expect(autopilot.resolve('ux.status'), equals(2));
    });

    testWidgets('renders text widget from spec', (tester) async {
      final spec = {
        'initialBody': 'test',
        'bodies': {
          'test': {'t': 4, 'type': 'text', 'text': 'Hello World'},
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
          'test': {
            't': 4,
            'type': 'text',
            'text': 'Headline',
            'style': 'headline',
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

      final textWidget = tester.widget<Text>(find.text('Headline'));
      expect(textWidget.style?.fontSize, GenrpTheme.fontXl);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('renders text with bound value', (tester) async {
      final spec = {
        'initialBody': 'test',
        'initialData': {'test.value': 'Bound Value'},
        'bodies': {
          'test': {
            't': 4,
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
            't': 4,
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

      final spacer = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 24,
      );
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
            't': 4,
            'type': 'column',
            'children': [
              {'type': 'text', 'text': 'Button Test'},
              {'type': 'button', 'text': 'Click Me', 'actionId': 101},
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
            't': 4,
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

    testWidgets('renders action centers from numeric action ids', (
      tester,
    ) async {
      final spec = {
        'initialBody': 'test',
        'actions': [
          {
            'id': 201,
            'name': 'Mark Ready',
            'todos': [
              {
                'id': 'todo-status',
                'type': 'ux',
                'operation': 'set',
                'path': 'status',
                'value': 'Ready',
              },
            ],
          },
        ],
        'bodies': {
          'test': {
            't': 4,
            'type': 'text',
            'text': 'Action Center Body',
            'actionCenters': {
              'toolbar': {
                'label': 'Actions',
                'actionIds': [201],
              },
            },
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

      expect(
        find.byKey(const ValueKey('action-center-toolbar-201')),
        findsOneWidget,
      );
      expect(find.text('Mark Ready'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('action-center-toolbar-201')));
      await tester.pumpAndSettle();

      final autopilot = tester
          .element(find.text('Action Center Body'))
          .read<AutopilotGo>();
      expect(autopilot.resolve('ux.status'), equals('Ready'));
    });
  });
}
