import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aibook/autopilotgo.dart';

void main() {
  test('AutopilotGo detects duplicate ids in registry', () {
    final autopilot = AutopilotGo();

    final specWithDuplicates = {
      'id': 'test-1',
      'bodiesRegistry': [
        {'id': 1, 'name': 'editor'},
        {'id': 1, 'name': 'preview'},
      ],
    };

    autopilot.configureSpec(specWithDuplicates);
    expect(autopilot.specError, isNotNull);
    expect(
      autopilot.specError,
      contains('Duplicate id 1 found in bodiesRegistry'),
    );
  });

  test('AutopilotGo does not set specError on valid spec', () {
    final autopilot = AutopilotGo();

    final specValid = {
      'id': 'test-2',
      'bodies': {
        'editor': {'bodyId': 1, 't': 4, 'type': 'text', 'text': 'Editor'},
        'preview': {'bodyId': 2, 't': 3, 'type': 'text', 'text': 'Preview'},
      },
    };

    autopilot.configureSpec(specValid);
    expect(autopilot.specError, isNull);
  });

  test('AutopilotGo detects missing fieldBinding src or fieldId', () {
    final autopilot = AutopilotGo();

    final spec = {
      'id': 'test-3',
      'fieldBindings': [
        {'src': 0}, // Missing fieldId/f
      ],
    };

    autopilot.configureSpec(spec);
    expect(autopilot.specError, equals('fieldBinding missing src or fieldId'));
  });

  test('AutopilotGo detects invalid actionId in body child', () {
    final autopilot = AutopilotGo();

    final spec = {
      'id': 'test-4',
      'actions': [
        {'id': 100, 'name': 'save'},
      ],
      'bodies': {
        'editor': {
          'bodyId': 1,
          't': 4,
          'type': 'column',
          'children': [
            {'actionId': 999}, // Invalid
          ],
        },
      },
    };

    autopilot.configureSpec(spec);
    expect(autopilot.specError, equals('Invalid actionId 999 in body child'));
  });

  test('AutopilotGo detects invalid template type in body', () {
    final autopilot = AutopilotGo();

    final spec = {
      'id': 'test-5',
      'templates': [
        {'id': 200, 'name': 'form'},
      ],
      'bodies': {
        'editor': {
          'bodyId': 1,
          't': 888, // Invalid
        },
      },
    };

    autopilot.configureSpec(spec);
    expect(autopilot.specError, equals('Unknown template type 888 in body'));
  });

  test('AutopilotGo detects invalid typeId in body child', () {
    final autopilot = AutopilotGo();

    final spec = {
      'id': 'test-6',
      'types': [
        {'id': 300, 'name': 'text'},
      ],
      'bodies': {
        'editor': {
          'bodyId': 1,
          't': 4,
          'type': 'column',
          'children': [
            {'typeId': 777}, // Invalid
          ],
        },
      },
    };

    autopilot.configureSpec(spec);
    expect(autopilot.specError, equals('Invalid typeId 777 in body child'));
  });

  test('AutopilotGo detects unknown template mode in body', () {
    final autopilot = AutopilotGo();

    final spec = {
      'id': 'test-7',
      'bodies': {
        'collection': {
          'bodyId': 1,
          't': 2,
          'm': [9],
        },
      },
    };

    autopilot.configureSpec(spec);
    expect(autopilot.specError, equals('Unknown template mode 9 in body'));
  });

  test('AutopilotGo detects unsupported mode for template type', () {
    final autopilot = AutopilotGo();

    final spec = {
      'id': 'test-8',
      'bodies': {
        'detail': {
          'bodyId': 1,
          't': 3,
          'm': [1],
        },
      },
    };

    autopilot.configureSpec(spec);
    expect(
      autopilot.specError,
      equals('Mode 1 is not supported by template type 3'),
    );
  });

  test('AutopilotGo detects invalid actionId in action center', () {
    final autopilot = AutopilotGo();

    final spec = {
      'id': 'test-9',
      'actions': [
        {'id': 1, 'name': 'save'},
      ],
      'bodies': {
        'editor': {
          'bodyId': 1,
          't': 4,
          'type': 'text',
          'text': 'Editor',
          'actionCenters': {
            'toolbar': {
              'actionIds': [999],
            },
          },
        },
      },
    };

    autopilot.configureSpec(spec);
    expect(
      autopilot.specError,
      equals('Invalid actionId 999 in action center'),
    );
  });
}
