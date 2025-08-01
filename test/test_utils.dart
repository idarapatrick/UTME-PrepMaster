import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:utme_prep_master/data/services/auth_service.dart';
import 'package:utme_prep_master/data/services/ai_service.dart';
import 'package:utme_prep_master/presentation/providers/user_state.dart';
import 'package:utme_prep_master/presentation/providers/theme_notifier.dart';
import 'package:utme_prep_master/presentation/providers/user_stats_provider.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}

class MockAIService extends Mock implements AIService {}

class MockUserState extends Mock implements UserState {}

class MockThemeNotifier extends Mock implements ThemeNotifier {}

class MockUserStatsProvider extends Mock implements UserStatsProvider {}

// Test widget wrapper with all necessary providers
class TestApp extends StatelessWidget {
  final Widget child;
  final AuthService? authService;
  final AIService? aiService;
  final UserState? userState;
  final ThemeNotifier? themeNotifier;
  final UserStatsProvider? userStatsProvider;

  const TestApp({
    super.key,
    required this.child,
    this.authService,
    this.aiService,
    this.userState,
    this.themeNotifier,
    this.userStatsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>.value(
          value: themeNotifier ?? MockThemeNotifier(),
        ),
        ChangeNotifierProvider<UserState>.value(
          value: userState ?? MockUserState(),
        ),
        ChangeNotifierProvider<UserStatsProvider>.value(
          value: userStatsProvider ?? MockUserStatsProvider(),
        ),
        Provider<AuthService>.value(value: authService ?? MockAuthService()),
        Provider<AIService>.value(value: aiService ?? MockAIService()),
      ],
      child: MaterialApp(
        home: child,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      ),
    );
  }
}

// Helper function to pump widget with test setup
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget widget, {
  AuthService? authService,
  AIService? aiService,
  UserState? userState,
  ThemeNotifier? themeNotifier,
  UserStatsProvider? userStatsProvider,
}) async {
  await tester.pumpWidget(
    TestApp(
      authService: authService,
      aiService: aiService,
      userState: userState,
      themeNotifier: themeNotifier,
      userStatsProvider: userStatsProvider,
      child: widget,
    ),
  );
}



// Helper function to find buttons by text
Finder findButtonByText(String text) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is ElevatedButton &&
        widget.child is Text &&
        (widget.child as Text).data == text,
  );
}

// Helper function to find text widgets by text
Finder findTextByText(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == text,
  );
}

// Helper function to wait for async operations
Future<void> waitForAsync(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

// Helper function to tap and wait
Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await waitForAsync(tester);
}

// Helper function to enter text and wait
Future<void> enterTextAndWait(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await waitForAsync(tester);
}
