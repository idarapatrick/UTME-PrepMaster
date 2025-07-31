import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_service.dart';

class OtpService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Generate a 6-digit OTP
  static String _generateOtp() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  // Send OTP to email
  static Future<bool> sendOtpToEmail(String email) async {
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
      
      // Send OTP via email service
      final emailSent = await EmailService.sendOtpEmail(email, otp);
      if (!emailSent) {
        return false;
      }
      
      return true;
    } catch (e) {
      // Error sending OTP
      return false;
    }
  }
  
  // Verify OTP
  static Future<bool> verifyOtp(String email, String otp) async {
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
        if (difference > 300) { // 5 minutes = 300 seconds
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
      // Error verifying OTP
      return false;
    }
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
  static Future<bool> createUserProfile(String email, String displayName, String authProvider) async {
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
      
      // Send welcome email for new users
      await EmailService.sendWelcomeEmail(email, displayName);
      
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