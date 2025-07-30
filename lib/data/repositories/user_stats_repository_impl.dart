import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_stats_model.dart';
import '../../domain/models/study_session_model.dart';
import '../../domain/repositories/user_stats_repository.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Stats
  @override
  Future<UserStats?> getUserStats(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_stats')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserStats.fromMap(doc.data()!, userId);
      }
      return null;
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  @override
  Future<void> createUserStats(UserStats stats) async {
    try {
      await _firestore
          .collection('user_stats')
          .doc(stats.userId)
          .set(stats.toMap());
    } catch (e) {
      print('Error creating user stats: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    try {
      await _firestore
          .collection('user_stats')
          .doc(stats.userId)
          .update(stats.toMap());
    } catch (e) {
      print('Error updating user stats: $e');
      rethrow;
    }
  }

  @override
  Stream<UserStats?> getUserStatsStream(String userId) {
    return _firestore
        .collection('user_stats')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserStats.fromMap(doc.data()!, userId);
          }
          return null;
        });
  }

  // Study Sessions
  @override
  Future<void> startStudySession(StudySession session) async {
    try {
      await _firestore
          .collection('study_sessions')
          .add(session.toMap());
    } catch (e) {
      print('Error starting study session: $e');
      rethrow;
    }
  }

  @override
  Future<void> endStudySession(String sessionId, DateTime endTime, int durationMinutes, int xpEarned) async {
    try {
      await _firestore
          .collection('study_sessions')
          .doc(sessionId)
          .update({
        'endTime': Timestamp.fromDate(endTime),
        'durationMinutes': durationMinutes,
        'xpEarned': xpEarned,
      });
    } catch (e) {
      print('Error ending study session: $e');
      rethrow;
    }
  }

  @override
  Future<List<StudySession>> getUserStudySessions(String userId, {DateTime? from, DateTime? to}) async {
    try {
      Query query = _firestore
          .collection('study_sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true);

      if (from != null) {
        query = query.where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
      }
      if (to != null) {
        query = query.where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(to));
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => StudySession.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting user study sessions: $e');
      return [];
    }
  }

  @override
  Stream<List<StudySession>> getUserStudySessionsStream(String userId) {
    return _firestore
        .collection('study_sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudySession.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // XP and Streak Management
  @override
  Future<void> addXp(String userId, int xp, {String? subjectId, String? reason}) async {
    try {
      final stats = await getUserStats(userId);
      if (stats != null) {
        final updatedSubjectXp = Map<String, int>.from(stats.subjectXp);
        if (subjectId != null) {
          updatedSubjectXp[subjectId] = (updatedSubjectXp[subjectId] ?? 0) + xp;
        }

        final updatedStats = stats.copyWith(
          totalXp: stats.totalXp + xp,
          subjectXp: updatedSubjectXp,
          updatedAt: DateTime.now(),
        );

        await updateUserStats(updatedStats);
      }
    } catch (e) {
      print('Error adding XP: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStreak(String userId, int newStreak) async {
    try {
      final stats = await getUserStats(userId);
      if (stats != null) {
        final updatedStats = stats.copyWith(
          currentStreak: newStreak,
          longestStreak: newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
          updatedAt: DateTime.now(),
        );
        await updateUserStats(updatedStats);
      }
    } catch (e) {
      print('Error updating streak: $e');
      rethrow;
    }
  }

  @override
  Future<void> checkAndUpdateStreak(String userId) async {
    try {
      final stats = await getUserStats(userId);
      if (stats == null) return;

      final now = DateTime.now();
      final lastStudy = stats.lastStudyDate;
      final daysSinceLastStudy = now.difference(lastStudy).inDays;

      if (daysSinceLastStudy == 1) {
        // Consecutive day
        await updateStreak(userId, stats.currentStreak + 1);
      } else if (daysSinceLastStudy > 1) {
        // Streak broken
        await updateStreak(userId, 1);
      }
    } catch (e) {
      print('Error checking and updating streak: $e');
    }
  }

  // Badge Management
  @override
  Future<void> awardBadge(String userId, String badgeId) async {
    try {
      final stats = await getUserStats(userId);
      if (stats != null && !stats.earnedBadges.contains(badgeId)) {
        final updatedBadges = List<String>.from(stats.earnedBadges)..add(badgeId);
        final updatedStats = stats.copyWith(
          earnedBadges: updatedBadges,
          updatedAt: DateTime.now(),
        );
        await updateUserStats(updatedStats);
      }
    } catch (e) {
      print('Error awarding badge: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getAvailableBadges(String userId) async {
    try {
      final stats = await getUserStats(userId);
      if (stats == null) return [];

      // Get all badges from Firestore
      final badgesSnapshot = await _firestore.collection('badges').get();
      final allBadges = badgesSnapshot.docs.map((doc) => doc.id).toList();

      // Return badges that user hasn't earned yet
      return allBadges.where((badgeId) => !stats.earnedBadges.contains(badgeId)).toList();
    } catch (e) {
      print('Error getting available badges: $e');
      return [];
    }
  }

  @override
  Future<void> checkAndAwardBadges(String userId) async {
    try {
      final stats = await getUserStats(userId);
      if (stats == null) return;

      // Get all badges
      final badgesSnapshot = await _firestore.collection('badges').get();
      
      for (final badgeDoc in badgesSnapshot.docs) {
        final badgeData = badgeDoc.data();
        final badgeId = badgeDoc.id;
        
        if (stats.earnedBadges.contains(badgeId)) continue;

        // Check if user qualifies for this badge
        if (_checkBadgeEligibility(stats, badgeData)) {
          await awardBadge(userId, badgeId);
        }
      }
    } catch (e) {
      print('Error checking and awarding badges: $e');
    }
  }

  bool _checkBadgeEligibility(UserStats stats, Map<String, dynamic> badgeData) {
    final type = badgeData['type'] as String?;
    final requirement = badgeData['requirement'] as int?;
    
    if (type == null || requirement == null) return false;

    switch (type) {
      case 'streak':
        return stats.currentStreak >= requirement;
      case 'xp':
        return stats.totalXp >= requirement;
      case 'studyTime':
        return stats.totalStudyTimeMinutes >= (requirement * 60); // Convert hours to minutes
      case 'accuracy':
        return stats.accuracyRate >= (requirement / 100.0);
      case 'subject':
        final subjectId = badgeData['subjectId'] as String?;
        if (subjectId != null) {
          return stats.getXpForSubject(subjectId) >= requirement;
        }
        return false;
      default:
        return false;
    }
  }

  // Leaderboard
  @override
  Future<List<UserStats>> getLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('user_stats')
          .orderBy('totalXp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserStats.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }

  @override
  Future<int> getUserRank(String userId) async {
    try {
      final userStats = await getUserStats(userId);
      if (userStats == null) return -1;

      final snapshot = await _firestore
          .collection('user_stats')
          .where('totalXp', isGreaterThan: userStats.totalXp)
          .count()
          .get();

      return (snapshot.count ?? 0) + 1;
    } catch (e) {
      print('Error getting user rank: $e');
      return -1;
    }
  }

  // Analytics
  @override
  Future<Map<String, dynamic>> getUserAnalytics(String userId, {DateTime? from, DateTime? to}) async {
    try {
      final sessions = await getUserStudySessions(userId, from: from, to: to);
      final stats = await getUserStats(userId);

      if (stats == null) return {};

      return {
        'totalSessions': sessions.length,
        'totalStudyTime': sessions.fold(0, (sum, session) => sum + session.durationMinutes),
        'totalXp': sessions.fold(0, (sum, session) => sum + session.xpEarned),
        'averageSessionLength': sessions.isNotEmpty 
            ? sessions.fold(0, (sum, session) => sum + session.durationMinutes) / sessions.length 
            : 0,
        'mostStudiedSubject': _getMostStudiedSubject(sessions),
        'streak': stats.currentStreak,
        'accuracy': stats.accuracyRate,
      };
    } catch (e) {
      print('Error getting user analytics: $e');
      return {};
    }
  }

  @override
  Future<Map<String, int>> getSubjectProgress(String userId) async {
    try {
      final stats = await getUserStats(userId);
      if (stats == null) return {};

      return stats.subjectXp;
    } catch (e) {
      print('Error getting subject progress: $e');
      return {};
    }
  }

  String _getMostStudiedSubject(List<StudySession> sessions) {
    if (sessions.isEmpty) return '';

    final subjectTime = <String, int>{};
    for (final session in sessions) {
      subjectTime[session.subjectId] = (subjectTime[session.subjectId] ?? 0) + session.durationMinutes;
    }

    String mostStudied = '';
    int maxTime = 0;
    for (final entry in subjectTime.entries) {
      if (entry.value > maxTime) {
        maxTime = entry.value;
        mostStudied = entry.key;
      }
    }

    return mostStudied;
  }
} 