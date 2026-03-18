import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/core/base/x.dart';
import 'package:genrp/core/agent/mock_transport.dart';

void main() {
  test('MockTransport saveRow returns a cloned row', () async {
    final row = X(v: ['Test', true]);
    final saved = await MockTransport.saveRow(row);

    expect(saved.v, equals(['Test', true]));
    // Should be a different instance
    expect(identical(saved, row), isFalse);
    expect(identical(saved.v, row.v), isFalse);
  });
}
