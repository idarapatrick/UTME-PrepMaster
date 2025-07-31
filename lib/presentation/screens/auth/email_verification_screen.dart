import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/email_verification_service.dart';
import '../../theme/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  bool _canResend = true;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    EmailVerificationService.startVerificationPolling();
  }

  Future<void> _resendVerification() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await EmailVerificationService.resendVerificationEmail();
      
      setState(() {
        _statusMessage = 'Verification email sent! Please check your inbox.';
        _canResend = false;
        _cooldownSeconds = 60;
      });

      // Start cooldown timer
      _startCooldownTimer();
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to send email: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startCooldownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
        _startCooldownTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text(
          'Verify Email',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread,
              size: 80,
              color: AppColors.dominantPurple,
            ),
            const SizedBox(height: 32),
            Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We\'ve sent a verification email to:',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.dominantPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user?.email ?? 'No email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dominantPurple,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your email address needs to be verified to continue. Please check your email for a verification link, or click the button below to send a new one.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage!.contains('Failed') || _statusMessage!.contains('Error')
                      ? AppColors.errorRed.withOpacity(0.1)
                      : AppColors.subjectGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage!.contains('Failed') || _statusMessage!.contains('Error')
                        ? AppColors.errorRed
                        : AppColors.subjectGreen,
                    width: 1,
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.contains('Failed') || _statusMessage!.contains('Error')
                        ? AppColors.errorRed
                        : AppColors.subjectGreen,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canResend && !_isLoading ? _resendVerification : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _canResend
                            ? 'Send Verification Email'
                            : 'Resend in ${_cooldownSeconds}s',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _signOut,
              child: Text(
                'Sign out and try different email',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Skip verification for testing purposes
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: Text(
                'Skip verification (Development only)',
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
