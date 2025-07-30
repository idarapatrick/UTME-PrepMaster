import '../models/study_session_model.dart';
import '../models/user_stats_model.dart';
import '../repositories/user_stats_repository.dart';

class TrackStudySessionUseCase {
  final UserStatsRepository _userStatsRepository;

  TrackStudySessionUseCase(this._userStatsRepository);

  Future<void> startSession({
    required String userId,
    required String subjectId,
    required String subjectName,
    List<String> activities = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    final session = StudySession(
      id: '', // Will be set by Firestore
      userId: userId,
      subjectId: subjectId,
      subjectName: subjectName,
      startTime: DateTime.now(),
      durationMinutes: 0,
      xpEarned: 0,
      activities: activities,
      metadata: metadata,
    );

    await _userStatsRepository.startStudySession(session);
  }

  Future<void> endSession({
    required String sessionId,
    required String userId,
    required String subjectId,
    int baseXp = 10,
    Map<String, int> activityXp = const {},
  }) async {
    final endTime = DateTime.now();
    
    // Calculate session duration
    final session = await _getCurrentSession(sessionId);
    if (session == null) return;
    
    final duration = endTime.difference(session.startTime).inMinutes;
    
    // Calculate XP based on activities and duration
    int totalXp = baseXp;
    
    // Add XP for each activity
    for (final activity in session.activities) {
      totalXp += activityXp[activity] ?? 5;
    }
    
    // Add XP for duration (1 XP per 5 minutes)
    totalXp += (duration ~/ 5);
    
    // End the session
    await _userStatsRepository.endStudySession(sessionId, endTime, duration, totalXp);
    
    // Update user stats
    await _updateUserStatsAfterSession(userId, subjectId, duration, totalXp);
    
    // Check for streak updates
    await _userStatsRepository.checkAndUpdateStreak(userId);
    
    // Check for new badges
    await _userStatsRepository.checkAndAwardBadges(userId);
  }

  Future<void> _updateUserStatsAfterSession(
    String userId,
    String subjectId,
    int durationMinutes,
    int xpEarned,
  ) async {
    final currentStats = await _userStatsRepository.getUserStats(userId);
    
    if (currentStats == null) {
      // Create new user stats
      final newStats = UserStats(
        userId: userId,
        totalXp: xpEarned,
        currentStreak: 1,
        longestStreak: 1,
        lastStudyDate: DateTime.now(),
        totalStudyTimeMinutes: durationMinutes,
        totalSessions: 1,
        quizzesCompleted: 0,
        questionsAnswered: 0,
        correctAnswers: 0,
        subjectXp: {subjectId: xpEarned},
        subjectStudyTime: {subjectId: durationMinutes},
        earnedBadges: [],
        availableBadges: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userStatsRepository.createUserStats(newStats);
    } else {
      // Update existing stats
      final updatedSubjectXp = Map<String, int>.from(currentStats.subjectXp);
      final updatedSubjectStudyTime = Map<String, int>.from(currentStats.subjectStudyTime);
      
      updatedSubjectXp[subjectId] = (updatedSubjectXp[subjectId] ?? 0) + xpEarned;
      updatedSubjectStudyTime[subjectId] = (updatedSubjectStudyTime[subjectId] ?? 0) + durationMinutes;
      
      final updatedStats = currentStats.copyWith(
        totalXp: currentStats.totalXp + xpEarned,
        totalStudyTimeMinutes: currentStats.totalStudyTimeMinutes + durationMinutes,
        totalSessions: currentStats.totalSessions + 1,
        lastStudyDate: DateTime.now(),
        subjectXp: updatedSubjectXp,
        subjectStudyTime: updatedSubjectStudyTime,
        updatedAt: DateTime.now(),
      );
      
      await _userStatsRepository.updateUserStats(updatedStats);
    }
  }

  Future<StudySession?> _getCurrentSession(String sessionId) async {
    // This would typically get the session from the repository
    // For now, we'll return null as the session management is handled differently
    return null;
  }
} 