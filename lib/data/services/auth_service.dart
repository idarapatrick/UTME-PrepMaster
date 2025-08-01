import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Validate password strength
      final passwordError = validatePassword(password);
      if (passwordError != null) {
        return AuthResult.failure(passwordError);
      }

      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(fullName);

        // Send email verification with custom action code settings
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: 'https://utme-prepmaster.firebaseapp.com/verify-email',
            handleCodeInApp: true,
            iOSBundleId: 'com.example.utmePrepMaster',
            androidPackageName: 'com.example.utme_prep_master',
            androidInstallApp: true,
            androidMinimumVersion: '12',
          ),
        );

        // Create user document in Firestore with more detailed info
        final userData = {
          'uid': user.uid,
          'email': user.email,
          'firstName': fullName.split(' ').first,
          'lastName': fullName.split(' ').length > 1
              ? fullName.split(' ').skip(1).join(' ')
              : '',
          'displayName': fullName,
          'photoURL': user.photoURL,
          'createdAt': DateTime.now(),
          'lastSignIn': DateTime.now(),
          'emailVerified': false, // Always false initially
          'authProvider': 'password',
          'isAnonymous': false,
        };

        await FirestoreService.saveFullUserProfile(user.uid, userData);

        // Create welcome notification
        await NotificationService.createWelcomeNotification(user.uid, fullName);

        return AuthResult.success(
          user: user,
          message:
              'Account created successfully! Please check your email to verify your account.',
          needsEmailVerification: true,
        );
      }

      return AuthResult.failure('Failed to create account. Please try again.');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Reload user to get latest verification status
        await user.reload();
        final reloadedUser = _auth.currentUser;

        // Check if email is verified
        if (reloadedUser != null && !reloadedUser.emailVerified) {
          // Send verification email if not verified (but don't block access)
          try {
            await reloadedUser.sendEmailVerification(
              ActionCodeSettings(
                url: 'https://utme-prepmaster.firebaseapp.com/verify-email',
                handleCodeInApp: true,
                iOSBundleId: 'com.example.utmePrepMaster',
                androidPackageName: 'com.example.utme_prep_master',
                androidInstallApp: true,
                androidMinimumVersion: '12',
              ),
            );
          } catch (e) {
            // Ignore error if email already sent recently
          }

          // Allow access but indicate verification is needed
          return AuthResult.success(
            user: reloadedUser ?? user,
            message: 'Welcome back! Please check your email for verification.',
            needsEmailVerification: true,
          );
        }

        return AuthResult.success(
          user: reloadedUser ?? user,
          message: 'Welcome back!',
        );
      }

      return AuthResult.failure('Failed to sign in. Please try again.');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Sign out first to force account selection
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure('Google sign-in was cancelled.');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Reload user to get latest verification status
        await user.reload();
        final reloadedUser = _auth.currentUser;

        // Check if this is a new user
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isNewUser) {
          // For new Google users, return success (Google accounts are pre-verified)
          return AuthResult.success(
            user: reloadedUser ?? user,
            message:
                'Google authentication successful. Welcome to UTME PrepMaster!',
            isNewUser: true,
            needsEmailVerification:
                false, // Google accounts don't need email verification
          );
        } else {
          // For existing Google users, they are already verified
          return AuthResult.success(
            user: reloadedUser ?? user,
            message: 'Welcome back!',
            needsEmailVerification:
                false, // Google accounts don't need email verification
          );
        }
      }

      return AuthResult.failure(
        'Failed to sign in with Google. Please try again.',
      );
    } catch (e) {
      return AuthResult.failure('Google sign-in failed. Please try again.');
    }
  }

  // Resend email verification
  Future<AuthResult> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: 'https://utme-prepmaster.firebaseapp.com/verify-email',
            handleCodeInApp: true,
            iOSBundleId: 'com.example.utmePrepMaster',
            androidPackageName: 'com.example.utme_prep_master',
            androidInstallApp: true,
            androidMinimumVersion: '12',
          ),
        );
        return AuthResult.success(
          message:
              'Verification email sent! Please check your inbox and spam folder.',
        );
      }
      return AuthResult.failure('No user found or email already verified.');
    } catch (e) {
      return AuthResult.failure(
        'Failed to send verification email. Please try again.',
      );
    }
  }

  // Handle verification link click
  Future<AuthResult> handleVerificationLinkClick() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user found.');
      }

      // Force reload the user multiple times to ensure we get the latest status
      await user.reload();
      await Future.delayed(const Duration(milliseconds: 500));
      await user.reload();

      final reloadedUser = _auth.currentUser;

      if (reloadedUser != null && reloadedUser.emailVerified) {
        // Update Firestore document (optional - don't fail if this doesn't work)
        try {
          await _firestore.collection('users').doc(reloadedUser.uid).update({
            'emailVerified': true,
            'lastVerified': DateTime.now(),
            'verificationCompleted': true,
          });
        } catch (e) {
          // Ignore Firestore update errors - verification is still successful
          // print('Firestore update failed: $e');
        }

        return AuthResult.success(
          user: reloadedUser,
          message: 'Email verified successfully!',
        );
      } else {
        return AuthResult.failure(
          'Email not verified yet. Please check your email and click the verification link.',
        );
      }
    } catch (e) {
      return AuthResult.failure('Error checking verification: ${e.toString()}');
    }
  }

  // Enhanced verification check with multiple attempts
  Future<bool> checkEmailVerifiedWithRetry({int maxAttempts = 3}) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final user = _auth.currentUser;
        if (user == null) {
          return false;
        }

        // Force reload the user
        await user.reload();
        await Future.delayed(Duration(milliseconds: 500 * attempt));

        final reloadedUser = _auth.currentUser;
        if (reloadedUser != null && reloadedUser.emailVerified) {
          // Update Firestore when verified (optional)
          try {
            await _firestore.collection('users').doc(reloadedUser.uid).update({
              'emailVerified': true,
              'lastVerified': DateTime.now(),
            });
          } catch (e) {
            // Ignore Firestore update errors - verification is still successful
            // print('Firestore update failed: $e');
          }
          return true;
        }

        // If not verified and this is not the last attempt, wait before retrying
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e) {
        // If there's an error and this is not the last attempt, continue
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt));
          continue;
        }
      }
    }
    return false;
  }

  // Backward compatibility method
  Future<bool> checkEmailVerified() async {
    return await checkEmailVerifiedWithRetry(maxAttempts: 1);
  }

  // Simple verification check (Firebase Auth only, no Firestore)
  Future<bool> checkEmailVerifiedSimple() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Force reload the user
      await user.reload();
      await Future.delayed(const Duration(milliseconds: 500));

      final reloadedUser = _auth.currentUser;
              return reloadedUser!.emailVerified;
    } catch (e) {
      return false;
    }
  }

  // Force refresh verification status by signing out and back in
  Future<AuthResult> forceRefreshVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user found.');
      }

      // Sign out the user
      await _auth.signOut();

      // Wait a moment
      await Future.delayed(const Duration(seconds: 1));

      // Try to sign back in with the same credentials
      return AuthResult.success(
        message: 'Please sign in again to refresh your verification status.',
      );
    } catch (e) {
      return AuthResult.failure(
        'Failed to refresh verification status: ${e.toString()}',
      );
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(
        message: 'Password reset email sent! Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure(
        'Failed to send password reset email. Please try again.',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      // Error during sign out, but continue
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user found to delete.');
      }

      // Delete user data from Firestore first
      try {
        // Delete user document
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user stats
        await _firestore.collection('user_stats').doc(user.uid).delete();

        // Delete study sessions in batches
        final studySessionsQuery = await _firestore
            .collection('study_sessions')
            .where('userId', isEqualTo: user.uid)
            .get();

        if (studySessionsQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (var doc in studySessionsQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }

        // Delete badges in batches
        final badgesQuery = await _firestore
            .collection('badges')
            .where('userId', isEqualTo: user.uid)
            .get();

        if (badgesQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (var doc in badgesQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }

        // Delete any other user-related collections
        final collections = [
          'cbt_results',
          'mockTests',
          'quizzes',
          'tests',
          'notes',
          'links',
        ];
        for (final collectionName in collections) {
          try {
            final query = await _firestore
                .collection(collectionName)
                .where('userId', isEqualTo: user.uid)
                .get();

            if (query.docs.isNotEmpty) {
              final batch = _firestore.batch();
              for (var doc in query.docs) {
                batch.delete(doc.reference);
              }
              await batch.commit();
            }
          } catch (e) {
            // Continue if collection doesn't exist or other errors
          }
        }
      } catch (e) {
        // Log the error but continue with account deletion
        // print('Error deleting Firestore data: $e');
      }

      // Delete the Firebase Auth account
      await user.delete();

      return AuthResult.success(message: 'Account deleted successfully.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return AuthResult.failure(
          'Please sign in again before deleting your account.',
        );
      }
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to delete account: ${e.toString()}');
    }
  }

  // Validate password strength
  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    ).hasMatch(password)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character (@\$!%*?&).';
    }

    return null; // Password is valid
  }

  // Get Firebase Auth error messages
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters and contain uppercase, lowercase, number, and special character.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final String message;
  final User? user;
  final bool needsEmailVerification;
  final bool isNewUser;

  AuthResult.success({
    required this.message,
    this.user,
    this.isNewUser = false,
    this.needsEmailVerification = false,
  }) : isSuccess = true;

  AuthResult.failure(this.message, {this.needsEmailVerification = false})
    : isSuccess = false,
      user = null,
      isNewUser = false;
}
