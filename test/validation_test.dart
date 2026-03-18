import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/autopilotgo.dart';

void main() {
  test('AutopilotGo detects duplicate ids in registry', () {
    final autopilot = AutopilotGo();

    final specWithDuplicates = {
      'id': 'test-1',
      'bodiesRegistry': [
        {'id': 1, 'name': 'editor'},
        {'id': 1, 'name': 'preview'}
      ]
    };

    autopilot.configureSpec(specWithDuplicates);
    expect(autopilot.specError, isNotNull);
    expect(autopilot.specError, contains('Duplicate id 1 found in bodiesRegistry'));
  });

  test('AutopilotGo does not set specError on valid spec', () {
    final autopilot = AutopilotGo();

    final specValid = {
      'id': 'test-2',
      'bodiesRegistry': [
        {'id': 1, 'name': 'editor'},
        {'id': 2, 'name': 'preview'}
      ]
    };

    autopilot.configureSpec(specValid);
    expect(autopilot.specError, isNull);
  });
}
