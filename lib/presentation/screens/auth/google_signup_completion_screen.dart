import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_helper.dart';

class GoogleSignupCompletionScreen extends StatefulWidget {
  final User googleUser;
  
  const GoogleSignupCompletionScreen({
    super.key,
    required this.googleUser,
  });

  @override
  State<GoogleSignupCompletionScreen> createState() => _GoogleSignupCompletionScreenState();
}

class _GoogleSignupCompletionScreenState extends State<GoogleSignupCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Pre-fill email from Google account
    _emailController.text = widget.googleUser.email ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _completeSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user display name
      await widget.googleUser.updateDisplayName('${_firstNameController.text.trim()} ${_lastNameController.text.trim()}');

      // Create user profile in Firestore
      final userData = {
        'uid': widget.googleUser.uid,
        'email': widget.googleUser.email,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'displayName': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        'photoURL': widget.googleUser.photoURL,
        'createdAt': DateTime.now(),
        'lastSignIn': DateTime.now(),
        'emailVerified': widget.googleUser.emailVerified,
        'authProvider': 'google',
        'isAnonymous': false,
      };

      await FirestoreService.saveFullUserProfile(widget.googleUser.uid, userData);

      // Send email verification with custom action code settings
      await widget.googleUser.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://utme-prepmaster.firebaseapp.com/verify-email',
          handleCodeInApp: true,
          iOSBundleId: 'com.example.utmePrepMaster',
          androidPackageName: 'com.example.utme_prep_master',
          androidInstallApp: true,
          androidMinimumVersion: '12',
        ),
      );

      if (mounted) {
        // Navigate to email verification screen immediately
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/email-verification', 
          (route) => false,
          arguments: {
            'email': widget.googleUser.email,
            'isNewUser': true,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing signup: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181A20) : AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Welcome message
                Text(
                  'Welcome to UTME PrepMaster!',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Please complete your profile to continue',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // First Name field
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name *',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF23243B) : Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Last Name field
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name *',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF23243B) : Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email field (read-only)
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2D3E) : Colors.grey[100],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dominantPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.dominantPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.dominantPurple,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your email will be verified automatically. You\'ll receive a verification link shortly.',
                          style: TextStyle(
                            color: AppColors.dominantPurple,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Complete signup button
                ElevatedButton(
                  onPressed: _isLoading ? null : _completeSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dominantPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Complete Signup',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 