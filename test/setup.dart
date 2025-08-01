import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:utme_prep_master/data/services/auth_service.dart';
import 'package:utme_prep_master/data/services/ai_service.dart';
import 'package:utme_prep_master/presentation/providers/user_state.dart';
import 'package:utme_prep_master/presentation/providers/theme_notifier.dart';
import 'package:utme_prep_master/presentation/providers/user_stats_provider.dart';
import 'package:utme_prep_master/presentation/providers/language_provider.dart';
import 'package:utme_prep_master/presentation/providers/study_preferences_provider.dart';
import 'package:utme_prep_master/presentation/providers/network_provider.dart';

// Mock Firebase App for testing
class MockFirebaseApp extends Mock implements FirebaseApp {}

// Mock Firebase Auth for testing
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Mock Firebase Firestore for testing
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Mock User for testing
class MockUser extends Mock implements User {}

// Mock DocumentReference for testing
class MockDocumentReference extends Mock implements DocumentReference {}

// Mock CollectionReference for testing
class MockCollectionReference extends Mock implements CollectionReference {}

// Mock classes for providers
class MockThemeNotifier extends Mock implements ThemeNotifier {}
class MockUserState extends Mock implements UserState {}
class MockUserStatsProvider extends Mock implements UserStatsProvider {}
class MockLanguageProvider extends Mock implements LanguageProvider {}
class MockStudyPreferencesProvider extends Mock implements StudyPreferencesProvider {}
class MockNetworkProvider extends Mock implements NetworkProvider {}
class MockAuthService extends Mock implements AuthService {}
class MockAIService extends Mock implements AIService {}

// Setup Firebase for testing
Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Create mock Firebase app
  final mockApp = MockFirebaseApp();
  final mockAuth = MockFirebaseAuth();
  final mockFirestore = MockFirebaseFirestore();
  
  // Mock Firebase initialization
  when(mockApp.name).thenReturn('[DEFAULT]');
  when(mockApp.options).thenReturn(const FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: 'test-sender-id',
    projectId: 'test-project-id',
    storageBucket: 'test-project-id.appspot.com',
  ));
  
  // Mock Firebase Auth instance
  when(mockAuth.app).thenReturn(mockApp);
  
  // Mock Firebase Firestore instance
  when(mockFirestore.app).thenReturn(mockApp);
  
  // Mock Firebase Auth instance
  when(mockAuth.app).thenReturn(mockApp);
  
  // Mock Firebase Firestore instance
  when(mockFirestore.app).thenReturn(mockApp);
  
  // Mock Firebase.initializeApp to return our mock app
  // This prevents the actual Firebase initialization in tests
  // Note: In a real test environment, you might want to use a test Firebase project
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

// Global test setup function
Future<void> testMain(Future<void> Function() testMain) async {
  await setupFirebaseForTesting();
  await testMain();
} 