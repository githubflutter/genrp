import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/agent/state_set.dart';

void main() {
  test('StateSet partitions chrome, body, and template state', () {
    final state = StateSet();

    state.set('status', 'Ready');
    state.set('body.1.filter', 'books');
    state.set('template.0.1.sort', 'name');
    state.set('mode.0.1', 2);
    state.set('selection.0.1', 3);
    state.set('selections.0.1', <int>[1, 3]);

    expect(state.get('status'), equals('Ready'));
    expect(state.get('body.1.filter'), equals('books'));
    expect(state.get('template.0.1.sort'), equals('name'));
    expect(state.get('mode.0.1'), equals(2));
    expect(state.get('selection.0.1'), equals(3));
    expect(state.get('selections.0.1'), equals(<int>[1, 3]));

    final snapshot = state.snapshot();
    expect(
      snapshot,
      equals({
        'chrome': {'status': 'Ready'},
        'bodies': {
          '1': {'filter': 'books'},
        },
        'templates': {
          '0.1': {
            'sort': 'name',
            'mode': 2,
            'selection': 3,
            'selections': <int>[1, 3],
          },
        },
      }),
    );
  });

  test('StateSet clears previous body and template scopes on body switch', () {
    final state = StateSet();

    state.set('currentBody', 1);
    state.set('status', 'Editing');
    state.set('body.1.filter', 'alpha');
    state.set('mode.0.1', 2);
    state.set('selection.0.1', 5);
    state.set('body.2.filter', 'beta');
    state.set('template.0.2.sort', 'title');

    state.set('currentBody', 2);

    expect(state.get('currentBody'), equals(2));
    expect(state.get('status'), equals('Editing'));
    expect(state.get('body.1.filter'), isNull);
    expect(state.get('mode.0.1'), isNull);
    expect(state.get('selection.0.1'), isNull);
    expect(state.get('body.2.filter'), equals('beta'));
    expect(state.get('template.0.2.sort'), equals('title'));
  });
}
