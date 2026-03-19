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
      'bodiesRegistry': [
        {'id': 1, 'name': 'editor'},
        {'id': 2, 'name': 'preview'},
      ],
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
      'bodiesRegistry': [
        {
          'id': 1,
          'children': [
            {'actionId': 999}, // Invalid
          ],
        },
      ],
    };

    autopilot.configureSpec(spec);
    expect(autopilot.specError, equals('Invalid actionId 999 in body child'));
  });

  test('AutopilotGo detects invalid templateId in body', () {
    final autopilot = AutopilotGo();

    final spec = {
      'id': 'test-5',
      'templates': [
        {'id': 200, 'name': 'form'},
      ],
      'bodiesRegistry': [
        {
          'id': 1,
          'templateId': 888, // Invalid
        },
      ],
    };

    autopilot.configureSpec(spec);
    expect(autopilot.specError, equals('Invalid templateId 888 in body'));
  });

  test('AutopilotGo detects invalid typeId in body child', () {
    final autopilot = AutopilotGo();

    final spec = {
      'id': 'test-6',
      'types': [
        {'id': 300, 'name': 'text'},
      ],
      'bodiesRegistry': [
        {
          'id': 1,
          'children': [
            {'typeId': 777}, // Invalid
          ],
        },
      ],
    };

    autopilot.configureSpec(spec);
    expect(autopilot.specError, equals('Invalid typeId 777 in body child'));
  });
}
