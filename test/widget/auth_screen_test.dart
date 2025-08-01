import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utme_prep_master/presentation/screens/auth/auth_screen.dart';

void main() {
  group('AuthScreen Widget Tests', () {
    testWidgets('should display auth screen with basic elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const AuthScreen()));

      // Should display basic UI elements
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display text input fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const AuthScreen()));

      // Should display input fields
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should display buttons', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AuthScreen()));

      // Should display buttons
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should allow text input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AuthScreen()));

      // Find text fields and enter text
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.pump();

        expect(find.text('test@example.com'), findsOneWidget);
      }
    });

    testWidgets('should handle button taps', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AuthScreen()));

      // Find and tap buttons
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pump();

        // Should not throw exceptions
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('should display icons', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AuthScreen()));

      // Should display icons
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should handle widget disposal gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const AuthScreen()));

      // Dispose widget
      await tester.pumpWidget(const SizedBox());

      // Should not throw any exceptions
      expect(tester.takeException(), isNull);
    });
  });
}
