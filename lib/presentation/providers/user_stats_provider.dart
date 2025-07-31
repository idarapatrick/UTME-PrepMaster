import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_stats_model.dart';
import '../../domain/models/study_session_model.dart';
import '../../domain/usecases/track_study_session_usecase.dart';
import '../../domain/usecases/quiz_completion_usecase.dart';
import '../../data/repositories/user_stats_repository_impl.dart';

class UserStatsProvider extends ChangeNotifier {
  final UserStatsRepositoryImpl _repository = UserStatsRepositoryImpl();
  final TrackStudySessionUseCase _trackSessionUseCase;
  final QuizCompletionUseCase _quizCompletionUseCase;
  
  UserStats? _userStats;
  List<StudySession> _recentSessions = [];
  bool _isLoading = false;
  String? _error;
  
  // Animation controllers
  bool _showXpAnimation = false;
  int _lastXpEarned = 0;
  bool _showStreakAnimation = false;
  int _lastStreakCount = 0;
  bool _showBadgeAnimation = false;
  String? _lastBadgeEarned;

  UserStatsProvider()
      : _trackSessionUseCase = TrackStudySessionUseCase(UserStatsRepositoryImpl()),
        _quizCompletionUseCase = QuizCompletionUseCase(UserStatsRepositoryImpl());

  // Getters
  UserStats? get userStats => _userStats;
  List<StudySession> get recentSessions => _recentSessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showXpAnimation => _showXpAnimation;
  int get lastXpEarned => _lastXpEarned;
  bool get showStreakAnimation => _showStreakAnimation;
  int get lastStreakCount => _lastStreakCount;
  bool get showBadgeAnimation => _showBadgeAnimation;
  String? get lastBadgeEarned => _lastBadgeEarned;

  // Initialize user stats
  Future<void> initializeUserStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // No user found, skipping user stats initialization
      return;
    }

    _setLoading(true);
    try {
      // Load user stats from Firebase
      _userStats = await _repository.getUserStats(user.uid);
      
      if (_userStats == null) {
        // Create default stats for new user
        _userStats = UserStats(
          userId: user.uid,
          totalXp: 0,
          currentStreak: 0,
          longestStreak: 0,
          lastStudyDate: DateTime.now(),
          totalStudyTimeMinutes: 0,
          totalSessions: 0,
          quizzesCompleted: 0,
          questionsAnswered: 0,
          correctAnswers: 0,
          subjectXp: {},
          subjectStudyTime: {},
          earnedBadges: [],
          availableBadges: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _repository.createUserStats(_userStats!);
      }
      
      // Load recent sessions
      await _loadRecentSessions();
      
      // Listen to real-time updates
      _listenToUserStats(user.uid);
      
      // Save state to local storage as backup
      await _saveStateToLocal();
      
    } catch (e) {
      _setError('Failed to load user stats: $e');
      // Try to load from local backup
      await _loadStateFromLocal();
    } finally {
      _setLoading(false);
    }
  }

  void _listenToUserStats(String userId) {
    _repository.getUserStatsStream(userId).listen((stats) {
      if (stats != null) {
        _handleStatsUpdate(stats);
      }
    });
  }

  void _handleStatsUpdate(UserStats newStats) {
    if (_userStats != null) {
      // Check for XP increase
      if (newStats.totalXp > _userStats!.totalXp) {
        _lastXpEarned = newStats.totalXp - _userStats!.totalXp;
        _showXpAnimation = true;
        notifyListeners();
        
        // Hide animation after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          _showXpAnimation = false;
          notifyListeners();
        });
      }
      
      // Check for streak increase
      if (newStats.currentStreak > _userStats!.currentStreak) {
        _lastStreakCount = newStats.currentStreak;
        _showStreakAnimation = true;
        notifyListeners();
        
        // Hide animation after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          _showStreakAnimation = false;
          notifyListeners();
        });
      }
      
      // Check for new badges
      final newBadges = newStats.earnedBadges
          .where((badge) => !_userStats!.earnedBadges.contains(badge))
          .toList();
      
      if (newBadges.isNotEmpty) {
        _lastBadgeEarned = newBadges.first;
        _showBadgeAnimation = true;
        notifyListeners();
        
        // Hide animation after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          _showBadgeAnimation = false;
          notifyListeners();
        });
      }
    }
    
    _userStats = newStats;
    notifyListeners();
    _autoSaveState(); // Auto-save when stats update
  }

  Future<void> _loadRecentSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      _recentSessions = await _repository.getUserStudySessions(
        user.uid,
        from: DateTime.now().subtract(const Duration(days: 7)),
      );
      notifyListeners();
    } catch (e) {
      // Error loading recent sessions
    }
  }

  // Study Session Management
  Future<void> startStudySession({
    required String subjectId,
    required String subjectName,
    List<String> activities = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _trackSessionUseCase.startSession(
        userId: user.uid,
        subjectId: subjectId,
        subjectName: subjectName,
        activities: activities,
        metadata: metadata,
      );
    } catch (e) {
      _setError('Failed to start study session: $e');
    }
  }

  Future<void> endStudySession({
    required String sessionId,
    required String subjectId,
    int baseXp = 10,
    Map<String, int> activityXp = const {},
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _trackSessionUseCase.endSession(
        sessionId: sessionId,
        userId: user.uid,
        subjectId: subjectId,
        baseXp: baseXp,
        activityXp: activityXp,
      );
    } catch (e) {
      _setError('Failed to end study session: $e');
    }
  }

  // Quiz Completion
  Future<void> completeQuiz({
    required String subjectId,
    required int totalQuestions,
    required int correctAnswers,
    required int timeSpentMinutes,
    Map<String, int> bonusXp = const {},
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _quizCompletionUseCase.completeQuiz(
        userId: user.uid,
        subjectId: subjectId,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        timeSpentMinutes: timeSpentMinutes,
        bonusXp: bonusXp,
      );
    } catch (e) {
      _setError('Failed to complete quiz: $e');
    }
  }

  // Enhanced Quiz Completion with new XP system
  Future<void> completeQuizWithNewSystem({
    required String subjectId,
    required int totalQuestions,
    required int correctAnswers,
    required int timeSpentMinutes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _repository.completeQuiz(
        user.uid,
        subjectId,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        timeSpentMinutes: timeSpentMinutes,
      );
    } catch (e) {
      _setError('Failed to complete quiz: $e');
    }
  }

  // CBT Test Start (20 XP for starting CBT)
  Future<void> startCbtTest(String subjectId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _repository.startCbtTest(user.uid, subjectId);
    } catch (e) {
      _setError('Failed to start CBT test: $e');
    }
  }

  // Daily Login Check
  Future<void> checkDailyLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _repository.checkDailyLogin(user.uid);
    } catch (e) {
      _setError('Failed to check daily login: $e');
    }
  }

  // Manual XP Addition
  Future<void> addXp(int xp, {String? subjectId, String? reason}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _repository.addXp(user.uid, xp, subjectId: subjectId, reason: reason);
    } catch (e) {
      _setError('Failed to add XP: $e');
    }
  }

  // Leaderboard
  Future<List<UserStats>> getLeaderboard({int limit = 50}) async {
    try {
      return await _repository.getLeaderboard(limit: limit);
    } catch (e) {
      _setError('Failed to load leaderboard: $e');
      return [];
    }
  }

  Future<int> getUserRank() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return -1;

    try {
      return await _repository.getUserRank(user.uid);
    } catch (e) {
      _setError('Failed to get user rank: $e');
      return -1;
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getUserAnalytics({DateTime? from, DateTime? to}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    try {
      return await _repository.getUserAnalytics(user.uid, from: from, to: to);
    } catch (e) {
      _setError('Failed to load analytics: $e');
      return {};
    }
  }

  Future<Map<String, int>> getSubjectProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    try {
      return await _repository.getSubjectProgress(user.uid);
    } catch (e) {
      _setError('Failed to load subject progress: $e');
      return {};
    }
  }

  // Badge Management
  Future<List<String>> getAvailableBadges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      return await _repository.getAvailableBadges(user.uid);
    } catch (e) {
      _setError('Failed to load available badges: $e');
      return [];
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Animation control
  void hideXpAnimation() {
    _showXpAnimation = false;
    notifyListeners();
  }

  void hideStreakAnimation() {
    _showStreakAnimation = false;
    notifyListeners();
  }

  void hideBadgeAnimation() {
    _showBadgeAnimation = false;
    notifyListeners();
  }

  // Local Storage Methods
  Future<void> _saveStateToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final stateData = {
        'userStats': _userStats?.toMap(),
        'recentSessions': _recentSessions.map((session) => session.toMap()).toList(),
        'lastSaved': DateTime.now().toIso8601String(),
      };

      await prefs.setString('user_stats_${user.uid}', jsonEncode(stateData));
      // State saved to local storage
    } catch (e) {
      // Error saving state to local storage
    }
  }

  Future<void> _loadStateFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final stateJson = prefs.getString('user_stats_${user.uid}');
      if (stateJson != null) {
        final stateData = jsonDecode(stateJson);
        
        if (stateData['userStats'] != null) {
          _userStats = UserStats.fromMap(stateData['userStats'], user.uid);
        }
        
        if (stateData['recentSessions'] != null) {
          _recentSessions = (stateData['recentSessions'] as List)
              .map((sessionData) => StudySession.fromMap(sessionData, ''))
              .toList();
        }
        
        notifyListeners();
        // State loaded from local storage
      }
    } catch (e) {
      // Error loading state from local storage
    }
  }

  // Auto-save state when data changes
  void _autoSaveState() {
    _saveStateToLocal();
  }
} 