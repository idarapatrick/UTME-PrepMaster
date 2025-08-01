import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utme_prep_master/presentation/screens/home_screen.dart';
import '../test_utils.dart';
import '../setup.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    setUpAll(() async {
      await setupFirebaseForTesting();
    });

    testWidgets('should display home screen with basic elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(TestApp(child: const HomeScreen()));

      // Should display basic UI elements
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display cards', (WidgetTester tester) async {
      await tester.pumpWidget(TestApp(child: const HomeScreen()));

      // Should display cards
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should display buttons', (WidgetTester tester) async {
      await tester.pumpWidget(TestApp(child: const HomeScreen()));

      // Should display buttons
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should display icons', (WidgetTester tester) async {
      await tester.pumpWidget(TestApp(child: const HomeScreen()));

      // Should display icons
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should handle button taps', (WidgetTester tester) async {
      await tester.pumpWidget(TestApp(child: const HomeScreen()));

      // Find and tap buttons
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pump();

        // Should not throw exceptions
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('should handle card taps', (WidgetTester tester) async {
      await tester.pumpWidget(TestApp(child: const HomeScreen()));

      // Find and tap cards
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pump();

        // Should not throw exceptions
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('should display text elements', (WidgetTester tester) async {
      await tester.pumpWidget(TestApp(child: const HomeScreen()));

      // Should display text elements
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should handle scroll behavior', (WidgetTester tester) async {
      await tester.pumpWidget(TestApp(child: const HomeScreen()));

      // Should be scrollable
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should handle widget disposal gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(TestApp(child: const HomeScreen()));

      // Dispose widget
      await tester.pumpWidget(const SizedBox());

      // Should not throw any exceptions
      expect(tester.takeException(), isNull);
    });
  });
}
