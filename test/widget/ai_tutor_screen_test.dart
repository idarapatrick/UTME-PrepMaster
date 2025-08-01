import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utme_prep_master/presentation/screens/ai_tutor_screen.dart';

void main() {
  group('AiTutorScreen Widget Tests', () {
    testWidgets('should display AI tutor screen with basic elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Should display basic UI elements
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display chat interface', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Should display chat interface
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display text input field', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Should display text input field
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display send button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Should display send button
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should allow text input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Find text field and enter text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Hello AI Tutor');
      await tester.pump();

      expect(find.text('Hello AI Tutor'), findsOneWidget);
    });

    testWidgets('should handle send button tap', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Tap send button
      final sendButton = find.byIcon(Icons.send);
      await tester.tap(sendButton);
      await tester.pump();

      // Should not throw exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display icons', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Should display icons
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should handle long text input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Enter a long message
      final textField = find.byType(TextField);
      final longMessage = 'A' * 500; // Very long message
      await tester.enterText(textField, longMessage);
      await tester.pump();

      // Should handle long text without errors
      expect(find.text(longMessage), findsOneWidget);
    });

    testWidgets('should handle keyboard interaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Tap on text field to show keyboard
      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();

      // Enter text
      await tester.enterText(textField, 'Test message');
      await tester.pump();
    });

    testWidgets('should handle widget disposal gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const AiTutorScreen()));

      // Dispose widget
      await tester.pumpWidget(const SizedBox());

      // Should not throw any exceptions
      expect(tester.takeException(), isNull);
    });
  });
}
