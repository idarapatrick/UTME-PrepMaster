import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/email_verification_service.dart';
import '../../theme/app_colors.dart';
import '../../../data/services/firestore_service.dart';
import '../../utils/responsive_helper.dart';
import '../auth/email_verification_screen.dart';
import '../home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _versionTapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final newUser = FirebaseAuth.instance.currentUser!;
        
        // Check if this is a test account that should bypass verification
        const testAccounts = [
          'm.musembi@alustudent.com',
          'admin@utmeprepmaster.com',
          'michael@utmeprepmaster.com',
          'idarapatrick@gmail.com',
        ];
        
        if (testAccounts.contains(newUser.email?.toLowerCase())) {
          print('DEBUG: Test account sign-up detected, proceeding to home');
          // Create user profile
          await FirestoreService.createUserProfile(newUser);
          
          // Save session data
          await _saveSessionData();
          
          setState(() {
            _isLoading = false;
          });
          return; // Let the StreamBuilder in main.dart handle navigation to HomeScreen
        }

        // For non-test accounts, send verification email
        await EmailVerificationService.sendVerificationEmail();

        // Create user profile before navigating
        await FirestoreService.createUserProfile(newUser);

        // Save session data
        await _saveSessionData();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
          );
        }
      } else {
        // Sign In Flow
        print('DEBUG: Starting sign-in with email: ${_emailController.text.trim()}');
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = FirebaseAuth.instance.currentUser!;
        print('DEBUG: User signed in: ${user.email}');
        print('DEBUG: User UID: ${user.uid}');
        print('DEBUG: User emailVerified: ${user.emailVerified}');

        // For any registered user, create profile and go to home
        await FirestoreService.createUserProfile(user);
        await _saveSessionData();

        print('DEBUG: Profile created and session saved, attempting navigation to HomeScreen');
        
        setState(() {
          _isLoading = false;
        });
        
        // Force navigation to home screen as fallback
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInAnonymously();

      await FirestoreService.createUserProfile(
        FirebaseAuth.instance.currentUser!,
      );

      // Save session data
      await _saveSessionData();

      // No need to navigate - AuthGate will handle this automatically
      // The user is now authenticated and will be redirected to HomeScreen
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize GoogleSignIn instance
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // If user cancels the sign-in flow
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential - handle potential null values
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Create user profile
      await FirestoreService.createUserProfile(userCredential.user!);

      // Save session data
      await _saveSessionData();

      print('DEBUG: Google Sign-In complete, navigating to HomeScreen');

      // Force navigation to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } on Exception catch (e) {
      print('Google Sign-In error: $e');
      setState(() {
        _errorMessage = 'Google Sign-In failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Session persistence methods
  Future<void> _saveSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await prefs.setString('user_id', user.uid);
        await prefs.setString('user_email', user.email ?? '');
        await prefs.setString(
          'auth_provider',
          user.providerData.isNotEmpty
              ? user.providerData.first.providerId
              : 'password',
        );
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('last_login', DateTime.now().toIso8601String());
      }
    } catch (e) {
      print('Error saving session data: $e');
    }
  }

  Future<void> _loadSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (isLoggedIn) {
        // Check if user is still authenticated with Firebase
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // User is still authenticated, AuthGate will handle navigation automatically
        } else {
          // Clear invalid session data
          await prefs.clear();
        }
      }
    } catch (e) {
      print('Error loading session data: $e');
    }
  }

  void _handleVersionTap() {
    final now = DateTime.now();

    // Reset counter if more than 3 seconds have passed
    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds > 3) {
      _versionTapCount = 0;
    }

    _versionTapCount++;
    _lastTapTime = now;

    // Show admin access after 5 taps
    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      _showAdminAccessDialog();
    }
  }

  void _showAdminAccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Access'),
        content: const Text(
          'Enter admin credentials to access admin features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/auth');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF181A20)
        : AppColors.backgroundPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: ResponsiveHelper.responsiveSingleChildScrollView(
        context: context,
        child: Padding(
          padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and branding
              _buildLogoSection(context),

              SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context) * 2,
              ),

              // Auth form
              _buildAuthForm(context, isDark),

              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),

              // Social login buttons
              _buildSocialLoginSection(context, isDark),

              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),

              // Anonymous login
              _buildAnonymousLoginSection(context, isDark),

              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),

              // Version info
              _buildVersionInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Column(
      children: [
        Container(
          height: ResponsiveHelper.getResponsiveIconSize(context, 80),
          width: ResponsiveHelper.getResponsiveIconSize(context, 80),
          decoration: BoxDecoration(
            color: AppColors.dominantPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveIconSize(context, 40),
            ),
          ),
          child: Icon(
            Icons.school,
            size: ResponsiveHelper.getResponsiveIconSize(context, 40),
            color: AppColors.dominantPurple,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
        Text(
          'UTME PrepMaster',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: AppColors.dominantPurple,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
        Text(
          'Your smart study companion',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm(BuildContext context, bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsivePadding(context),
        ),
      ),
      child: Padding(
        padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsivePadding(context) / 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(
                    Icons.lock_outlined,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsivePadding(context) / 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getResponsiveButtonHeight(context),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dominantPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsivePadding(context) / 2,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            20,
                          ),
                          width: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            20,
                          ),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _isSignUp ? 'Sign Up' : 'Sign In',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              16,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context) / 2,
              ),
              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsivePadding(context) / 2,
                    ),
                    border: Border.all(color: AppColors.errorRed, width: 1),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppColors.errorRed,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        14,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context) / 2,
                ),
              ],
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : 'Don\'t have an account? Sign Up',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    color: AppColors.dominantPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: AppColors.textTertiary, thickness: 1),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsivePadding(context),
              ),
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: AppColors.textTertiary, thickness: 1),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
        SizedBox(
          width: double.infinity,
          height: ResponsiveHelper.getResponsiveButtonHeight(context),
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: Image.asset(
              'assets/icons/google_icon_light.png',
              height: ResponsiveHelper.getResponsiveIconSize(context, 20),
            ),
            label: Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.borderLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsivePadding(context) / 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousLoginSection(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.getResponsiveButtonHeight(context),
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _signInAnonymously,
        icon: Icon(
          Icons.person_outline,
          size: ResponsiveHelper.getResponsiveIconSize(context, 20),
        ),
        label: Text(
          'Continue as Guest',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dominantPurple,
          side: BorderSide(color: AppColors.dominantPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsivePadding(context) / 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return GestureDetector(
      onTap: _handleVersionTap,
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        child: Text(
          'Version 1.0.0',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
