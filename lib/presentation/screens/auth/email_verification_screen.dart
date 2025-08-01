import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? email;
  final bool isNewUser; // Add this to track if it's a new user signup

  const EmailVerificationScreen({
    super.key,
    this.email,
    this.isNewUser = false,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  Timer? _timer;
  bool _isResending = false;
  bool _canResend = true;
  int _resendCountdown = 0;
  String? _userEmail;
  bool _hasShownConfirmation = false;

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    _showConfirmationDialog();
  }

  void _getUserEmail() {
    // Get email from widget or from current user
    _userEmail = widget.email ?? FirebaseAuth.instance.currentUser?.email;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showConfirmationDialog() {
    // Show confirmation dialog after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_hasShownConfirmation) {
        _hasShownConfirmation = true;
        _showVerificationConfirmationDialog();
      }
    });
  }

  void _showVerificationConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              const Text('Check Your Email'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We\'ve sent a verification link to:',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                _userEmail ?? 'No email available',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Important: Check Your Spam Folder!',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verification emails often go to spam/junk folders. Please check your spam folder if you don\'t see the email in your inbox.',
                      style: TextStyle(color: Colors.orange[800], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Have you verified your email?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleNotVerified();
              },
              child: const Text(
                'No, I haven\'t',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleVerified();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Yes, I have',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Enhanced verification check with proper token refresh
  Future<bool> _checkEmailVerifiedWithTokenRefresh() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;



      // Force refresh the ID token to get latest verification status
      await user.reload();
      await user.getIdToken(true); // Force refresh token

      // Small delay to ensure server sync
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the refreshed user instance
      final refreshedUser = FirebaseAuth.instance.currentUser;

      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      
      return false;
    }
  }

  void _handleVerified() async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checking email verification status...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // First try the enhanced verification with token refresh
      bool isVerified = await _checkEmailVerifiedWithTokenRefresh();

      // If still not verified, try with AuthService methods as fallback
      if (!isVerified) {
        isVerified = await _authService.checkEmailVerifiedSimple();

        if (!isVerified) {
          isVerified = await _authService.checkEmailVerifiedWithRetry(
            maxAttempts: 5,
          );
        }
      }

      if (isVerified) {
        // Email is verified, proceed to app
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email verified successfully! Welcome to UTME PrepMaster!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } else {
        // Email not verified yet
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email verification not detected. Please ensure you clicked the verification link in your email (check spam folder too). Try waiting a few moments and check again.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );

          // Show the confirmation dialog again after a delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _showVerificationConfirmationDialog();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkCurrentStatus() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checking current verification status...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Use the enhanced verification method first
      bool isVerified = await _checkEmailVerifiedWithTokenRefresh();

      // Fallback to AuthService method if needed
      if (!isVerified) {
        isVerified = await _authService.checkEmailVerifiedSimple();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVerified
                  ? 'Your email is verified! You can now proceed to the app.'
                  : 'Your email is not yet verified. Please check your email and click the verification link.',
            ),
            backgroundColor: isVerified ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        if (isVerified) {
          // Navigate to home screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _forceRefreshVerification() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Force refreshing verification status...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // First try the enhanced token refresh method
      bool isVerified = await _checkEmailVerifiedWithTokenRefresh();

      if (isVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email verification confirmed! Proceeding to app...',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate to home screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
        return;
      }

      // If token refresh didn't work, try the AuthService method
      final result = await _authService.handleVerificationLinkClick();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.isSuccess ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        if (result.isSuccess) {
          // Navigate to home screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error force refreshing: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleNotVerified() {
    if (widget.isNewUser) {
      // For new users, go back to sign up screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please verify your email to complete your account setup.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/auth', (route) => false);
      }
    } else {
      // For existing users, stay on verification screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email to access the app.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });

        if (_resendCountdown <= 0) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _canResend = true;
              _resendCountdown = 0;
            });
          }
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.06), // Responsive padding
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                screenHeight -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email verification icon
                Container(
                  width: isSmallScreen ? 80 : 120,
                  height: isSmallScreen ? 80 : 120,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: isSmallScreen ? 40 : 60,
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 20 : 32),

                // Title
                Text(
                  'Check Your Email',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 20 : null,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isSmallScreen ? 12 : 16),

                // Description
                Text(
                  'We\'ve sent a verification link to:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 14 : null,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isSmallScreen ? 6 : 8),

                // Email address
                Text(
                  _userEmail ?? 'No email available',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                    fontSize: isSmallScreen ? 14 : null,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isSmallScreen ? 16 : 24),

                // Instructions
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.orange,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        'Click the verification link in your email to activate your account.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        '⚠️ IMPORTANT: Check your spam/junk folder if you don\'t see the email in your inbox!',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: isSmallScreen ? 11 : 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmallScreen ? 20 : 32),

                // Manual verification check button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleVerified,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      'I\'ve Verified My Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : null,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 8 : 12),

                // Refresh status button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _checkCurrentStatus,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Refresh Verification Status',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : null),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 8 : 12),

                // Force refresh button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _forceRefreshVerification,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.orange),
                    ),
                    icon: const Icon(Icons.sync, color: Colors.orange),
                    label: Text(
                      'Force Refresh (Advanced)',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : null,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 12 : 16),

                // Resend email button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _canResend && !_isResending
                        ? _resendVerificationEmail
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isResending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _isResending
                          ? 'Sending...'
                          : _canResend
                          ? 'Resend Verification Email'
                          : 'Resend in ${_resendCountdown}s',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : null),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 12 : 16),

                // Back to sign in button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/auth');
                  },
                  child: Text(
                    'Back to Sign In',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: isSmallScreen ? 14 : null,
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 6 : 8),

                // Sign out and try again button
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Signed out. Please sign in again to refresh your verification status.',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                      if (mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/auth', (route) => false);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error signing out: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Sign Out & Try Again',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: isSmallScreen ? 14 : null,
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 6 : 8),

                // Restart app button
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please close and restart the app to refresh verification status.',
                          ),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Restart App',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: isSmallScreen ? 14 : null,
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 16 : 24),

                // Help text
                Text(
                  'Didn\'t receive the email? Check your spam/junk folder or try resending.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 12 : null,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Add extra space at bottom for very small screens
                if (isVerySmallScreen) SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      final result = await _authService.resendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.isSuccess ? Colors.green : Colors.red,
          ),
        );

        if (result.isSuccess) {
          _startResendCountdown();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }
}
