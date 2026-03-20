import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aibook/autopilotgo.dart';

void main() {
  test(
    'Autopilot resetRuntime clears data, ux state, bindings, and actions',
    () {
      final autopilot = AutopilotGo();
      autopilot.configureSpec({
        'id': 'reset-spec',
        'initialState': {'currentBody': 1, 'status': 'Ready'},
        'initialData': {'book.title': 'Reset Test'},
        'fieldBindings': [
          {'src': 1, 'fieldId': 101, 'path': 'data.book.title'},
        ],
        'actions': [
          {'id': 7, 'n': 'Save', 'name': 'saveBook', 'todos': const []},
        ],
        'bodies': {
          'editor': {'bodyId': 1, 't': 4, 'type': 'text', 'text': 'Editor'},
        },
      });

      autopilot.selectUxIdentity(
        hostId: 1,
        bodyId: 2,
        widgetId: 3,
        notify: false,
      );

      expect(autopilot.resolve('data.book.title'), equals('Reset Test'));
      expect(autopilot.resolve('ux.status'), equals('Ready'));
      expect(autopilot.hasAction(7), isTrue);
      expect(
        autopilot.resolveFieldBinding(src: 1, fieldId: 101),
        equals('Reset Test'),
      );

      autopilot.resetRuntime(notify: false);

      expect(autopilot.resolve('data.book.title'), isNull);
      expect(autopilot.resolve('ux.status'), isNull);
      expect(autopilot.hasAction(7), isFalse);
      expect(autopilot.selectedHostId, isNull);
      expect(autopilot.selectedBodyId, isNull);
      expect(autopilot.selectedWidgetId, isNull);
      expect(autopilot.resolveFieldBinding(src: 1, fieldId: 101), isNull);
    },
  );

  test('Copilot clear helpers clear only their own store', () {
    final autopilot = AutopilotGo();
    autopilot.copilotData.patch({'a': 1}, notify: false);
    autopilot.copilotUX.patch({'b': 2}, notify: false);

    autopilot.copilotData.clear(notify: false);
    expect(autopilot.resolve('a'), isNull);
    expect(autopilot.resolve('ux.b'), equals(2));

    autopilot.copilotUX.clear(notify: false);
    expect(autopilot.resolve('ux.b'), isNull);
  });
}
