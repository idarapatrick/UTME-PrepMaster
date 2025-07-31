import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetupService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create admin user (for development/testing only)
  static Future<void> createAdminUser(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Error creating admin user
      rethrow;
    }
  }

  // Promote existing user to admin
  static Future<void> promoteUserToAdmin({
    required String userEmail,
    required String adminCode,
  }) async {
    try {
      // Find user by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = userQuery.docs.first;
      
      // Update user role to admin
      await userDoc.reference.update({
        'role': 'admin',
        'adminCode': adminCode,
        'permissions': ['upload', 'verify', 'delete', 'manage'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // User promoted to admin successfully
      
    } catch (e) {
      // Error promoting user to admin
      rethrow;
    }
  }

  // List all admin users
  static Future<List<Map<String, dynamic>>> getAdminUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['admin', 'developer'])
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'email': data['email'],
          'role': data['role'],
          'isActive': data['isActive'] ?? true,
          'createdAt': data['createdAt'],
        };
      }).toList();
    } catch (e) {
      // Error getting admin users
      return [];
    }
  }

  // Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userRole = userDoc.data()?['role'] ?? 'user';
      return userRole == 'admin' || userRole == 'developer';
    } catch (e) {
      // Error checking admin status
      return false;
    }
  }

  // Get current user's admin info
  static Future<Map<String, dynamic>?> getCurrentUserAdminInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final data = userDoc.data()!;
      final userRole = data['role'] ?? 'user';
      
      if (userRole != 'admin' && userRole != 'developer') {
        return null;
      }

      return {
        'email': data['email'],
        'role': data['role'],
        'adminCode': data['adminCode'],
        'permissions': data['permissions'] ?? [],
        'isActive': data['isActive'] ?? true,
      };
    } catch (e) {
      // Error getting admin info
      return null;
    }
  }
} 