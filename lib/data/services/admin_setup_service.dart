import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetupService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create admin user (for development/testing only)
  static Future<void> createAdminUser({
    required String email,
    required String password,
    required String adminCode,
    String role = 'admin',
  }) async {
    try {
      // 1. Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create Firestore user document with admin role
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'adminCode': adminCode,
        'permissions': ['upload', 'verify', 'delete', 'manage'],
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'displayName': 'Admin User',
        'subjects': [], // Admin doesn't need subjects
      });

      print('✅ Admin user created successfully!');
      print('📧 Email: $email');
      print('🔑 Admin Code: $adminCode');
      print('👤 Role: $role');
      print('⚠️  Remember to use strong passwords in production!');
      
    } catch (e) {
      print('❌ Error creating admin user: $e');
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

      print('✅ User promoted to admin successfully!');
      print('📧 Email: $userEmail');
      print('🔑 Admin Code: $adminCode');
      
    } catch (e) {
      print('❌ Error promoting user to admin: $e');
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
      print('❌ Error getting admin users: $e');
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
      print('❌ Error checking admin status: $e');
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
      print('❌ Error getting admin info: $e');
      return null;
    }
  }
} 