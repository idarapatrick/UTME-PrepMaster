import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;
import '../../domain/models/user_profile_model.dart';
import '../nigerian_universities.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // USER PROFILE METHODS

  static Future<void> createUserProfile(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAnonymous': user.isAnonymous,
        'xp': 0,
        'cbtHighScore': 0,
        'displayName': user.displayName ?? 'User${user.uid.substring(0, 6)}',
      });
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<UserProfile?> getFullUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!, doc.id);
  }

  static Future<void> updateUserProfileFromModel(UserProfile profile) async {
    await _db
        .collection('users')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  static Future<void> updateStudyStatistics(
    String userId, {
    int? studyStreak,
    int? totalStudyTime,
    int? badgesCount,
  }) async {
    final updates = <String, dynamic>{};
    
    if (studyStreak != null) updates['studyStreak'] = studyStreak;
    if (totalStudyTime != null) updates['totalStudyTime'] = totalStudyTime;
    if (badgesCount != null) updates['badgesCount'] = badgesCount;
    
    if (updates.isNotEmpty) {
      await _db.collection('users').doc(userId).update(updates);
    }
  }

  static Future<void> saveFullUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  // TEST & QUIZ METHODS

  static Future<void> saveTestResult(
    String userId,
    String subject,
    int score,
    int totalQuestions,
    Duration duration,
  ) async {
    final batch = _db.batch();
    
    // Save test result
    final testRef = _db.collection('users').doc(userId).collection('tests').doc();
    batch.set(testRef, {
      'subject': subject,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': (score / totalQuestions * 100).round(),
      'duration': duration.inSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update user stats
    final userRef = _db.collection('users').doc(userId);
    batch.update(userRef, {
      'totalTests': FieldValue.increment(1),
      'totalScore': FieldValue.increment(score),
    });

    await batch.commit();
    updateCbtHighScore(userId, score);
    _checkAchievements(userId);
  }

  static Future<void> saveMockTestResult(
    String userId,
    String subject,
    int score,
    int totalQuestions,
    Duration duration,
    List<Map<String, dynamic>> answers,
  ) async {
    final batch = _db.batch();
    
    // Save mock test result
    final testRef = _db.collection('users').doc(userId).collection('mockTests').doc();
    batch.set(testRef, {
      'subject': subject,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': (score / totalQuestions * 100).round(),
      'duration': duration.inSeconds,
      'answers': answers,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update user stats
    final userRef = _db.collection('users').doc(userId);
    batch.update(userRef, {
      'totalMockTests': FieldValue.increment(1),
      'totalMockScore': FieldValue.increment(score),
    });

    await batch.commit();
    updateCbtHighScore(userId, score);
    _checkAchievements(userId);
  }

  static Future<void> saveQuizResult(
    String userId,
    String subject,
    int score,
    int totalQuestions,
    Duration duration,
  ) async {
    final batch = _db.batch();
    
    // Save quiz result
    final quizRef = _db.collection('users').doc(userId).collection('quizzes').doc();
    batch.set(quizRef, {
      'subject': subject,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': (score / totalQuestions * 100).round(),
      'duration': duration.inSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update user stats
    final userRef = _db.collection('users').doc(userId);
    batch.update(userRef, {
      'totalQuizzes': FieldValue.increment(1),
      'totalQuizScore': FieldValue.increment(score),
    });

    await batch.commit();
    _checkAchievements(userId);
  }

  // SUBJECT METHODS

  static Future<List<String>> loadUserSubjects(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return [];
    
    final data = doc.data()!;
    return List<String>.from(data['subjects'] ?? []);
  }

  static Future<void> saveUserSubjects(String userId, List<String> subjects) async {
    await _db.collection('users').doc(userId).update({
      'subjects': subjects,
    });
  }

  static Future<Map<String, dynamic>?> loadSubjectProgress(String userId, String subject) async {
    final doc = await _db.collection('users').doc(userId).collection('subject_progress').doc(subject).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> saveSubjectProgress(
    String userId,
    Map<String, double> progress,
  ) async {
    await _db.collection('users').doc(userId).update({
      'subjectProgress': progress,
    });
  }

  // LIBRARY METHODS

  static Future<void> saveNote(
    String userId,
    String subject,
    String title,
    String content,
  ) async {
    await _db.collection('users').doc(userId).collection('notes').add({
      'subject': subject,
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> saveLink(
    String userId,
    String subject,
    String title,
    String url,
  ) async {
    await _db.collection('users').doc(userId).collection('links').add({
      'subject': subject,
      'title': title,
      'url': url,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // LEADERBOARD METHODS

  static Future<List<Map<String, dynamic>>> fetchXpLeaderboard() async {
    final query = _db.collection('users')
        .orderBy('xp', descending: true)
        .limit(50);
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'userId': doc.id,
        'displayName': data['displayName'] ?? 'Anonymous',
        'xp': data['xp'] ?? 0,
        'photoUrl': data['photoUrl'],
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchCbtLeaderboard() async {
    final query = _db.collection('users')
        .orderBy('cbtHighScore', descending: true)
        .limit(50);
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'userId': doc.id,
        'displayName': data['displayName'] ?? 'Anonymous',
        'cbtHighScore': data['cbtHighScore'] ?? 0,
        'photoUrl': data['photoUrl'],
      };
    }).toList();
  }

  // ACHIEVEMENT METHODS

  static Future<List<String>> fetchUserBadges(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) return [];
      
      final data = doc.data()!;
      return List<String>.from(data['achievements'] ?? []);
    } catch (e) {
      developer.log('Error fetching user badges: $e');
      return [];
    }
  }

  // UTILITY METHODS

  static List<String> nigerianInstitutions() {
    return nigerianUniversities;
  }

  static Future<void> uploadFile(String userId, String filePath) async {
    // Implementation for file upload
    // This would use Firebase Storage
  }

  // PRIVATE HELPER METHODS

  static void updateCbtHighScore(String userId, int score) {
    _db.collection('users').doc(userId).get().then((doc) {
      if (doc.exists) {
        final currentHighScore = doc.data()!['cbtHighScore'] ?? 0;
        if (score > currentHighScore) {
          _db.collection('users').doc(userId).update({
            'cbtHighScore': score,
          });
        }
      }
    });
  }

  static void _checkAchievements(String userId) {
    _db.collection('users').doc(userId).get().then((doc) async {
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final achievements = List<String>.from(data['achievements'] ?? []);
      
      // Check for various achievements
      if (_hasAchievement(achievements, 'top-1')) {
        // Check if user is #1 in leaderboard
        final leaderboard = await fetchXpLeaderboard();
        if (leaderboard.isNotEmpty && leaderboard.first['userId'] == userId) {
          _grantAchievement(userId, 'top-1');
        }
      }
      
      if (_hasAchievement(achievements, 'streak-7')) {
        // Check for 7-day streak
        final streak = data['currentStreak'] ?? 0;
        if (streak >= 7) {
          _grantAchievement(userId, 'streak-7');
        }
      }
      
      if (_hasAchievement(achievements, 'perfect-score')) {
        // Check for perfect score
        final tests = data['totalTests'] ?? 0;
        final perfectScores = data['perfectScores'] ?? 0;
        if (tests > 0 && perfectScores > 0) {
          _grantAchievement(userId, 'perfect-score');
        }
      }
      
      if (_hasAchievement(achievements, 'fast-learner')) {
        // Check for quick completion
        final avgTime = data['averageTestTime'] ?? 0;
        if (avgTime > 0 && avgTime < 300) { // Less than 5 minutes
          _grantAchievement(userId, 'fast-learner');
        }
      }
      
      if (_hasAchievement(achievements, 'bookworm')) {
        // Check for study time
        final studyTime = data['totalStudyTime'] ?? 0;
        if (studyTime > 3600) { // More than 1 hour
          _grantAchievement(userId, 'bookworm');
        }
      }
    });
  }

  static bool _hasAchievement(List<String> achievements, String achievement) {
    return !achievements.contains(achievement);
  }

  static void _grantAchievement(String userId, String achievement) {
    _db.collection('users').doc(userId).update({
      'achievements': FieldValue.arrayUnion([achievement]),
      'xp': FieldValue.increment(100), // Award XP for achievement
    });
  }

  static Future<List<String>> _getUserAchievementIds(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return [];
    
    final data = doc.data()!;
    return List<String>.from(data['achievements'] ?? []);
  }

  static Map<String, dynamic> _getDateRange(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'week':
        return {
          'start': now.subtract(const Duration(days: 7)),
          'end': now,
        };
      case 'month':
        return {
          'start': DateTime(now.year, now.month - 1, now.day),
          'end': now,
        };
      case 'year':
        return {
          'start': DateTime(now.year - 1, now.month, now.day),
          'end': now,
        };
      default:
        return {
          'start': now.subtract(const Duration(days: 30)),
          'end': now,
        };
    }
  }
}
