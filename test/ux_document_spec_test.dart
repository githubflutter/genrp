import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/model/uschema/ux_document_spec.dart';

void main() {
  test('UxSpecDocument parses typed template and action specs', () {
    final document = UxSpecDocument.fromJson({
      'id': 'typed-doc',
      'toolbar': {'title': 'Typed UX'},
      'initialBody': 1,
      'templates': [
        {'id': 4, 'name': 'form'},
      ],
      'types': [
        {'id': 1, 'name': 'column'},
        {'id': 3, 'name': 'textField'},
        {'id': 4, 'name': 'button'},
      ],
      'actions': [
        {
          'id': 7,
          'name': 'saveRow',
          'todos': [
            {
              'id': 'todo-1',
              'type': 'ux',
              'operation': 'set',
              'path': 'status',
              'value': 'Saved',
            },
          ],
        },
      ],
      'bodies': {
        'editor': {
          'bodyId': 1,
          't': 4,
          'typeId': 1,
          'children': [
            {'widgetId': 10, 'typeId': 3, 'label': 'Name', 'src': 1, 'f': 100},
            {'widgetId': 11, 'typeId': 4, 'text': 'Save', 'actionId': 7},
          ],
          'actionCenters': {
            'toolbar': {
              'label': 'Main Actions',
              'actionIds': [7],
            },
          },
        },
      },
    });

    final body = document.resolveBody(1);
    expect(document.toolbarTitle, equals('Typed UX'));
    expect(document.actions.single.name, equals('saveRow'));
    expect(body, isNotNull);
    expect(body!.templateType, equals('form'));
    expect(body.root.type, equals('column'));
    expect(body.root.children.first.type, equals('textField'));
    expect(body.root.children.last.actionId, equals(7));
    expect(body.actionCenters['toolbar']?.actionIds, equals([7]));
  });

  test('UxSpecDocument supports nested registry normalization', () {
    final document = UxSpecDocument.fromJson({
      'initialBody': 2,
      'registry': {
        'templates': [
          {'id': 3, 'name': 'detail'},
        ],
        'types': [
          {'id': 5, 'name': 'text'},
        ],
        'bodies': [
          {'id': 2, 'name': 'preview'},
        ],
      },
      'bodies': {
        'preview': {'bodyId': 2, 't': 3, 'typeId': 5, 'text': 'Preview Body'},
      },
    });

    final body = document.resolveBody(2);
    expect(body, isNotNull);
    expect(body!.templateType, equals('detail'));
    expect(body.root.type, equals('text'));
    expect(body.root.text, equals('Preview Body'));
  });
}
