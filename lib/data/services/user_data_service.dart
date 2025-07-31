import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import '../../domain/models/user_profile_model.dart';
import '../../domain/models/progress_tracking_model.dart';
import '../../domain/models/leaderboard_data_model.dart';

class UserDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // USER PROFILE OPERATIONS
  
  static Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      
      return UserProfile.fromMap(doc.data()!, doc.id);
    } catch (e) {
      developer.log('Error fetching user profile: $e');
      return null;
    }
  }

  static Future<void> createOrUpdateUserProfile(UserProfile profile) async {
    try {
      await _db.collection('users')
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      developer.log('Error creating/updating user profile: $e');
      throw Exception('Failed to save user profile');
    }
  }

  static Future<void> updateUserField(String userId, String field, dynamic value) async {
    try {
      await _db.collection('users').doc(userId).update({field: value});
    } catch (e) {
      developer.log('Error updating user field $field: $e');
      throw Exception('Failed to update user data');
    }
  }

  static Future<void> incrementUserStats(String userId, Map<String, int> increments) async {
    try {
      final updates = <String, dynamic>{};
      increments.forEach((field, value) {
        updates[field] = FieldValue.increment(value);
      });
      
      await _db.collection('users').doc(userId).update(updates);
    } catch (e) {
      developer.log('Error incrementing user stats: $e');
      throw Exception('Failed to update user statistics');
    }
  }

  // PROGRESS TRACKING OPERATIONS

  static Future<ProgressTrackingModel?> getUserProgress(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).collection('progress').doc('tracking').get();
      
      if (!doc.exists) {
        // Create empty progress tracking
        final emptyProgress = ProgressTrackingModel.empty(userId);
        await _saveUserProgress(emptyProgress);
        return emptyProgress;
      }
      
      return ProgressTrackingModel.fromMap(doc.data()!, userId);
    } catch (e) {
      developer.log('Error fetching user progress: $e');
      return null;
    }
  }

  static Future<void> updateUserProgress(ProgressTrackingModel progress) async {
    await _saveUserProgress(progress);
  }

  static Future<void> _saveUserProgress(ProgressTrackingModel progress) async {
    try {
      await _db.collection('users')
          .doc(progress.userId)
          .collection('progress')
          .doc('tracking')
          .set(progress.toMap(), SetOptions(merge: true));
    } catch (e) {
      developer.log('Error saving user progress: $e');
      throw Exception('Failed to save user progress');
    }
  }

  static Future<void> addTestResult(String userId, TestResult testResult) async {
    try {
      final batch = _db.batch();
      
      // Add test to user's test history
      final testRef = _db.collection('users')
          .doc(userId)
          .collection('tests')
          .doc();
      batch.set(testRef, testResult.toMap());
      
      // Update user's progress
      final progressRef = _db.collection('users')
          .doc(userId)
          .collection('progress')
          .doc('tracking');
      
      batch.update(progressRef, {
        'recentTests': FieldValue.arrayUnion([testResult.toMap()]),
        'lastActivity': FieldValue.serverTimestamp(),
        'totalXp': FieldValue.increment(testResult.score * 10), // 10 XP per correct answer
      });
      
      // Update main user document
      final userRef = _db.collection('users').doc(userId);
      batch.update(userRef, {
        'xp': FieldValue.increment(testResult.score * 10),
        'lastActivity': FieldValue.serverTimestamp(),
      });
      
      if (testResult.testType == 'mock') {
        batch.update(userRef, {
          'cbtHighScore': testResult.score,
        });
      }
      
      await batch.commit();
    } catch (e) {
      developer.log('Error adding test result: $e');
      throw Exception('Failed to save test result');
    }
  }

  static Future<void> updateSubjectProgress(String userId, String subject, SubjectProgress progress) async {
    try {
      await _db.collection('users')
          .doc(userId)
          .collection('progress')
          .doc('tracking')
          .update({
        'subjectProgress.$subject': progress.toMap(),
        'lastActivity': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error updating subject progress: $e');
      throw Exception('Failed to update subject progress');
    }
  }

  static Future<void> updateStudyStreak(String userId) async {
    try {
      final user = await getCurrentUserProfile();
      if (user == null) return;
      
      final today = DateTime.now();
      final lastActivity = user.createdAt; // This should be lastActivity from user data
      
      int newStreak = 1;
      if (_isConsecutiveDay(lastActivity, today)) {
        // Continue streak
        newStreak = (user.studyStreak) + 1;
      }
      
      await _db.collection('users').doc(userId).update({
        'studyStreak': newStreak,
        'lastActivity': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error updating study streak: $e');
      throw Exception('Failed to update study streak');
    }
  }

  // LEADERBOARD OPERATIONS

  static Future<LeaderboardDataModel> getLeaderboardData() async {
    try {
      final xpFuture = _getXpLeaderboard();
      final cbtFuture = _getCbtLeaderboard();
      
      final results = await Future.wait([xpFuture, cbtFuture]);
      
      return LeaderboardDataModel(
        xpLeaderboard: results[0],
        cbtLeaderboard: results[1],
        lastFetched: DateTime.now(),
      );
    } catch (e) {
      developer.log('Error fetching leaderboard data: $e');
      return LeaderboardDataModel.empty();
    }
  }

  static Future<List<LeaderboardEntry>> _getXpLeaderboard() async {
    final query = _db.collection('users')
        .orderBy('xp', descending: true)
        .limit(50);
    
    final snapshot = await query.get();
    
    return snapshot.docs.asMap().entries.map((entry) {
      final index = entry.key;
      final doc = entry.value;
      final data = doc.data();
      
      return LeaderboardEntry(
        userId: doc.id,
        displayName: data['displayName'] ?? 'Anonymous',
        photoUrl: data['photoUrl'],
        score: data['xp'] ?? 0,
        rank: index + 1,
        lastUpdated: (data['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  static Future<List<LeaderboardEntry>> _getCbtLeaderboard() async {
    final query = _db.collection('users')
        .orderBy('cbtHighScore', descending: true)
        .limit(50);
    
    final snapshot = await query.get();
    
    return snapshot.docs.asMap().entries.map((entry) {
      final index = entry.key;
      final doc = entry.value;
      final data = doc.data();
      
      return LeaderboardEntry(
        userId: doc.id,
        displayName: data['displayName'] ?? 'Anonymous',
        photoUrl: data['photoUrl'],
        score: data['cbtHighScore'] ?? 0,
        rank: index + 1,
        lastUpdated: (data['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  // ACHIEVEMENTS AND BADGES

  static Future<List<String>> getUserAchievements(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) return [];
      
      final data = doc.data()!;
      return List<String>.from(data['achievements'] ?? []);
    } catch (e) {
      developer.log('Error fetching user achievements: $e');
      return [];
    }
  }

  static Future<void> grantAchievement(String userId, String achievementId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'achievements': FieldValue.arrayUnion([achievementId]),
        'xp': FieldValue.increment(100), // Bonus XP for achievements
        'badgesCount': FieldValue.increment(1),
      });
    } catch (e) {
      developer.log('Error granting achievement: $e');
      throw Exception('Failed to grant achievement');
    }
  }

  // UTILITY METHODS

  static Stream<UserProfile?> watchUserProfile(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data()!, doc.id);
    });
  }

  static Stream<ProgressTrackingModel?> watchUserProgress(String userId) {
    return _db.collection('users')
        .doc(userId)
        .collection('progress')
        .doc('tracking')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return ProgressTrackingModel.fromMap(doc.data()!, userId);
    });
  }

  static Future<void> deleteUserData(String userId) async {
    try {
      final batch = _db.batch();
      
      // Delete user document
      batch.delete(_db.collection('users').doc(userId));
      
      // Delete sub-collections (you might need to do this recursively for large datasets)
      final collections = ['tests', 'progress', 'notes', 'links'];
      
      for (final collection in collections) {
        final snapshot = await _db
            .collection('users')
            .doc(userId)
            .collection(collection)
            .get();
        
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
      }
      
      await batch.commit();
    } catch (e) {
      developer.log('Error deleting user data: $e');
      throw Exception('Failed to delete user data');
    }
  }

  // PRIVATE HELPER METHODS

  static bool _isConsecutiveDay(DateTime lastActivity, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));
    return lastActivity.year == yesterday.year &&
           lastActivity.month == yesterday.month &&
           lastActivity.day == yesterday.day;
  }


}
