import 'package:flutter_test/flutter_test.dart';
import 'package:novaide/constants/app_constants.dart';
import 'package:novaide/main.dart';

void main() {
  testWidgets('Mingo IDE App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MingoIDEApp());
    await tester.pump();

    // Verify that Mingo IDE brand is rendered.
    expect(find.text(AppConstants.appName), findsWidgets);
  });
}
