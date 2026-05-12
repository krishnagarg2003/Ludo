import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/main.dart';

void main() {
  testWidgets('Ludo app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LudoApp());

    // Verify that our app shows the title.
    expect(find.text('LUDO'), findsOneWidget);
    expect(find.text('CHAMPIONS'), findsOneWidget);
  });
}
