/// UTME PrepMaster - Main Application Entry Point
/// 
/// This file serves as the main entry point for the UTME PrepMaster application.
/// It handles Firebase initialization, provider setup, theme management, and
/// authentication state management.
/// 
/// Key Responsibilities:
/// - Initialize Firebase services
/// - Set up Provider state management
/// - Configure app theme and preferences
/// - Handle authentication flow
/// - Define app routes and navigation

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'config/firebase_options.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/auth/otp_verification_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/badges_screen.dart';
import 'presentation/screens/phone_verification_screen.dart';
import 'presentation/screens/ai_tutor_screen.dart';
import 'presentation/screens/mock_test_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/subject_selection_screen.dart';
import 'presentation/providers/user_state.dart';
import 'presentation/providers/subject_state.dart';
import 'presentation/providers/test_state.dart';
import 'presentation/providers/theme_notifier.dart';
import 'presentation/providers/user_stats_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/study_preferences_provider.dart';
import 'presentation/providers/network_provider.dart';
import 'presentation/screens/life_at_intro_screen.dart';
import 'presentation/screens/study_partner_screen.dart';
import 'presentation/screens/notes_screen.dart';
import 'presentation/screens/links_screen.dart';
import 'presentation/screens/admin/question_upload_screen.dart';
import 'presentation/screens/admin/developer_panel_screen.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'presentation/screens/auth/admin_auth_screen.dart';
import 'presentation/screens/course_content_screen.dart';
import 'presentation/screens/leaderboard_screen.dart';
import 'presentation/screens/edit_profile_screen.dart';
import 'presentation/screens/my_library_screen.dart';
import 'presentation/screens/auth/google_signup_completion_screen.dart';
import 'presentation/screens/auth/email_verification_screen.dart';
import 'presentation/screens/auth/username_setup_screen.dart';
import 'presentation/screens/notifications_screen.dart';
import 'presentation/screens/language_selection_screen.dart';
import 'presentation/screens/study_preferences_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main application entry point
/// 
/// Initializes Firebase, sets up providers, and starts the application.
/// This function is called when the app is launched.
void main() async {
  // Ensure Flutter bindings are initialized for platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling for duplicate initialization
  // This prevents crashes when Firebase is already initialized (e.g., hot reload)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle duplicate Firebase initialization gracefully
    if (e.toString().contains('duplicate-app')) {
      // Firebase is already initialized, continue without error
    } else {
      // Re-throw other Firebase initialization errors
      rethrow;
    }
  }

  // Configure Firestore for offline support and unlimited cache
  // This enables the app to work offline and cache data locally
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Enable offline persistence
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Unlimited cache size
  );

  // Load user's theme preference from local storage
  // Defaults to light mode if no preference is saved
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('theme_mode') ?? false;

  // Start the application with Provider setup for state management
  // Each provider manages a specific aspect of the app's state
  runApp(
    MultiProvider(
      providers: [
        // Theme management - handles light/dark mode switching
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier()..initializeThemeSync(isDarkMode),
        ),
        // User state management - handles user authentication and profile
        ChangeNotifierProvider(create: (_) => UserState()),
        // Subject state management - handles selected subjects and progress
        ChangeNotifierProvider(create: (_) => SubjectState()),
        // Test state management - handles current test session
        ChangeNotifierProvider(create: (_) => TestState()),
        // User statistics - handles XP, streaks, badges, and progress
        ChangeNotifierProvider(create: (_) => UserStatsProvider()),
        // Language preferences - handles app language selection
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        // Study preferences - handles study settings and reminders
        ChangeNotifierProvider(create: (_) => StudyPreferencesProvider()),
        // Network connectivity - monitors internet connection status
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Main application widget that sets up the MaterialApp
/// 
/// This widget configures the app's theme, routes, and initial screen.
/// It uses Provider to access the theme notifier for dynamic theme switching.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the theme notifier to get current theme mode
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    
    return MaterialApp(
      title: 'UTME PrepMaster',
      theme: AppTheme.lightTheme, // Light theme configuration
      darkTheme: AppTheme.darkTheme, // Dark theme configuration
      themeMode: themeNotifier.themeMode, // Dynamic theme mode based on user preference
      debugShowCheckedModeBanner: false, // Hide debug banner in release
      home: const AuthGate(), // Initial screen that handles authentication flow
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/otp-verification': (context) => OtpVerificationScreen(),
        '/email-verification': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return EmailVerificationScreen(
              email: args['email'] as String?,
              isNewUser: args['isNewUser'] as bool? ?? false,
            );
          } else if (args is String) {
            return EmailVerificationScreen(email: args);
          } else {
            return const EmailVerificationScreen();
          }
        },
        '/onboarding': (context) => const OnboardingScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/badges': (context) => const BadgesScreen(),
        '/phone-verification': (context) => const PhoneVerificationScreen(),
        '/ai-tutor': (context) => const AiTutorScreen(),
        '/mock-test': (context) => const MockTestScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
        '/subject-selection': (context) => const SubjectSelectionScreen(),
        '/life-at-intro': (context) => const LifeAtIntroScreen(),
        '/study-partner': (context) => const StudyPartnerScreen(),
        '/notes': (context) => const NotesScreen(),
        '/links': (context) => const LinksScreen(),
        '/course-content': (context) {
          final subject =
              ModalRoute.of(context)!.settings.arguments as String? ??
              'Mathematics';
          return CourseContentScreen(subject: subject);
        },
        '/admin/upload-questions': (context) => const QuestionUploadScreen(),
        '/admin/developer-panel': (context) => const DeveloperPanelScreen(),
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/admin/auth': (context) => const AdminAuthScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/my-library': (context) => const MyLibraryScreen(),
        '/google-signup-completion': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as User;
          return GoogleSignupCompletionScreen(googleUser: args);
        },
        '/username-setup': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return UsernameSetupScreen(user: args['user'] as User);
        },
        '/notifications': (context) => const NotificationsScreen(),
        '/language-selection': (context) => const LanguageSelectionScreen(),
        '/study-preferences': (context) => const StudyPreferencesScreen(),
      },
    );
  }
}

/// Authentication gate widget that handles app initialization and authentication flow
/// 
/// This widget determines which screen to show based on:
/// - App initialization status
/// - User authentication state
/// - Onboarding completion status
/// - Email verification status
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

/// State class for AuthGate widget
/// 
/// Manages app initialization, authentication state, and navigation logic
class _AuthGateState extends State<AuthGate> {
  /// Whether the app is still initializing (shows splash screen)
  bool _isInitializing = true;
  
  /// Whether the user has completed onboarding
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initializes the application and sets up providers
  /// 
  /// This method:
  /// - Waits for Firebase to fully initialize
  /// - Checks onboarding status from SharedPreferences
  /// - Initializes providers in the background
  /// - Handles any initialization errors gracefully
  Future<void> _initializeApp() async {
    try {
      // Give Firebase time to fully initialize before proceeding
      // This prevents authentication state issues during app startup
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check if user has completed onboarding from local storage
      // New users will see onboarding, returning users skip it
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // Initialize providers after the widget is built
      // This ensures context is available for provider initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          // Initialize user statistics provider
          final userStatsProvider = Provider.of<UserStatsProvider>(
            context,
            listen: false,
          );
          userStatsProvider.initializeUserStats();

          // Initialize network connectivity monitoring
          final networkProvider = Provider.of<NetworkProvider>(
            context,
            listen: false,
          );
          networkProvider.initialize();
        } catch (e) {
          // Gracefully handle provider initialization errors
          // These errors don't prevent the app from starting
        }
      });
    } catch (e) {
      // Handle any initialization errors gracefully
      // The app will still start even if some initialization fails
    } finally {
      // Always mark initialization as complete
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while app is initializing
    if (_isInitializing) {
      return const SplashScreen();
    }

    // Listen to Firebase authentication state changes
    // This automatically updates the UI when user signs in/out
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash screen while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Show onboarding for new users who haven't completed it
        if (!_hasSeenOnboarding) {
          return const OnboardingScreen();
        }

        // Handle authenticated users
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          // Google Sign-In users are automatically verified
          // Send them directly to the home screen
          if (user.providerData.isNotEmpty &&
              user.providerData.first.providerId == 'google.com') {
            return const HomeScreen();
          }

          // For email/password users, check email verification status
          if (user.emailVerified) {
            // Verified users go directly to home screen
            return const HomeScreen();
          } else {
            // Unverified users can still access the app
            // Email verification will be handled in the authentication flow
            // This allows users to complete verification later
            return const HomeScreen();
          }
        }

        // No authenticated user, show authentication screen
        return const AuthScreen();
      },
    );
  }
}
