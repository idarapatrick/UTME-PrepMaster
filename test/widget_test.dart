// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:utme_prep_master/main.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app renders without throwing exceptions
    expect(tester.takeException(), isNull);
  });
}
