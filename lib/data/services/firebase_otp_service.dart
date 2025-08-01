import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseOtpService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send OTP via Firebase Functions
  static Future<bool> sendOtpToEmail(String email) async {
    try {
      // Call Firebase Function to send OTP
      final HttpsCallable callable = _functions.httpsCallable('sendOtpEmail');
      final result = await callable.call({'email': email});

      final success = result.data['success'] as bool? ?? false;
      if (success) {
        // OTP sent to email via Firebase Functions
        return true;
      } else {
        // Failed to send OTP
        return false;
      }
    } catch (e) {
      // Error sending OTP via Firebase Functions
      // Fallback to local OTP for development
      return await _sendLocalOtp(email);
    }
  }

  // Verify OTP via Firebase Functions
  static Future<bool> verifyOtp(String email, String otp) async {
    try {
      // Call Firebase Function to verify OTP
      final HttpsCallable callable = _functions.httpsCallable('verifyOtp');
      final result = await callable.call({'email': email, 'otp': otp});

      final success = result.data['success'] as bool? ?? false;
      if (success) {
        // OTP verified successfully for email
        return true;
      } else {
        // OTP verification failed
        return false;
      }
    } catch (e) {
      // Error verifying OTP via Firebase Functions
      // Fallback to local verification for development
      return await _verifyLocalOtp(email, otp);
    }
  }

  // Local fallback for development
  static Future<bool> _sendLocalOtp(String email) async {
    try {
      final otp = _generateOtp();
      final timestamp = FieldValue.serverTimestamp();

      // Store OTP in Firestore with expiration (5 minutes)
      await _firestore.collection('otp_codes').doc(email).set({
        'otp': otp,
        'timestamp': timestamp,
        'expires_at': FieldValue.serverTimestamp(),
        'verified': false,
      });

      // Local OTP for email
      return true;
    } catch (e) {
      // Error sending local OTP
      return false;
    }
  }

  static Future<bool> _verifyLocalOtp(String email, String otp) async {
    try {
      final doc = await _firestore.collection('otp_codes').doc(email).get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data();
      final storedOtp = data?['otp'] as String?;
      final timestamp = data?['timestamp'] as Timestamp?;
      final verified = data?['verified'] as bool? ?? false;

      if (verified) {
        return false; // OTP already used
      }

      // Check if OTP is expired (5 minutes)
      if (timestamp != null) {
        final now = Timestamp.now();
        final difference = now.seconds - timestamp.seconds;
        if (difference > 300) {
          // 5 minutes = 300 seconds
          return false;
        }
      }

      if (storedOtp == otp) {
        // Mark OTP as verified
        await _firestore.collection('otp_codes').doc(email).update({
          'verified': true,
        });
        return true;
      }

      return false;
    } catch (e) {
      // Error verifying local OTP
      return false;
    }
  }

  static String _generateOtp() {
    final random = DateTime.now().millisecondsSinceEpoch % 900000 + 100000;
    return random.toString();
  }

  // Check if email is already registered
  static Future<bool> isEmailRegistered(String email) async {
    try {
      // Check in Firestore users collection
      final doc = await _firestore.collection('users').doc(email).get();
      return doc.exists;
    } catch (e) {
      // Error checking email registration
      return false;
    }
  }

  // Create user profile after successful OTP verification
  static Future<bool> createUserProfile(
    String email,
    String displayName,
    String authProvider,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(email).set({
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'authProvider': authProvider,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': true,
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      // Error creating user profile
      return false;
    }
  }

  // Update last login
  static Future<void> updateLastLogin(String email) async {
    try {
      await _firestore.collection('users').doc(email).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Error updating last login
    }
  }
}
