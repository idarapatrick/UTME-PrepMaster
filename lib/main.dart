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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized to prevent duplicate app error
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase is already initialized, just continue
    if (e.toString().contains('duplicate-app')) {
      // Firebase is already initialized, continue
    } else {
      rethrow; // Re-throw other errors
    }
  }

  // Enable Firestore offline caching
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Load theme preference from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier()..setTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light),
        ),
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => SubjectState()),
        ChangeNotifierProvider(create: (_) => TestState()),
        ChangeNotifierProvider(create: (_) => UserStatsProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => StudyPreferencesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'UTME PrepMaster',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isInitializing = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait a bit for Firebase to fully initialize
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check if user has seen onboarding
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // Initialize user stats provider in the background
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final userStatsProvider = Provider.of<UserStatsProvider>(
            context,
            listen: false,
          );
          userStatsProvider.initializeUserStats();
        } catch (e) {
          // Ignore user stats initialization errors
        }
      });
    } catch (e) {
      // Error initializing app
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // If user has not seen onboarding, show onboarding first
        if (!_hasSeenOnboarding) {
          return const OnboardingScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          // Google users don't need email verification - go directly to home
          if (user.providerData.isNotEmpty &&
              user.providerData.first.providerId == 'google.com') {
            return const HomeScreen();
          }

          // For email/password users, check if they're verified
          if (user.emailVerified) {
            // User is verified, go directly to home
            return const HomeScreen();
          } else {
            // User is not verified, but this should only happen for new sign-ups
            // Existing users should be able to sign in normally
            // For now, let them access the app (verification will be handled in auth flow)
            return const HomeScreen();
          }
        }

        // No user, show auth screen
        return const AuthScreen();
      },
    );
  }
}
