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
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
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
              Icon(
                Icons.email_outlined,
                color: Colors.blue,
                size: 24,
              ),
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please check your email (including spam folder) and click the verification link.',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 14,
                        ),
                      ),
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

  void _handleVerified() async {
    try {
      final isVerified = await _authService.checkEmailVerified();
      if (isVerified) {
        // Email is verified, proceed to app
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully! Welcome to UTME PrepMaster!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to home screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      } else {
        // Email not verified yet
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified yet. Please check your email and click the verification link.'),
              backgroundColor: Colors.orange,
            ),
          );
          // Show the confirmation dialog again
          _showVerificationConfirmationDialog();
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

  void _handleNotVerified() {
    if (widget.isNewUser) {
      // For new users, go back to sign up screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email to complete your account setup.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email verification icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.email_outlined,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              'Check Your Email',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'We\'ve sent a verification link to:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Email address
            Text(
              _userEmail ?? 'No email available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click the verification link in your email to activate your account. Don\'t forget to check your spam folder!',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Manual verification check button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleVerified,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  'I\'ve Verified My Email',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Resend email button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canResend && !_isResending ? _resendVerificationEmail : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _isResending
                      ? 'Sending...'
                      : _canResend
                          ? 'Resend Verification Email'
                          : 'Resend in ${_resendCountdown}s',
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Back to sign in button
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/auth');
              },
              child: Text(
                'Back to Sign In',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Help text
            Text(
              'Didn\'t receive the email? Check your spam folder or try resending.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
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