import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/autopilotgo.dart';
import 'package:genrp/core/runtime/template_runtime.dart';

void main() {
  group('TemplateRuntime', () {
    testWidgets('renders the current small widget set from nodes', (tester) async {
      const runtime = TemplateRuntime();
      final autopilot = AutopilotGo();
      final node = {
        'type': 'column',
        'children': [
          {'type': 'text', 'text': 'First'},
          {'type': 'spacer', 'height': 10},
          {'type': 'text', 'text': 'Second'},
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: runtime.render(node, autopilot),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      final spacer = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(spacer.height, 10);
    });
  });
}
