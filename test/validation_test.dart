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

  test('AutopilotGo detects missing src or fieldId in fieldBindings', () {
    final autopilot = AutopilotGo();

    final specWithMissingFieldBindingKeys = {
      'id': 'test-3',
      'fieldBindings': [
        {'src': 1}, // missing fieldId
      ],
    };

    autopilot.configureSpec(specWithMissingFieldBindingKeys);
    expect(autopilot.specError, isNotNull);
    expect(
      autopilot.specError,
      contains('fieldBindings entry missing src or fieldId'),
    );
  });

  test('AutopilotGo detects body reference missing templateId', () {
    final autopilot = AutopilotGo();

    final specWithMissingTemplateId = {
      'id': 'test-4',
      'templates': [
        {'id': 1, 'name': 'form'},
      ],
      'bodies': {
        'test': {
          'templateId': 2, // missing from templates
        },
      },
    };

    autopilot.configureSpec(specWithMissingTemplateId);
    expect(autopilot.specError, isNotNull);
    expect(
      autopilot.specError,
      contains('body reference missing templateId 2 in templates list'),
    );
  });

  test('AutopilotGo detects body child reference missing actionId', () {
    final autopilot = AutopilotGo();

    final specWithMissingActionId = {
      'id': 'test-5',
      'actions': [
        {'id': 1, 'name': 'save'},
      ],
      'bodies': {
        'test': {
          'children': [
            {'actionId': 2}, // missing from actions
          ],
        },
      },
    };

    autopilot.configureSpec(specWithMissingActionId);
    expect(autopilot.specError, isNotNull);
    expect(
      autopilot.specError,
      contains('body child reference missing actionId 2 in actions list'),
    );
  });

  test('AutopilotGo detects body child reference missing typeId', () {
    final autopilot = AutopilotGo();

    final specWithMissingTypeId = {
      'id': 'test-6',
      'types': [
        {'id': 1, 'name': 'text'},
      ],
      'bodies': {
        'test': {
          'children': [
            {'typeId': 2}, // missing from types
          ],
        },
      },
    };

    autopilot.configureSpec(specWithMissingTypeId);
    expect(autopilot.specError, isNotNull);
    expect(
      autopilot.specError,
      contains('body child reference missing typeId 2 in types list'),
    );
  });
}
