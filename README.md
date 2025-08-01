# UTME PrepMaster

A comprehensive Flutter application designed to help students prepare for the UTME (Unified Tertiary Matriculation Examination) in Nigeria. The app provides study materials, practice tests, progress tracking, and AI-powered tutoring.

## Link to download the APK file:
[APK Link](https://drive.google.com/drive/folders/1px3tQjKW9lKaJlcC2B-KxIy9nXc5DGf9?usp=drive_link)

## 📱 Features

- **Authentication System**: Secure login/signup with email verification
- **Study Materials**: Access to comprehensive study resources and PDFs
- **Practice Tests**: CBT (Computer-Based Test) and quiz functionality
- **Progress Tracking**: XP system, streaks, and achievement badges
- **AI Tutor**: Intelligent tutoring system for personalized learning
- **User Preferences**: Theme, language, and study preferences
- **Offline Support**: Network-aware functionality with graceful error handling
- **Cross-Platform**: Works on Android, iOS, Web, Windows, and macOS

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/utme-prep-master.git
   cd utme-prep-master
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and place configuration files:
     - `google-services.json` in `android/app/`
     - `GoogleService-Info.plist` in `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Clean Architecture Pattern

The app follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── data/                    # Data Layer
│   ├── models/             # Data models
│   ├── repositories/       # Repository implementations
│   └── services/          # External services (Firebase, API)
├── domain/                 # Domain Layer
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/         # Business logic
└── presentation/          # Presentation Layer
    ├── providers/         # State management
    ├── screens/          # UI screens
    └── widgets/          # Reusable widgets
```

### State Management

We use **Provider** with **ChangeNotifier** for state management:

- **Why Provider?**: Simple, lightweight, and follows Flutter's recommended patterns
- **Benefits**: 
  - Easy to test and debug
  - Minimal boilerplate code
  - Great performance with selective rebuilds
  - Clear separation of concerns

### Key Components

- **ThemeNotifier**: Manages app theme (light/dark mode)
- **UserStatsProvider**: Handles XP, streaks, and user progress
- **NetworkProvider**: Monitors network connectivity
- **StudyPreferencesProvider**: Manages study settings and preferences

## 📊 Code Quality & Testing

### Current Status

#### Flutter Analyze Results
```
0 issues found (6.7s)
```


#### Flutter Test Results
```
All tests passed (40 tests)
```


### Design Principles

- **Responsive Design**: Works on all screen sizes
- **Dark/Light Theme**: User preference with persistence
- **Loading States**: Smooth user experience during async operations
- **Error Handling**: User-friendly error messages and retry mechanisms
- **Accessibility**: Screen reader support and keyboard navigation

## 🔧 Configuration

### Environment Setup

1. **Firebase Configuration**
   ```dart
   // lib/firebase_options.dart
   // Generated from Firebase CLI
   ```

2. **App Icons**
   ```yaml
   # pubspec.yaml
   flutter_launcher_icons:
     android: "launcher_icon"
     ios: true
     image_path: "assets/icons/app_icon.png"
   ```

3. **Dependencies**
   ```yaml
   # Key dependencies
   firebase_core: ^4.0.0
   firebase_auth: ^6.0.0
   cloud_firestore: ^6.0.0
   provider: ^6.1.2
   shared_preferences: ^2.2.2
   connectivity_plus: ^5.0.2
   ```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Run tests and analysis**
   ```bash
   flutter test
   flutter analyze
   ```
5. **Commit your changes**
   ```bash
   git commit -m "feat: add your feature description"
   ```
6. **Push to your branch**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**

### Code Style Guidelines

- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comprehensive comments for complex logic
- Write tests for new features
- Ensure all tests pass before submitting PR

### Commit Message Format

```
type(scope): description

Examples:
feat(auth): add email verification
fix(ui): resolve theme persistence issue
docs(readme): update setup instructions
test(provider): add unit tests for UserStatsProvider
```

## 📚 API Documentation

### Authentication Service
```dart
class AuthService {
  /// Signs in user with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  
  /// Registers new user
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password);
  
  /// Sends email verification
  Future<void> sendEmailVerification();
}
```

### User Stats Provider
```dart
class UserStatsProvider extends ChangeNotifier {
  /// Awards XP for completing activities
  Future<void> addXp(int amount, String reason);
  
  /// Completes CBT test with XP popup
  Future<void> completeCbtTestWithPopup({
    required String testId,
    required int score,
    required int totalQuestions,
  });
}
```

### Error Handler Service
```dart
class ErrorHandlerService {
  /// Executes operation with retry mechanism
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  });
  
  /// Shows error snackbar
  static void showErrorSnackBar(BuildContext context, String message);
}
```

## 🏆 Achievements & Progress

### XP System
- **CBT Completion**: +260 XP
- **Quiz Completion**: +50 XP per correct answer
- **Study Sessions**: +10 XP per 30 minutes
- **Streak Bonuses**: +25 XP for 7-day streak

### Badges
- **First Steps**: Complete first quiz
- **Scholar**: Complete 10 study sessions
- **Master**: Achieve 1000 XP
- **Streak Master**: Maintain 30-day streak

## 🔒 Security

- **Firebase Authentication**: Secure user authentication
- **Firestore Security Rules**: Data access control
- **Input Validation**: Client and server-side validation
- **Error Handling**: Secure error messages (no sensitive data exposure)

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web
- ✅ Windows
- ✅ macOS

## 🐛 Known Issues

1. **BuildContext Usage**: Some async operations need context handling
2. **Print Statements**: Remove debug prints from production code

## 📈 Performance

- **App Size**: Optimized for minimal download size
- **Memory Usage**: Efficient state management
- **Network**: Offline-first approach with sync
- **Battery**: Optimized for mobile devices

## 📞 Support

- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions


**Built with ❤️ for Nigerian students preparing for UTME**
