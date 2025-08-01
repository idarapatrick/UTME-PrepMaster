import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:utme_prep_master/presentation/screens/auth/auth_screen.dart';
import 'package:utme_prep_master/data/services/auth_service.dart';
import 'package:utme_prep_master/presentation/providers/network_provider.dart';
import 'package:utme_prep_master/presentation/providers/theme_notifier.dart';
import 'package:utme_prep_master/presentation/theme/app_theme.dart';

@GenerateMocks([AuthService, NetworkProvider])
import 'auth_screen_test.mocks.dart';

void main() {
  group('Auth Screen Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockNetworkProvider mockNetworkProvider;

    setUp(() {
      mockAuthService = MockAuthService();
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
          child: const AuthScreen(),
        ),
      );
    }

    testWidgets('should display auth screen with sign in form', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue your learning journey'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
    });

    testWidgets('should switch to sign up form when sign up button is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap sign up button
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join us and start your learning journey'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3)); // Name, email, and password fields
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextField).first, 'invalid-email');
      await tester.pumpAndSettle();

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - should show validation error
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should validate password length', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter short password
      await tester.enterText(find.byType(TextField).last, '123');
      await tester.pumpAndSettle();

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - should show validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should validate required fields in sign up form', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to sign up form
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Try to sign up without filling fields
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Assert - should show validation errors
      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('should show loading state during authentication', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAuthService.signInWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return AuthResult.success(message: 'Success');
      });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pumpAndSettle();

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle successful sign in', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAuthService.signInWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => AuthResult.success(message: 'Welcome back!'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pumpAndSettle();

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - should show success message
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('should handle authentication error', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAuthService.signInWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => AuthResult.failure('Invalid credentials'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpassword');
      await tester.pumpAndSettle();

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should handle Google sign in', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => AuthResult.success(message: 'Google sign in successful'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Google sign in button
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      // Assert - should show success message
      expect(find.text('Google sign in successful'), findsOneWidget);
    });

    testWidgets('should handle forgot password', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);
      when(mockAuthService.resetPassword(any)).thenAnswer((_) async => AuthResult.success(message: 'Password reset email sent'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap forgot password link
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pumpAndSettle();

      // Tap reset button
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Assert - should show success message
      expect(find.text('Password reset email sent'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pumpAndSettle();

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      // Assert - should show password
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should handle network connectivity issues', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(false);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - should show network error
      expect(find.text('No Internet Connection'), findsOneWidget);
    });

    testWidgets('should validate password strength in sign up', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to sign up form
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Enter weak password
      await tester.enterText(find.byType(TextField).last, 'weak');
      await tester.pumpAndSettle();

      // Tap sign up button
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Assert - should show password strength error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should handle form submission with empty fields', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to sign in without entering credentials
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - should show validation errors
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('should handle keyboard navigation', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on email field
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.pumpAndSettle();

      // Press tab to move to password field
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pumpAndSettle();

      // Assert - both fields should have content
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('should handle special characters in email', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter email with special characters
      await tester.enterText(find.byType(TextField).first, 'test+tag@example.com');
      await tester.pumpAndSettle();

      // Assert - should accept valid email with special characters
      expect(find.text('test+tag@example.com'), findsOneWidget);
    });

    testWidgets('should handle long input text', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkProvider.isConnected).thenReturn(true);
      when(mockNetworkProvider.isInitialized).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to sign up form
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Enter long name
      const longName = 'This is a very long name that should be handled properly by the form validation system';
      await tester.enterText(find.byType(TextField).first, longName);
      await tester.pumpAndSettle();

      // Assert - should handle long text
      expect(find.text(longName), findsOneWidget);
    });
  });
}
