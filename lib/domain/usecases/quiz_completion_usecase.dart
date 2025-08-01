import '../models/user_stats_model.dart';
import '../repositories/user_stats_repository.dart';

class QuizCompletionUseCase {
  final UserStatsRepository _userStatsRepository;

  QuizCompletionUseCase(this._userStatsRepository);

  Future<void> completeQuiz({
    required String userId,
    required String subjectId,
    required int totalQuestions,
    required int correctAnswers,
    required int timeSpentMinutes,
    Map<String, int> bonusXp = const {},
  }) async {
    // Calculate base XP
    int baseXp = 20; // Base XP for completing a quiz

    // Add XP for correct answers (5 XP per correct answer)
    int accuracyXp = correctAnswers * 5;

    // Add XP for speed (bonus for completing quickly)
    int speedXp = _calculateSpeedBonus(timeSpentMinutes, totalQuestions);

    // Add XP for accuracy bonus
    int accuracyBonusXp = _calculateAccuracyBonus(
      correctAnswers,
      totalQuestions,
    );

    // Add subject-specific bonus XP
    int subjectBonusXp = bonusXp[subjectId] ?? 0;

    int totalXp =
        baseXp + accuracyXp + speedXp + accuracyBonusXp + subjectBonusXp;

    // Update user stats
    await _updateUserStatsAfterQuiz(
      userId: userId,
      subjectId: subjectId,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      timeSpentMinutes: timeSpentMinutes,
      xpEarned: totalXp,
    );

    // Check for streak updates
    await _userStatsRepository.checkAndUpdateStreak(userId);

    // Check for new badges
    await _userStatsRepository.checkAndAwardBadges(userId);
  }

  int _calculateSpeedBonus(int timeSpentMinutes, int totalQuestions) {
    // Bonus XP for completing questions quickly
    // Less than 1 minute per question = 10 XP bonus
    // Less than 30 seconds per question = 20 XP bonus
    double minutesPerQuestion = timeSpentMinutes / totalQuestions;

    if (minutesPerQuestion < 0.5) return 20; // 30 seconds per question
    if (minutesPerQuestion < 1.0) return 10; // 1 minute per question
    return 0;
  }

  int _calculateAccuracyBonus(int correctAnswers, int totalQuestions) {
    double accuracy = correctAnswers / totalQuestions;

    if (accuracy >= 0.9) return 30; // 90%+ accuracy = 30 XP bonus
    if (accuracy >= 0.8) return 20; // 80%+ accuracy = 20 XP bonus
    if (accuracy >= 0.7) return 10; // 70%+ accuracy = 10 XP bonus
    return 0;
  }

  Future<void> _updateUserStatsAfterQuiz({
    required String userId,
    required String subjectId,
    required int totalQuestions,
    required int correctAnswers,
    required int timeSpentMinutes,
    required int xpEarned,
  }) async {
    final currentStats = await _userStatsRepository.getUserStats(userId);

    if (currentStats == null) {
      // Create new user stats
      final newStats = UserStats(
        userId: userId,
        totalXp: xpEarned,
        currentStreak: 1,
        longestStreak: 1,
        lastStudyDate: DateTime.now(),
        totalStudyTimeMinutes: timeSpentMinutes,
        totalSessions: 0,
        quizzesCompleted: 1,
        questionsAnswered: totalQuestions,
        correctAnswers: correctAnswers,
        subjectXp: {subjectId: xpEarned},
        subjectStudyTime: {subjectId: timeSpentMinutes},
        earnedBadges: [],
        availableBadges: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userStatsRepository.createUserStats(newStats);
    } else {
      // Update existing stats
      final updatedSubjectXp = Map<String, int>.from(currentStats.subjectXp);
      final updatedSubjectStudyTime = Map<String, int>.from(
        currentStats.subjectStudyTime,
      );

      updatedSubjectXp[subjectId] =
          (updatedSubjectXp[subjectId] ?? 0) + xpEarned;
      updatedSubjectStudyTime[subjectId] =
          (updatedSubjectStudyTime[subjectId] ?? 0) + timeSpentMinutes;

      final updatedStats = currentStats.copyWith(
        totalXp: currentStats.totalXp + xpEarned,
        totalStudyTimeMinutes:
            currentStats.totalStudyTimeMinutes + timeSpentMinutes,
        quizzesCompleted: currentStats.quizzesCompleted + 1,
        questionsAnswered: currentStats.questionsAnswered + totalQuestions,
        correctAnswers: currentStats.correctAnswers + correctAnswers,
        lastStudyDate: DateTime.now(),
        subjectXp: updatedSubjectXp,
        subjectStudyTime: updatedSubjectStudyTime,
        updatedAt: DateTime.now(),
      );

      await _userStatsRepository.updateUserStats(updatedStats);
    }
  }
}
