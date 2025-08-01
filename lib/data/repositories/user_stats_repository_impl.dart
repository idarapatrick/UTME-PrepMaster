import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_stats_model.dart';
import '../../domain/models/study_session_model.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../services/notification_service.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Stats
  @override
  Future<UserStats?> getUserStats(String userId) async {
    try {
      final doc = await _firestore.collection('user_stats').doc(userId).get();

      if (doc.exists) {
        return UserStats.fromMap(doc.data()!, userId);
      }
      return null;
    } catch (e) {
      // Error getting user stats
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
      // Error creating user stats
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
      // Error updating user stats
      rethrow;
    }
  }

  @override
  Stream<UserStats?> getUserStatsStream(String userId) {
    return _firestore.collection('user_stats').doc(userId).snapshots().map((
      doc,
    ) {
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
      await _firestore.collection('study_sessions').add(session.toMap());
    } catch (e) {
      // Error starting study session
      rethrow;
    }
  }

  @override
  Future<void> endStudySession(
    String sessionId,
    DateTime endTime,
    int durationMinutes,
    int xpEarned,
  ) async {
    try {
      await _firestore.collection('study_sessions').doc(sessionId).update({
        'endTime': Timestamp.fromDate(endTime),
        'durationMinutes': durationMinutes,
        'xpEarned': xpEarned,
      });
    } catch (e) {
      // Error ending study session
      rethrow;
    }
  }

  @override
  Future<List<StudySession>> getUserStudySessions(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      Query query = _firestore
          .collection('study_sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true);

      if (from != null) {
        query = query.where(
          'startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from),
        );
      }
      if (to != null) {
        query = query.where(
          'startTime',
          isLessThanOrEqualTo: Timestamp.fromDate(to),
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => StudySession.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      // Error getting user study sessions
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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StudySession.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // XP and Streak Management
  @override
  Future<void> checkAndUpdateStreak(String userId) async {
    try {
      final stats = await getUserStats(userId);
      if (stats == null) return;

      final now = DateTime.now();
      final lastStudy = stats.lastStudyDate;

      // Check if user logged in today
      final today = DateTime(now.year, now.month, now.day);
      final lastStudyDay = DateTime(
        lastStudy.year,
        lastStudy.month,
        lastStudy.day,
      );
      final daysSinceLastStudy = today.difference(lastStudyDay).inDays;

      if (daysSinceLastStudy == 0) {
        // User already logged in today, no streak update needed
        return;
      } else if (daysSinceLastStudy == 1) {
        // Consecutive day - increment streak
        await updateStreak(userId, stats.currentStreak + 1);
      } else if (daysSinceLastStudy > 1) {
        // Streak broken - reset to 1
        await updateStreak(userId, 1);
      } else {
        // First time login - start streak at 1
        await updateStreak(userId, 1);
      }

      // Update last study date to today
      final updatedStats = stats.copyWith(lastStudyDate: now, updatedAt: now);
      await updateUserStats(updatedStats);
    } catch (e) {
      // Error checking and updating streak
      rethrow;
    }
  }

  // Enhanced XP methods for specific activities
  @override
  Future<void> addXp(
    String userId,
    int xp, {
    String? subjectId,
    String? reason,
  }) async {
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

        // Create XP notification
        if (reason != null) {
          await NotificationService.createXpNotification(userId, xp, reason);
        }
      }
    } catch (e) {
      // Error adding XP
      rethrow;
    }
  }

  // Method for CBT test completion (20 XP for starting CBT)
  Future<void> startCbtTest(String userId, String subjectId) async {
    try {
      await addXp(userId, 20, subjectId: subjectId, reason: 'cbt_start');
    } catch (e) {
      rethrow;
    }
  }

  // Method for CBT test completion with comprehensive stats tracking
  Future<void> completeCbtTest(
    String userId,
    String subjectId, {
    int correctAnswers = 0,
    int totalQuestions = 0,
    int timeSpentMinutes = 0,
    int score = 0,
  }) async {
    try {
      // Base XP for completing CBT test
      int baseXp = 50; // Higher XP for CBT tests

      // Bonus XP for accuracy
      int accuracyBonus = 0;
      if (totalQuestions > 0) {
        double accuracy = correctAnswers / totalQuestions;
        if (accuracy >= 0.9) {
          accuracyBonus = 30; // 90%+ = 30 bonus XP
        } else if (accuracy >= 0.8) {
          accuracyBonus = 20; // 80%+ = 20 bonus XP
        } else if (accuracy >= 0.7) {
          accuracyBonus = 10; // 70%+ = 10 bonus XP
        }
      }

      // Bonus XP for speed (if completed quickly)
      int speedBonus = 0;
      if (timeSpentMinutes > 0 && totalQuestions > 0) {
        double minutesPerQuestion = timeSpentMinutes / totalQuestions;
        if (minutesPerQuestion < 1.0) {
          speedBonus = 15; // Very fast
        } else if (minutesPerQuestion < 2.0) {
          speedBonus = 10; // Fast
        }
      }

      int totalXp = baseXp + accuracyBonus + speedBonus;

      await addXp(
        userId,
        totalXp,
        subjectId: subjectId,
        reason: 'cbt_completion',
      );

      // Update comprehensive stats
      final stats = await getUserStats(userId);
      if (stats != null) {
        final updatedStats = stats.copyWith(
          questionsAnswered: stats.questionsAnswered + totalQuestions,
          correctAnswers: stats.correctAnswers + correctAnswers,
          totalStudyTimeMinutes: stats.totalStudyTimeMinutes + timeSpentMinutes,
          updatedAt: DateTime.now(),
        );
        await updateUserStats(updatedStats);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Method for quiz completion (10 XP for completing quiz)
  Future<void> completeQuiz(
    String userId,
    String subjectId, {
    int correctAnswers = 0,
    int totalQuestions = 0,
    int timeSpentMinutes = 0,
  }) async {
    try {
      // Base XP for completing quiz
      int baseXp = 10;

      // Bonus XP for accuracy
      int accuracyBonus = 0;
      if (totalQuestions > 0) {
        double accuracy = correctAnswers / totalQuestions;
        if (accuracy >= 0.9) {
          accuracyBonus = 15; // 90%+ = 15 bonus XP
        } else if (accuracy >= 0.8) {
          accuracyBonus = 10; // 80%+ = 10 bonus XP
        } else if (accuracy >= 0.7) {
          accuracyBonus = 5; // 70%+ = 5 bonus XP
        }
      }

      // Bonus XP for speed (if completed quickly)
      int speedBonus = 0;
      if (timeSpentMinutes > 0 && totalQuestions > 0) {
        double minutesPerQuestion = timeSpentMinutes / totalQuestions;
        if (minutesPerQuestion < 0.5) {
          speedBonus = 10; // Very fast
        } else if (minutesPerQuestion < 1.0) {
          speedBonus = 5; // Fast
        }
      }

      int totalXp = baseXp + accuracyBonus + speedBonus;

      await addXp(
        userId,
        totalXp,
        subjectId: subjectId,
        reason: 'quiz_completion',
      );

      // Update comprehensive stats
      final stats = await getUserStats(userId);
      if (stats != null) {
        final updatedStats = stats.copyWith(
          quizzesCompleted: stats.quizzesCompleted + 1,
          questionsAnswered: stats.questionsAnswered + totalQuestions,
          correctAnswers: stats.correctAnswers + correctAnswers,
          totalStudyTimeMinutes: stats.totalStudyTimeMinutes + timeSpentMinutes,
          updatedAt: DateTime.now(),
        );
        await updateUserStats(updatedStats);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Method for daily login streak check
  Future<void> checkDailyLogin(String userId) async {
    try {
      await checkAndUpdateStreak(userId);
    } catch (e) {
      rethrow;
    }
  }

  // Badge Management
  @override
  Future<void> awardBadge(String userId, String badgeId) async {
    try {
      final stats = await getUserStats(userId);
      if (stats != null && !stats.earnedBadges.contains(badgeId)) {
        final updatedBadges = List<String>.from(stats.earnedBadges)
          ..add(badgeId);
        final updatedStats = stats.copyWith(
          earnedBadges: updatedBadges,
          updatedAt: DateTime.now(),
        );
        await updateUserStats(updatedStats);
      }
    } catch (e) {
      // Error awarding badge
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
      return allBadges
          .where((badgeId) => !stats.earnedBadges.contains(badgeId))
          .toList();
    } catch (e) {
      // Error getting available badges
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
      // Error checking and awarding badges
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
        return stats.totalStudyTimeMinutes >=
            (requirement * 60); // Convert hours to minutes
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
      // Error getting leaderboard
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
      // Error getting user rank
      return -1;
    }
  }

  // Analytics
  @override
  Future<Map<String, dynamic>> getUserAnalytics(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final sessions = await getUserStudySessions(userId, from: from, to: to);
      final stats = await getUserStats(userId);

      if (stats == null) return {};

      return {
        'totalSessions': sessions.length,
        'totalStudyTime': sessions.fold(
          0,
          (total, session) => total + session.durationMinutes,
        ),
        'totalXp': sessions.fold(
          0,
          (total, session) => total + session.xpEarned,
        ),
        'averageSessionLength': sessions.isNotEmpty
            ? sessions.fold(
                    0,
                    (total, session) => total + session.durationMinutes,
                  ) /
                  sessions.length
            : 0,
        'mostStudiedSubject': _getMostStudiedSubject(sessions),
        'streak': stats.currentStreak,
        'accuracy': stats.accuracyRate,
      };
    } catch (e) {
      // Error getting user analytics
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
      // Error getting subject progress
      return {};
    }
  }

  String _getMostStudiedSubject(List<StudySession> sessions) {
    if (sessions.isEmpty) return '';

    final subjectTime = <String, int>{};
    for (final session in sessions) {
      subjectTime[session.subjectId] =
          (subjectTime[session.subjectId] ?? 0) + session.durationMinutes;
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

  @override
  Future<void> updateStreak(String userId, int newStreak) async {
    try {
      final stats = await getUserStats(userId);
      if (stats != null) {
        final updatedStats = stats.copyWith(
          currentStreak: newStreak,
          longestStreak: newStreak > stats.longestStreak
              ? newStreak
              : stats.longestStreak,
          updatedAt: DateTime.now(),
        );
        await updateUserStats(updatedStats);

        // Create streak notification
        await NotificationService.createStreakNotification(userId, newStreak);
      }
    } catch (e) {
      // Error updating streak
      rethrow;
    }
  }
}
