import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:utme_prep_master/presentation/screens/ai_tutor_screen.dart';
import 'package:utme_prep_master/data/services/ai_service.dart';
import 'package:utme_prep_master/presentation/providers/network_provider.dart';
import 'package:utme_prep_master/presentation/providers/theme_notifier.dart';
import 'package:utme_prep_master/presentation/theme/app_theme.dart';

@GenerateMocks([AIService, NetworkProvider])
import 'ai_tutor_screen_test.mocks.dart';

void main() {
  group('AI Tutor Screen Widget Tests', () {
    late MockAIService mockAIService;
    late MockNetworkProvider mockNetworkProvider;

    setUp(() {
      mockAIService = MockAIService();
      mockNetworkProvider = MockNetworkProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeNotifier>.value(
              value: ThemeNotifier(),
            ),
            ChangeNotifierProvider<NetworkProvider>.value(
              value: mockNetworkProvider,
            ),
          ],
          child: const AiTutorScreen(),
        ),
      );
    }

    testWidgets('should display AI Tutor screen with welcome message', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('AI Tutor'), findsOneWidget);
      expect(find.text('Hello! I\'m your AI tutor. I can help you with any UTME subject. What would you like to learn today?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should display subject dropdown with correct options', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on dropdown to open it
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Chemistry'), findsOneWidget);
      expect(find.text('Biology'), findsOneWidget);
      expect(find.text('Economics'), findsOneWidget);
      expect(find.text('Literature'), findsOneWidget);
      expect(find.text('Government'), findsOneWidget);
    });

    testWidgets('should change selected subject when dropdown item is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select English
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('English'), findsWidgets);
    });

    testWidgets('should not send empty message', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to send empty message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Hello! I\'m your AI tutor. I can help you with any UTME subject. What would you like to learn today?'), findsOneWidget);
      // Should only have the welcome message, no additional messages
      expect(find.byType(ChatMessage), findsOneWidget);
    });

    testWidgets('should send message and display user message', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async => 'This is a test response');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter message
      await tester.enterText(find.byType(TextField), 'What is calculus?');
      await tester.pumpAndSettle();

      // Send message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('What is calculus?'), findsOneWidget);
    });

    testWidgets('should show typing indicator when AI is responding', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return 'This is a test response';
      });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter and send message
      await tester.enterText(find.byType(TextField), 'What is calculus?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Assert - should show typing indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display AI response after typing indicator', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async => 'Calculus is a branch of mathematics...');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter and send message
      await tester.enterText(find.byType(TextField), 'What is calculus?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Calculus is a branch of mathematics...'), findsOneWidget);
    });

    testWidgets('should scroll to bottom when new message is added', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async => 'Test response');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Add multiple messages to create scrollable content
      for (int i = 0; i < 5; i++) {
        await tester.enterText(find.byType(TextField), 'Message $i');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
      }

      // Assert - should be able to scroll
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should handle network connectivity changes', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(false);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - should show network error
      expect(find.text('No Internet Connection'), findsOneWidget);
    });

    testWidgets('should show error message when AI service fails', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenThrow(Exception('Service unavailable'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter and send message
      await tester.enterText(find.byType(TextField), 'What is calculus?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Assert - should show error message
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    });

    testWidgets('should clear text field after sending message', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async => 'Test response');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter message
      await tester.enterText(find.byType(TextField), 'What is calculus?');
      await tester.pumpAndSettle();

      // Verify text is entered
      expect(find.text('What is calculus?'), findsOneWidget);

      // Send message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Assert - text field should be cleared
      expect(find.text('What is calculus?'), findsOneWidget); // Only in the message list, not in text field
    });

    testWidgets('should handle long messages properly', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async => 'Test response');

      const longMessage = 'This is a very long message that should be handled properly by the AI tutor screen. '
          'It contains multiple sentences and should be displayed correctly in the chat interface. '
          'The message should wrap properly and not cause any layout issues.';

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter long message
      await tester.enterText(find.byType(TextField), longMessage);
      await tester.pumpAndSettle();

      // Send message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(longMessage), findsOneWidget);
    });

    testWidgets('should maintain chat history when navigating back and forth', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async => 'Test response');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'What is calculus?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Navigate away (simulate by rebuilding widget)
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - should still have the message
      expect(find.text('What is calculus?'), findsOneWidget);
    });

    testWidgets('should handle rapid message sending', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async => 'Test response');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Send multiple messages rapidly
      for (int i = 0; i < 3; i++) {
        await tester.enterText(find.byType(TextField), 'Message $i');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Assert - should handle all messages
      expect(find.text('Message 0'), findsOneWidget);
      expect(find.text('Message 1'), findsOneWidget);
      expect(find.text('Message 2'), findsOneWidget);
    });

    testWidgets('should display correct timestamp for messages', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async => 'Test response');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'What is calculus?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Assert - should have timestamp
      expect(find.byType(ChatMessage), findsWidgets);
    });

    testWidgets('should handle special characters in messages', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAIService.getAIResponse(any)).thenAnswer((_) async => 'Test response');

      const specialMessage = 'What is 2 + 2 = 4? And what about π (pi)?';

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter message with special characters
      await tester.enterText(find.byType(TextField), specialMessage);
      await tester.pumpAndSettle();

      // Send message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(specialMessage), findsOneWidget);
    });
  });
}
