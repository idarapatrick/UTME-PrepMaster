import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

// Mock classes for Firebase
class MockFirebaseApp extends Mock implements FirebaseApp {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockCollectionReference extends Mock implements CollectionReference {}

// Global test setup
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Create mock Firebase instances
  final mockApp = MockFirebaseApp();
  final mockAuth = MockFirebaseAuth();
  final mockFirestore = MockFirebaseFirestore();
  
  // Setup mock Firebase app
  when(mockApp.name).thenReturn('[DEFAULT]');
  when(mockApp.options).thenReturn(const FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: 'test-sender-id',
    projectId: 'test-project-id',
    storageBucket: 'test-project-id.appspot.com',
  ));
  
  // Setup mock Firebase Auth
  when(mockAuth.app).thenReturn(mockApp);
  
  // Setup mock Firebase Firestore
  when(mockFirestore.app).thenReturn(mockApp);
  
  // Mock Firebase.initializeApp to prevent actual initialization
  // This is a workaround since we can't directly mock static methods
  // The actual mocking will be done in the service classes
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