import 'package:flutter_test/flutter_test.dart';
import 'package:genrp/main.dart';

void main() {
  testWidgets('main launcher opens AICodex in one direction', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Choose App'), findsOneWidget);
    expect(find.text('AIBook'), findsOneWidget);
    expect(find.text('AICodex'), findsOneWidget);
    expect(find.text('AIStudio'), findsOneWidget);

    await tester.tap(find.text('AICodex'));
    await tester.pump();

    expect(find.text('Schema Source'), findsOneWidget);
    expect(find.text('Master/Main Editor'), findsOneWidget);
    expect(find.text('Choose App'), findsNothing);
    expect(find.text('AIBook'), findsNothing);
    expect(find.text('AIStudio'), findsNothing);
  });
}
