import '../models/user_stats_model.dart';
import '../models/study_session_model.dart';

abstract class UserStatsRepository {
  // User Stats
  Future<UserStats?> getUserStats(String userId);
  Future<void> createUserStats(UserStats stats);
  Future<void> updateUserStats(UserStats stats);
  Stream<UserStats?> getUserStatsStream(String userId);

  // Study Sessions
  Future<void> startStudySession(StudySession session);
  Future<void> endStudySession(
    String sessionId,
    DateTime endTime,
    int durationMinutes,
    int xpEarned,
  );
  Future<List<StudySession>> getUserStudySessions(
    String userId, {
    DateTime? from,
    DateTime? to,
  });
  Stream<List<StudySession>> getUserStudySessionsStream(String userId);

  // XP and Streak Management
  Future<void> addXp(
    String userId,
    int xp, {
    String? subjectId,
    String? reason,
  });
  Future<void> updateStreak(String userId, int newStreak);
  Future<void> checkAndUpdateStreak(String userId);

  // Badge Management
  Future<void> awardBadge(String userId, String badgeId);
  Future<List<String>> getAvailableBadges(String userId);
  Future<void> checkAndAwardBadges(String userId);

  // Leaderboard
  Future<List<UserStats>> getLeaderboard({int limit = 50});
  Future<int> getUserRank(String userId);

  // Analytics
  Future<Map<String, dynamic>> getUserAnalytics(
    String userId, {
    DateTime? from,
    DateTime? to,
  });
  Future<Map<String, int>> getSubjectProgress(String userId);
}
