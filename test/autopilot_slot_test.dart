import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/autopilotgo.dart';
import 'package:genrp/core/base/x.dart';

void main() {
  test('Autopilot resolves and updates by slot first', () {
    final autopilot = AutopilotGo();
    autopilot.registerFieldSlot(1, 101, 0);
    autopilot.registerFieldSlot(1, 102, 1);

    // Set initial X data
    autopilot.copilotData.setValue('x_row', X(v: ['Title', false]));

    // Read by slot
    final title = autopilot.resolveFieldBinding(src: 1, fieldId: 101);
    expect(title, 'Title');

    final saved = autopilot.resolveFieldBinding(src: 1, fieldId: 102);
    expect(saved, false);

    // Update by slot
    autopilot.updateFieldBinding(src: 1, fieldId: 101, value: 'New Title');
    final updatedX = autopilot.copilotData.getValue('x_row') as X;
    expect(updatedX.v[0], 'New Title');
  });

  test('Autopilot slot update extends list if too short', () {
    final autopilot = AutopilotGo();
    autopilot.registerFieldSlot(1, 101, 2);
    autopilot.copilotData.setValue('x_row', X(v: []));

    autopilot.updateFieldBinding(src: 1, fieldId: 101, value: 'Extended');
    final updatedX = autopilot.copilotData.getValue('x_row') as X;
    expect(updatedX.v.length, 3);
    expect(updatedX.v[2], 'Extended');
  });
}
