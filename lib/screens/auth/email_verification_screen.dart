import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/email_verification_service.dart';
import '../../theme/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _verificationTimer;
  String _statusMessage = 'We’ve sent a verification email to your inbox.';
  bool _isResending = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _startVerificationPolling();
  }

  void _startVerificationPolling() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      final verified = await EmailVerificationService.checkEmailVerified();
      if (verified) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isVerified = true;
            _statusMessage =
                'Your email has been verified. You may now continue.';
          });
        }
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _statusMessage = 'Resending email...';
    });

    try {
      await EmailVerificationService.sendVerificationEmail();
      setState(() {
        _statusMessage = 'Verification email sent again!';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.message}';
      });
    } catch (_) {
      setState(() {
        _statusMessage = 'An unexpected error occurred.';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _goToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 48,
                    color: AppColors.dominantPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verify Your Email',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.dominantPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.secondaryGray),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isResending ? null : _resendVerificationEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dominantPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isResending
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : const Text('Resend Email'),
                    ),
                  ),
                  if (_isVerified) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goToHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
