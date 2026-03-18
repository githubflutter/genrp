import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/app/aibook.dart';
import 'package:genrp/core/ux/bound_checkbox.dart';

void main() {
  testWidgets('AIBook renders spec-driven editor and preview flow', (tester) async {
    await tester.pumpWidget(const AIBookApp());
    await tester.pumpAndSettle();

    expect(find.text('Book Editor'), findsOneWidget);
    expect(find.text('Book Title'), findsOneWidget);
    expect(find.byType(BoundCheckbox), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'My Test Book');
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Status: Saved'), findsOneWidget);

    await tester.tap(find.text('Show Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Current Title: My Test Book'), findsOneWidget);
    expect(find.text('Saved Flag: true'), findsOneWidget);
  });
}
