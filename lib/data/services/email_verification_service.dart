import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../../domain/models/verification_status_model.dart';
import 'offline_cache_service.dart';

class EmailVerificationService {
  static const int maxResendAttempts = 5;
  static const Duration resendCooldown = Duration(minutes: 1);
  
  static Timer? _verificationTimer;
  static StreamController<VerificationStatus>? _statusController;

  // INITIALIZATION AND CLEANUP

  static void initialize() {
    _statusController ??= StreamController<VerificationStatus>.broadcast();
  }

  // BASIC VERIFICATION METHODS

  static Future<bool> sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        await _updateVerificationStatus(VerificationStatus.pending);
        return true; // Email was sent
      } catch (e) {
        developer.log('Error sending verification email: $e');
        await _updateVerificationStatus(VerificationStatus.failed);
        rethrow;
      }
    }
    return false; // Email was not sent (user null or already verified)
  }

  static Future<bool> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.reload();
        final isVerified = user.emailVerified;
        
        if (isVerified) {
          await _updateVerificationStatus(VerificationStatus.verified);
        }
        
        return isVerified;
      } catch (e) {
        developer.log('Error checking email verification: $e');
        return false;
      }
    }
    return false;
  }

  // ENHANCED VERIFICATION METHODS

  static Future<VerificationStatusModel> getVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const VerificationStatusModel(status: VerificationStatus.unverified);
      }

      // Check cached status first
      final cachedStatus = await _getCachedVerificationStatus();
      
      // If user is verified in Firebase, update status
      if (user.emailVerified) {
        final verifiedStatus = VerificationStatusModel(
          status: VerificationStatus.verified,
          verifiedAt: DateTime.now(),
          lastSentAt: cachedStatus?.lastSentAt,
          resendCount: cachedStatus?.resendCount ?? 0,
        );
        await _cacheVerificationStatus(verifiedStatus);
        return verifiedStatus;
      }

      // Return cached status or default unverified
      return cachedStatus ?? const VerificationStatusModel(status: VerificationStatus.unverified);
    } catch (e) {
      developer.log('Error getting verification status: $e');
      return const VerificationStatusModel(
        status: VerificationStatus.failed,
        errorMessage: 'Failed to check verification status',
      );
    }
  }

  static Future<bool> canResendEmail() async {
    final status = await getVerificationStatus();
    
    // Can't resend if already verified or reached max attempts
    if (status.isVerified || status.resendCount >= maxResendAttempts) {
      return false;
    }

    // Check cooldown period
    if (status.lastSentAt != null) {
      final timeSinceLastSend = DateTime.now().difference(status.lastSentAt!);
      if (timeSinceLastSend < resendCooldown) {
        return false;
      }
    }

    return true;
  }

  static Future<Duration?> getResendCooldownRemaining() async {
    final status = await getVerificationStatus();
    
    if (status.lastSentAt == null) return null;
    
    final timeSinceLastSend = DateTime.now().difference(status.lastSentAt!);
    final remaining = resendCooldown - timeSinceLastSend;
    
    return remaining.isNegative ? null : remaining;
  }

  static Future<void> resendVerificationEmail() async {
    final canResend = await canResendEmail();
    if (!canResend) {
      throw Exception('Cannot resend verification email at this time');
    }

    final currentStatus = await getVerificationStatus();
    
    try {
      final emailSent = await sendVerificationEmail();
      
      if (emailSent) {
        final newStatus = currentStatus.copyWith(
          status: VerificationStatus.pending,
          lastSentAt: DateTime.now(),
          resendCount: currentStatus.resendCount + 1,
          errorMessage: null,
        );
        
        await _cacheVerificationStatus(newStatus);
      } else {
        throw Exception('User is already verified or email could not be sent');
      }
    } catch (e) {
      final errorStatus = currentStatus.copyWith(
        status: VerificationStatus.failed,
        errorMessage: e.toString(),
      );
      
      await _cacheVerificationStatus(errorStatus);
      rethrow;
    }
  }

  // VERIFICATION MONITORING

  static Stream<VerificationStatus> watchVerificationStatus() {
    _statusController?.close();
    _statusController = StreamController<VerificationStatus>.broadcast();
    
    // Start polling for verification status
    startVerificationPolling();
    
    return _statusController!.stream;
  }

  static void startVerificationPolling() {
    _verificationTimer?.cancel();
    
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final isVerified = await checkEmailVerified();
        _statusController?.add(
          isVerified ? VerificationStatus.verified : VerificationStatus.pending
        );
        
        if (isVerified) {
          timer.cancel();
          _statusController?.close();
        }
      } catch (e) {
        _statusController?.add(VerificationStatus.failed);
      }
    });
  }

  static void stopVerificationPolling() {
    _verificationTimer?.cancel();
    _statusController?.close();
  }

  // VERIFICATION HELPERS

  static Future<bool> handleEmailLink(String link) async {
    try {
      if (FirebaseAuth.instance.isSignInWithEmailLink(link)) {
        // This is an email link, handle accordingly
        await _updateVerificationStatus(VerificationStatus.verified);
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error handling email link: $e');
      await _updateVerificationStatus(VerificationStatus.failed);
      return false;
    }
  }

  static Future<void> markAsExpired() async {
    await _updateVerificationStatus(VerificationStatus.expired);
  }

  // EDGE CASE HANDLERS

  static Future<void> handleAlreadyVerified() async {
    await _updateVerificationStatus(VerificationStatus.verified);
  }

  static Future<void> handleVerificationError(String error) async {
    final currentStatus = await getVerificationStatus();
    final errorStatus = currentStatus.copyWith(
      status: VerificationStatus.failed,
      errorMessage: error,
    );
    await _cacheVerificationStatus(errorStatus);
  }

  static Future<bool> isEmailAlreadyInUse(String email) async {
    try {
      // Try to create a user with this email to check if it exists
      // This is a workaround since fetchSignInMethodsForEmail was deprecated
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: 'temp_password_123!'
      );
      return false; // Email is not in use
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error checking if email is in use: $e');
      return false;
    }
  }

  // CLEANUP

  static void dispose() {
    _verificationTimer?.cancel();
    _statusController?.close();
  }

  // PRIVATE HELPER METHODS

  static Future<void> _updateVerificationStatus(VerificationStatus status) async {
    final currentStatus = await getVerificationStatus();
    final newStatus = currentStatus.copyWith(
      status: status,
      verifiedAt: status == VerificationStatus.verified ? DateTime.now() : null,
    );
    
    await _cacheVerificationStatus(newStatus);
    _statusController?.add(status);
  }

  static Future<void> _cacheVerificationStatus(VerificationStatusModel status) async {
    try {
      await OfflineCacheService.initialize();
      // You can implement specific caching for verification status in OfflineCacheService
      // For now, we'll use a simple approach
    } catch (e) {
      developer.log('Error caching verification status: $e');
    }
  }

  static Future<VerificationStatusModel?> _getCachedVerificationStatus() async {
    try {
      // Implement getting cached verification status
      // This would integrate with OfflineCacheService
      return null;
    } catch (e) {
      developer.log('Error getting cached verification status: $e');
      return null;
    }
  }
}
