# Architecture Documentation

## Overview

UTME PrepMaster follows **Clean Architecture** principles to ensure maintainability, testability, and scalability. The architecture is divided into three main layers with clear separation of concerns.

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   Screens   │  │  Widgets    │  │  Providers  │          │
│  │             │  │             │  │             │          │
│  │ • Home      │  │ • Loading   │  │ • Theme     │          │
│  │ • Auth      │  │ • Network   │  │ • UserStats │          │
│  │ • Settings  │  │ • XP Popup  │  │ • Network   │          │
│  │ • Tests     │  │ • Animations│  │ • Study     │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  Entities   │  │ Repositories │  │  Use Cases  │          │
│  │             │  │             │  │             │          │
│  │ • User      │  │ • AuthRepo  │  │ • Login     │          │
│  │ • Test      │  │ • TestRepo  │  │ • Register  │          │
│  │ • Progress  │  │ • UserRepo  │  │ • TakeTest  │          │
│  │ • Settings  │  │ • StatsRepo │  │ • UpdateXP  │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   Models    │  │ Repositories │  │  Services   │          │
│  │             │  │             │  │             │          │
│  │ • UserModel │  │ • AuthRepo  │  │ • Firebase  │          │
│  │ • TestModel │  │ • TestRepo  │  │ • AIService │          │
│  │ • StatsModel│  │ • UserRepo  │  │ • Network   │          │
│  │ • Settings  │  │ • StatsRepo │  │ • Storage   │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow

### 1. User Authentication Flow

```
User Input → Auth Screen → AuthService → Firebase Auth → UserStatsProvider → UI Update
     │           │            │              │              │
     ▼           ▼            ▼              ▼              ▼
  Email/Pass → Validation → Firebase → User Data → XP/Stats Display
```

### 2. Test Completion Flow

```
Test Screen → MockTestScreen → UserStatsProvider → FirestoreService → XP Popup → UI Update
     │             │               │                │              │
     ▼             ▼               ▼                ▼              ▼
  Submit Test → Calculate Score → Add XP → Save to DB → Show Animation → Update Stats
```

### 3. Theme Management Flow

```
Settings → ThemeNotifier → UserPreferencesService → SharedPreferences → Persist → UI Update
    │           │                │                    │              │
    ▼           ▼                ▼                    ▼              ▼
  Toggle → Notify Listeners → Save to Storage → Local Storage → Rebuild UI
```

## 🔄 State Management

### Provider Pattern Implementation

```dart
// Example: UserStatsProvider
class UserStatsProvider extends ChangeNotifier {
  int _xp = 0;
  int _streak = 0;
  
  int get xp => _xp;
  int get streak => _streak;
  
  Future<void> addXp(int amount, String reason) async {
    _xp += amount;
    await _saveToFirestore();
    notifyListeners(); // Triggers UI rebuild
  }
}
```

### Provider Setup in Main

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeNotifier()),
    ChangeNotifierProvider(create: (_) => UserStatsProvider()),
    ChangeNotifierProvider(create: (_) => NetworkProvider()),
    ChangeNotifierProvider(create: (_) => StudyPreferencesProvider()),
  ],
  child: MyApp(),
)
```

## 🧪 Testing Strategy

### Test Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        TEST LAYERS                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  Unit Tests │  │ Widget Tests│  │Integration  │          │
│  │             │  │             │  │   Tests     │          │
│  │ • Services  │  │ • Screens   │  │ • User Flow │          │
│  │ • Providers │  │ • Widgets   │  │ • Navigation│          │
│  │ • Models    │  │ • Forms     │  │ • State     │          │
│  │ • Utils     │  │ • Dialogs   │  │ • Network   │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### Test Coverage Targets

- **Unit Tests**: 80% coverage
- **Widget Tests**: All major screens
- **Integration Tests**: Critical user flows
- **Overall**: 70% minimum coverage

## 🔧 Error Handling Architecture

### Centralized Error Handling

```dart
class ErrorHandlerService {
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        await Future.delayed(delay * attempt);
      }
    }
  }
}
```

### Error Flow

```
User Action → Service Call → Error Handler → Retry Logic → UI Feedback
     │            │              │              │              │
     ▼            ▼              ▼              ▼              ▼
  Button Tap → API Call → Catch Exception → Retry 3x → Show SnackBar
```

## 🌐 Network Architecture

### Network-Aware Components

```dart
class NetworkAwareWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        if (!networkProvider.isConnected) {
          return NetworkStatusWidget();
        }
        return child!;
      },
    );
  }
}
```

### Network Flow

```
App Start → NetworkProvider → Connectivity Stream → UI Update → Service Calls
     │            │                │              │              │
     ▼            ▼                ▼              ▼              ▼
  Initialize → Monitor Network → Connection Change → Rebuild UI → Enable/Disable Features
```

## 📱 Platform Architecture

### Cross-Platform Support

```
┌─────────────────────────────────────────────────────────────────┐
│                    PLATFORM LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   Android   │  │     iOS     │  │     Web     │          │
│  │             │  │             │  │             │          │
│  │ • APK       │  │ • IPA       │  │ • PWA       │          │
│  │ • Firebase  │  │ • Firebase  │  │ • Firebase  │          │
│  │ • Permissions│ │ • Permissions│ │ • Service   │          │
│  │ • Icons     │  │ • Icons     │  │   Workers   │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

## 🔐 Security Architecture

### Authentication Flow

```
User Login → Firebase Auth → JWT Token → Secure Storage → API Calls
     │            │              │              │              │
     ▼            ▼              ▼              ▼              ▼
  Credentials → Validate → Generate Token → Store Locally → Include in Headers
```

### Data Protection

- **Firestore Security Rules**: Role-based access control
- **Input Validation**: Client and server-side validation
- **Error Messages**: No sensitive data exposure
- **Token Management**: Secure token storage and refresh

## 📊 Performance Architecture

### Optimization Strategies

1. **State Management**: Selective rebuilds with Provider
2. **Image Caching**: Efficient image loading and caching
3. **Lazy Loading**: Load content on demand
4. **Memory Management**: Proper disposal of resources
5. **Network Optimization**: Offline-first with sync

### Performance Monitoring

```dart
class PerformanceMonitor {
  static void trackScreenLoad(String screenName) {
    // Track screen load times
  }
  
  static void trackUserAction(String action) {
    // Track user interactions
  }
  
  static void trackError(String error) {
    // Track application errors
  }
}
```

## 🚀 Deployment Architecture

### Build Pipeline

```
Source Code → Flutter Build → Platform-Specific Build → Distribution
     │              │                │                    │
     ▼              ▼                ▼                    ▼
  Git Repo → Flutter Compile → Android/iOS/Web → App Store/Play Store
```

### Environment Configuration

- **Development**: Debug mode with hot reload
- **Staging**: Release mode with test data
- **Production**: Release mode with production data

## 📈 Scalability Considerations

### Horizontal Scaling

- **Firebase**: Automatic scaling for backend services
- **CDN**: Content delivery for static assets
- **Caching**: Local and remote caching strategies

### Vertical Scaling

- **Code Splitting**: Lazy loading of features
- **Memory Management**: Efficient resource usage
- **Performance Monitoring**: Continuous optimization

## 🔄 Migration Strategy

### Version Updates

1. **Backward Compatibility**: Maintain API compatibility
2. **Gradual Rollout**: Feature flags for new features
3. **Data Migration**: Automatic data schema updates
4. **User Communication**: Clear update notifications

---

This architecture ensures the app is maintainable, testable, and scalable while providing a great user experience across all platforms. 