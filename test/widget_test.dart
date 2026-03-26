import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagme/app/app.dart';

void main() {
  testWidgets('TagMeApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TagMeApp()),
    );

    // Verify the app renders with the map placeholder screen
    expect(find.text('Map'), findsWidgets);
  });
}
