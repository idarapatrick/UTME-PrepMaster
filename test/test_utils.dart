import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utme_prep_master/data/services/auth_service.dart';
import 'package:utme_prep_master/data/services/ai_service.dart';
import 'package:utme_prep_master/presentation/providers/user_state.dart';
import 'package:utme_prep_master/presentation/providers/theme_notifier.dart';
import 'package:utme_prep_master/presentation/providers/user_stats_provider.dart';
import 'package:utme_prep_master/presentation/providers/language_provider.dart';
import 'package:utme_prep_master/presentation/providers/study_preferences_provider.dart';
import 'package:utme_prep_master/presentation/providers/network_provider.dart';
import 'widget/ai_tutor_screen_test.mocks.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockUserState extends Mock implements UserState {}
class MockThemeNotifier extends Mock implements ThemeNotifier {}
class MockUserStatsProvider extends Mock implements UserStatsProvider {}
class MockLanguageProvider extends Mock implements LanguageProvider {}
class MockStudyPreferencesProvider extends Mock implements StudyPreferencesProvider {}
class MockNetworkProvider extends Mock implements NetworkProvider {}

// Firebase mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockCollectionReference extends Mock implements CollectionReference {}

// Note: Firebase setup is now handled in setup.dart

// Mock Firebase App
class MockFirebaseApp extends Mock implements FirebaseApp {}

// Test widget wrapper with all necessary providers
class TestApp extends StatelessWidget {
  final Widget child;
  final AuthService? authService;
  final AIService? aiService;
  final UserState? userState;
  final ThemeNotifier? themeNotifier;
  final UserStatsProvider? userStatsProvider;
  final LanguageProvider? languageProvider;
  final StudyPreferencesProvider? studyPreferencesProvider;
  final NetworkProvider? networkProvider;

  const TestApp({
    super.key,
    required this.child,
    this.authService,
    this.aiService,
    this.userState,
    this.themeNotifier,
    this.userStatsProvider,
    this.languageProvider,
    this.studyPreferencesProvider,
    this.networkProvider,
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
        ChangeNotifierProvider<LanguageProvider>.value(
          value: languageProvider ?? MockLanguageProvider(),
        ),
        ChangeNotifierProvider<StudyPreferencesProvider>.value(
          value: studyPreferencesProvider ?? MockStudyPreferencesProvider(),
        ),
        ChangeNotifierProvider<NetworkProvider>.value(
          value: networkProvider ?? MockNetworkProvider(),
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
  LanguageProvider? languageProvider,
  StudyPreferencesProvider? studyPreferencesProvider,
  NetworkProvider? networkProvider,
}) async {
  await tester.pumpWidget(
    TestApp(
      authService: authService,
      aiService: aiService,
      userState: userState,
      themeNotifier: themeNotifier,
      userStatsProvider: userStatsProvider,
      languageProvider: languageProvider,
      studyPreferencesProvider: studyPreferencesProvider,
      networkProvider: networkProvider,
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

// Helper function to create mock user
User createMockUser({
  String uid = 'test-uid',
  String email = 'test@example.com',
  String displayName = 'Test User',
  bool emailVerified = true,
}) {
  final mockUser = MockUser();
  when(mockUser.uid).thenReturn(uid);
  when(mockUser.email).thenReturn(email);
  when(mockUser.displayName).thenReturn(displayName);
  when(mockUser.emailVerified).thenReturn(emailVerified);
  return mockUser;
}

// Helper function to create mock Firestore document
DocumentReference createMockDocumentReference({
  String path = 'users/test-uid',
}) {
  final mockDoc = MockDocumentReference();
  when(mockDoc.path).thenReturn(path);
  return mockDoc;
}

// Helper function to create mock Firestore collection
CollectionReference createMockCollectionReference({
  String path = 'users',
}) {
  final mockCollection = MockCollectionReference();
  when(mockCollection.path).thenReturn(path);
  return mockCollection;
}
