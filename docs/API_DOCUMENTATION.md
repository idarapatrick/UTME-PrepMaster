# API Documentation

## Overview

This document provides comprehensive API documentation for the UTME PrepMaster application. It covers all services, providers, and key methods used throughout the application.

## 📚 Table of Contents

1. [Authentication Services](#authentication-services)
2. [User Management](#user-management)
3. [Test & Quiz Services](#test--quiz-services)
4. [Progress Tracking](#progress-tracking)
5. [AI Services](#ai-services)
6. [Storage Services](#storage-services)
7. [Network Services](#network-services)
8. [State Management](#state-management)
9. [Error Handling](#error-handling)
10. [Utility Services](#utility-services)

---

## 🔐 Authentication Services

### AuthService

Handles user authentication using Firebase Authentication.

#### Methods

```dart
class AuthService {
  /// Signs in user with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// 
  /// Returns [UserCredential] on success
  /// Throws [FirebaseAuthException] on failure
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);

  /// Registers new user with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// 
  /// Returns [UserCredential] on success
  /// Throws [FirebaseAuthException] on failure
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password);

  /// Sends email verification to current user
  /// 
  /// Throws [FirebaseAuthException] if user is not logged in
  Future<void> sendEmailVerification();

  /// Signs out current user
  /// 
  /// Clears all authentication state
  Future<void> signOut();

  /// Gets current user
  /// 
  /// Returns [User?] - current user or null if not authenticated
  User? get currentUser;

  /// Stream of authentication state changes
  /// 
  /// Returns [Stream<User?>] - stream of user authentication state
  Stream<User?> get authStateChanges;
}
```

#### Usage Example

```dart
// Sign in user
try {
  final userCredential = await authService.signInWithEmailAndPassword(
    'user@example.com',
    'password123'
  );
  print('User signed in: ${userCredential.user?.email}');
} catch (e) {
  print('Sign in failed: $e');
}

// Listen to auth state changes
authService.authStateChanges.listen((User? user) {
  if (user != null) {
    print('User is signed in: ${user.email}');
  } else {
    print('User is signed out');
  }
});
```

---

## 👤 User Management

### UserPreferencesService

Manages user preferences using SharedPreferences for local storage.

#### Methods

```dart
class UserPreferencesService {
  /// Saves theme mode preference
  /// 
  /// [isDark] - true for dark mode, false for light mode
  static Future<void> saveThemeMode(bool isDark);

  /// Loads theme mode preference
  /// 
  /// Returns [bool] - true for dark mode, false for light mode
  /// Defaults to false (light mode)
  static Future<bool> loadThemeMode();

  /// Saves language preference
  /// 
  /// [languageCode] - language code (e.g., 'en', 'fr')
  static Future<void> saveLanguage(String languageCode);

  /// Loads language preference
  /// 
  /// Returns [String] - language code
  /// Defaults to 'en'
  static Future<String> loadLanguage();

  /// Saves daily reminder time
  /// 
  /// [time] - TimeOfDay for daily reminder
  static Future<void> saveDailyReminderTime(TimeOfDay time);

  /// Loads daily reminder time
  /// 
  /// Returns [TimeOfDay] - saved reminder time
  /// Defaults to 9:00 AM
  static Future<TimeOfDay> loadDailyReminderTime();

  /// Saves study session duration
  /// 
  /// [duration] - duration in minutes
  static Future<void> saveStudySessionDuration(int duration);

  /// Loads study session duration
  /// 
  /// Returns [int] - duration in minutes
  /// Defaults to 30 minutes
  static Future<int> loadStudySessionDuration();

  /// Saves notification settings
  /// 
  /// [enabled] - true to enable notifications
  static Future<void> saveNotificationsEnabled(bool enabled);

  /// Loads notification settings
  /// 
  /// Returns [bool] - notification enabled state
  /// Defaults to true
  static Future<bool> loadNotificationsEnabled();

  /// Saves sound settings
  /// 
  /// [enabled] - true to enable sounds
  static Future<void> saveSoundEnabled(bool enabled);

  /// Loads sound settings
  /// 
  /// Returns [bool] - sound enabled state
  /// Defaults to true
  static Future<bool> loadSoundEnabled();
}
```

#### Usage Example

```dart
// Save theme preference
await UserPreferencesService.saveThemeMode(true);

// Load theme preference
final isDarkMode = await UserPreferencesService.loadThemeMode();

// Save study preferences
await UserPreferencesService.saveDailyReminderTime(TimeOfDay(hour: 9, minute: 0));
await UserPreferencesService.saveStudySessionDuration(45);
await UserPreferencesService.saveNotificationsEnabled(true);
```

---

## 📝 Test & Quiz Services

### MockTestScreen

Handles CBT (Computer-Based Test) functionality.

#### Methods

```dart
class MockTestScreen extends StatefulWidget {
  /// Completes a CBT test and awards XP
  /// 
  /// [testId] - unique identifier for the test
  /// [score] - user's score on the test
  /// [totalQuestions] - total number of questions
  /// 
  /// Awards 260 XP for test completion
  Future<void> completeCbtTest({
    required String testId,
    required int score,
    required int totalQuestions,
  });

  /// Calculates test score percentage
  /// 
  /// [correctAnswers] - number of correct answers
  /// [totalQuestions] - total number of questions
  /// 
  /// Returns [double] - percentage score (0.0 to 100.0)
  double calculateScorePercentage(int correctAnswers, int totalQuestions);

  /// Validates test submission
  /// 
  /// [answers] - map of question IDs to selected answers
  /// [totalQuestions] - total number of questions
  /// 
  /// Returns [bool] - true if all questions are answered
  bool validateTestSubmission(Map<String, String> answers, int totalQuestions);
}
```

#### Usage Example

```dart
// Complete a CBT test
await completeCbtTest(
  testId: 'math_test_001',
  score: 15,
  totalQuestions: 20,
);

// Calculate score percentage
final percentage = calculateScorePercentage(15, 20); // Returns 75.0

// Validate submission
final isValid = validateTestSubmission(answers, 20);
if (isValid) {
  // Submit test
}
```

---

## 📊 Progress Tracking

### UserStatsProvider

Manages user statistics, XP, and achievements using ChangeNotifier.

#### Properties

```dart
class UserStatsProvider extends ChangeNotifier {
  /// Current user XP
  int get xp;

  /// Current user streak
  int get streak;

  /// Current user level
  int get level;

  /// List of user badges
  List<String> get badges;

  /// Last XP earned
  int get lastXpEarned;

  /// Whether to show XP animation
  bool get showXpAnimation;

  /// User's study statistics
  Map<String, dynamic> get studyStats;
}
```

#### Methods

```dart
class UserStatsProvider extends ChangeNotifier {
  /// Awards XP for completing activities
  /// 
  /// [amount] - XP amount to award
  /// [reason] - reason for XP award (e.g., 'cbt_completion', 'quiz_correct')
  /// 
  /// Triggers UI update via notifyListeners()
  Future<void> addXp(int amount, String reason);

  /// Completes CBT test with XP popup
  /// 
  /// [testId] - unique test identifier
  /// [score] - user's score
  /// [totalQuestions] - total questions in test
  /// 
  /// Awards 260 XP and shows popup animation
  Future<void> completeCbtTestWithPopup({
    required String testId,
    required int score,
    required int totalQuestions,
  });

  /// Updates user streak
  /// 
  /// [newStreak] - new streak count
  /// 
  /// Triggers UI update and saves to Firestore
  Future<void> updateStreak(int newStreak);

  /// Adds badge to user
  /// 
  /// [badgeId] - unique badge identifier
  /// 
  /// Triggers UI update and saves to Firestore
  Future<void> addBadge(String badgeId);

  /// Loads user stats from Firestore
  /// 
  /// Called on app startup
  Future<void> loadUserStats();

  /// Saves user stats to Firestore
  /// 
  /// Called when stats are updated
  Future<void> saveUserStats();
}
```

#### Usage Example

```dart
// Award XP for quiz completion
await userStatsProvider.addXp(50, 'quiz_correct');

// Complete CBT test with popup
await userStatsProvider.completeCbtTestWithPopup(
  testId: 'math_test_001',
  score: 18,
  totalQuestions: 20,
);

// Update streak
await userStatsProvider.updateStreak(7);

// Add badge
await userStatsProvider.addBadge('first_quiz');

// Listen to changes
Consumer<UserStatsProvider>(
  builder: (context, userStats, child) {
    return Text('XP: ${userStats.xp}');
  },
);
```

---

## 🤖 AI Services

### AIService

Provides AI-powered tutoring functionality.

#### Methods

```dart
class AIService {
  /// Gets AI response for user query
  /// 
  /// [message] - user's question or query
  /// [context] - additional context (optional)
  /// 
  /// Returns [String] - AI-generated response
  /// Throws [NetworkException] on network error
  Future<String> getAIResponse(String message, {String? context});

  /// Gets personalized study recommendations
  /// 
  /// [userStats] - user's current statistics
  /// [weakAreas] - areas where user needs improvement
  /// 
  /// Returns [List<String>] - list of recommendations
  Future<List<String>> getStudyRecommendations(
    Map<String, dynamic> userStats,
    List<String> weakAreas,
  );

  /// Analyzes test performance
  /// 
  /// [testResults] - user's test results
  /// 
  /// Returns [Map<String, dynamic>] - performance analysis
  Future<Map<String, dynamic>> analyzeTestPerformance(
    Map<String, dynamic> testResults,
  );

  /// Generates practice questions
  /// 
  /// [subject] - subject area
  /// [difficulty] - question difficulty level
  /// [count] - number of questions to generate
  /// 
  /// Returns [List<Map<String, dynamic>>] - list of questions
  Future<List<Map<String, dynamic>>> generatePracticeQuestions(
    String subject,
    String difficulty,
    int count,
  );
}
```

#### Usage Example

```dart
// Get AI response
try {
  final response = await aiService.getAIResponse(
    'Explain quadratic equations',
    context: 'Mathematics, UTME preparation',
  );
  print('AI Response: $response');
} catch (e) {
  print('AI Service error: $e');
}

// Get study recommendations
final recommendations = await aiService.getStudyRecommendations(
  userStats,
  ['Mathematics', 'Physics'],
);

// Generate practice questions
final questions = await aiService.generatePracticeQuestions(
  'Mathematics',
  'medium',
  10,
);
```

---

## 💾 Storage Services

### FirestoreService

Manages Firestore database operations.

#### Methods

```dart
class FirestoreService {
  /// Saves user data to Firestore
  /// 
  /// [userId] - user's unique identifier
  /// [data] - user data to save
  /// 
  /// Throws [FirebaseException] on database error
  Future<void> saveUserData(String userId, Map<String, dynamic> data);

  /// Loads user data from Firestore
  /// 
  /// [userId] - user's unique identifier
  /// 
  /// Returns [Map<String, dynamic>] - user data
  /// Throws [FirebaseException] on database error
  Future<Map<String, dynamic>> loadUserData(String userId);

  /// Saves test results
  /// 
  /// [userId] - user's unique identifier
  /// [testId] - test identifier
  /// [results] - test results data
  /// 
  /// Throws [FirebaseException] on database error
  Future<void> saveTestResults(
    String userId,
    String testId,
    Map<String, dynamic> results,
  );

  /// Loads test results
  /// 
  /// [userId] - user's unique identifier
  /// [testId] - test identifier
  /// 
  /// Returns [Map<String, dynamic>] - test results
  /// Throws [FirebaseException] on database error
  Future<Map<String, dynamic>> loadTestResults(String userId, String testId);

  /// Saves user notes
  /// 
  /// [userId] - user's unique identifier
  /// [note] - note data
  /// 
  /// Returns [String] - note ID
  /// Throws [FirebaseException] on database error
  Future<String> saveNote(String userId, Map<String, dynamic> note);

  /// Loads user notes
  /// 
  /// [userId] - user's unique identifier
  /// 
  /// Returns [List<Map<String, dynamic>>] - list of notes
  /// Throws [FirebaseException] on database error
  Future<List<Map<String, dynamic>>> loadNotes(String userId);

  /// Deletes user note
  /// 
  /// [userId] - user's unique identifier
  /// [noteId] - note identifier
  /// 
  /// Throws [FirebaseException] on database error
  Future<void> deleteNote(String userId, String noteId);

  /// Updates user progress
  /// 
  /// [userId] - user's unique identifier
  /// [progress] - progress data
  /// 
  /// Throws [FirebaseException] on database error
  Future<void> updateUserProgress(String userId, Map<String, dynamic> progress);
}
```

#### Usage Example

```dart
// Save user data
await firestoreService.saveUserData(userId, {
  'xp': 1250,
  'streak': 7,
  'level': 5,
  'badges': ['first_quiz', 'week_streak'],
});

// Load user data
final userData = await firestoreService.loadUserData(userId);
print('User XP: ${userData['xp']}');

// Save test results
await firestoreService.saveTestResults(userId, 'math_test_001', {
  'score': 18,
  'totalQuestions': 20,
  'timeSpent': 1800, // seconds
  'completedAt': FieldValue.serverTimestamp(),
});

// Save note
final noteId = await firestoreService.saveNote(userId, {
  'title': 'Math Notes',
  'content': 'Quadratic equations...',
  'subject': 'Mathematics',
  'createdAt': FieldValue.serverTimestamp(),
});

// Load notes
final notes = await firestoreService.loadNotes(userId);
```

---

## 🌐 Network Services

### NetworkProvider

Monitors network connectivity and provides network status.

#### Properties

```dart
class NetworkProvider extends ChangeNotifier {
  /// Whether device is connected to internet
  bool get isConnected;

  /// Current connection type
  String get connectionType;

  /// Connection quality indicator
  String get connectionQuality;

  /// Network status message
  String get statusMessage;
}
```

#### Methods

```dart
class NetworkProvider extends ChangeNotifier {
  /// Initializes network monitoring
  /// 
  /// Starts listening to connectivity changes
  Future<void> initializeNetworkMonitoring();

  /// Checks current network status
  /// 
  /// Updates internal state and notifies listeners
  Future<void> checkNetworkStatus();

  /// Disposes network monitoring
  /// 
  /// Cancels connectivity stream subscription
  @override
  void dispose();
}
```

#### Usage Example

```dart
// Listen to network changes
Consumer<NetworkProvider>(
  builder: (context, networkProvider, child) {
    if (!networkProvider.isConnected) {
      return NetworkStatusWidget();
    }
    return child!;
  },
);

// Check network status
await networkProvider.checkNetworkStatus();
print('Connected: ${networkProvider.isConnected}');
print('Connection type: ${networkProvider.connectionType}');
```

---

## 🔄 State Management

### ThemeNotifier

Manages application theme state.

#### Properties

```dart
class ThemeNotifier extends ChangeNotifier {
  /// Whether dark mode is enabled
  bool get isDarkMode;

  /// Current theme mode
  ThemeMode get themeMode;
}
```

#### Methods

```dart
class ThemeNotifier extends ChangeNotifier {
  /// Toggles between light and dark mode
  /// 
  /// Saves preference to SharedPreferences
  Future<void> toggleTheme();

  /// Initializes theme from saved preferences
  /// 
  /// Called on app startup
  Future<void> initializeTheme();

  /// Synchronous theme initialization
  /// 
  /// Used for immediate theme setup
  void initializeThemeSync(bool isDark);
}
```

#### Usage Example

```dart
// Toggle theme
await themeNotifier.toggleTheme();

// Listen to theme changes
Consumer<ThemeNotifier>(
  builder: (context, themeNotifier, child) {
    return Icon(
      icon: themeNotifier.isDarkMode 
        ? Icons.light_mode 
        : Icons.dark_mode,
    );
  },
);
```

---

## ⚠️ Error Handling

### ErrorHandlerService

Provides centralized error handling and retry mechanisms.

#### Methods

```dart
class ErrorHandlerService {
  /// Executes operation with retry mechanism
  /// 
  /// [operation] - operation to execute
  /// [maxRetries] - maximum number of retry attempts (default: 3)
  /// [delay] - delay between retries (default: 2 seconds)
  /// 
  /// Returns [T] - operation result
  /// Throws [Exception] after all retries fail
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  });

  /// Shows error snackbar
  /// 
  /// [context] - build context
  /// [message] - error message to display
  static void showErrorSnackBar(BuildContext context, String message);

  /// Shows loading dialog
  /// 
  /// [context] - build context
  /// [message] - loading message
  static void showLoadingDialog(BuildContext context, String message);

  /// Hides loading dialog
  /// 
  /// [context] - build context
  static void hideLoadingDialog(BuildContext context);

  /// Shows retry dialog
  /// 
  /// [context] - build context
  /// [message] - error message
  /// [onRetry] - retry callback function
  static void showRetryDialog(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  );
}
```

#### Usage Example

```dart
// Execute with retry
try {
  final result = await ErrorHandlerService.executeWithRetry(
    () => apiService.fetchData(),
    maxRetries: 3,
    delay: Duration(seconds: 2),
  );
  print('Success: $result');
} catch (e) {
  ErrorHandlerService.showErrorSnackBar(context, 'Failed to load data');
}

// Show loading dialog
ErrorHandlerService.showLoadingDialog(context, 'Loading...');

// Hide loading dialog
ErrorHandlerService.hideLoadingDialog(context);

// Show retry dialog
ErrorHandlerService.showRetryDialog(
  context,
  'Network error. Please try again.',
  () => retryOperation(),
);
```

---

## 🛠️ Utility Services

### NotificationService

Manages in-app notifications.

#### Methods

```dart
class NotificationService {
  /// Shows in-app notification
  /// 
  /// [title] - notification title
  /// [message] - notification message
  /// [type] - notification type (info, success, warning, error)
  static void showNotification(
    String title,
    String message, {
    NotificationType type = NotificationType.info,
  });

  /// Schedules daily reminder
  /// 
  /// [time] - reminder time
  /// [message] - reminder message
  static Future<void> scheduleDailyReminder(TimeOfDay time, String message);

  /// Cancels daily reminder
  static Future<void> cancelDailyReminder();

  /// Shows study reminder
  /// 
  /// [subject] - study subject
  /// [duration] - study duration in minutes
  static void showStudyReminder(String subject, int duration);
}
```

### UsernameService

Manages username generation and validation.

#### Methods

```dart
class UsernameService {
  /// Generates unique username
  /// 
  /// [email] - user's email address
  /// 
  /// Returns [String] - generated username
  static Future<String> generateUsername(String email);

  /// Validates username
  /// 
  /// [username] - username to validate
  /// 
  /// Returns [bool] - true if valid
  static bool validateUsername(String username);

  /// Checks if username is available
  /// 
  /// [username] - username to check
  /// 
  /// Returns [bool] - true if available
  static Future<bool> isUsernameAvailable(String username);
}
```

---

## 📋 Error Codes

### Firebase Auth Errors

| Error Code | Description | Solution |
|------------|-------------|----------|
| `user-not-found` | User doesn't exist | Check email spelling |
| `wrong-password` | Incorrect password | Verify password |
| `email-already-in-use` | Email already registered | Use different email or sign in |
| `weak-password` | Password too weak | Use stronger password |
| `invalid-email` | Invalid email format | Check email format |

### Network Errors

| Error Code | Description | Solution |
|------------|-------------|----------|
| `network-error` | No internet connection | Check network connection |
| `timeout` | Request timeout | Retry operation |
| `server-error` | Server error | Try again later |

### Validation Errors

| Error Code | Description | Solution |
|------------|-------------|----------|
| `invalid-input` | Invalid input data | Check input format |
| `required-field` | Missing required field | Fill all required fields |
| `invalid-format` | Invalid data format | Use correct format |

---

## 🔧 Configuration

### Environment Variables

```dart
// Firebase configuration
const String firebaseApiKey = 'your-api-key';
const String firebaseProjectId = 'your-project-id';
const String firebaseMessagingSenderId = 'your-sender-id';

// AI Service configuration
const String aiServiceUrl = 'https://api.example.com/ai';
const String aiServiceKey = 'your-ai-service-key';

// App configuration
const String appName = 'UTME PrepMaster';
const String appVersion = '1.0.0';
const int minSdkVersion = 21;
```

### Build Configuration

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/logos/
    - assets/icons/
    - assets/pdfs/
    - assets/screens/
    - assets/avatars/

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 21
```

---

This API documentation provides comprehensive coverage of all services and methods used in the UTME PrepMaster application. For additional details or specific implementation questions, please refer to the source code or contact the development team. 