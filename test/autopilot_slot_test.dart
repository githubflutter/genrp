import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aibook/autopilotgo.dart';
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

  test('Autopilot uses path fallback when slot is missing', () {
    final autopilot = AutopilotGo();
    autopilot.registerFieldPath(1, 101, 'data.custom_field');
    autopilot.copilotData.setValue('custom_field', 'Path Value');

    // Read by path fallback
    final value = autopilot.resolveFieldBinding(src: 1, fieldId: 101);
    expect(value, 'Path Value');

    // Update by path fallback
    autopilot.updateFieldBinding(src: 1, fieldId: 101, value: 'New Path Value');
    expect(autopilot.copilotData.getValue('custom_field'), 'New Path Value');
  });

  test('Autopilot ignores path when slot exists', () {
    final autopilot = AutopilotGo();
    autopilot.registerFieldSlot(1, 101, 0);
    autopilot.registerFieldPath(1, 101, 'data.custom_field');
    autopilot.copilotData.setValue('x_row', X(v: ['Slot Value']));
    autopilot.copilotData.setValue('custom_field', 'Path Value');

    // Read prefers slot over path
    final value = autopilot.resolveFieldBinding(src: 1, fieldId: 101);
    expect(value, 'Slot Value');

    // Update prefers slot over path
    autopilot.updateFieldBinding(src: 1, fieldId: 101, value: 'New Slot Value');
    final updatedX = autopilot.copilotData.getValue('x_row') as X;
    expect(updatedX.v[0], 'New Slot Value');
    expect(autopilot.copilotData.getValue('custom_field'), 'Path Value'); // Path should not be updated
  });
}
