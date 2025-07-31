import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectProgress {
  final String subject;
  final double completion;
  final int totalTopics;
  final int completedTopics;
  final DateTime lastStudied;
  final Duration totalTimeSpent;

  const SubjectProgress({
    required this.subject,
    required this.completion,
    required this.totalTopics,
    required this.completedTopics,
    required this.lastStudied,
    required this.totalTimeSpent,
  });

  factory SubjectProgress.fromMap(Map<String, dynamic> data) {
    return SubjectProgress(
      subject: data['subject'] ?? '',
      completion: (data['completion'] ?? 0.0).toDouble(),
      totalTopics: data['totalTopics'] ?? 0,
      completedTopics: data['completedTopics'] ?? 0,
      lastStudied: (data['lastStudied'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalTimeSpent: Duration(seconds: data['totalTimeSpent'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'completion': completion,
      'totalTopics': totalTopics,
      'completedTopics': completedTopics,
      'lastStudied': Timestamp.fromDate(lastStudied),
      'totalTimeSpent': totalTimeSpent.inSeconds,
    };
  }
}

class TestResult {
  final String subject;
  final int score;
  final int totalQuestions;
  final double percentage;
  final Duration duration;
  final DateTime timestamp;
  final String testType; // 'quiz', 'mock', 'practice'

  const TestResult({
    required this.subject,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.duration,
    required this.timestamp,
    required this.testType,
  });

  factory TestResult.fromMap(Map<String, dynamic> data) {
    return TestResult(
      subject: data['subject'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      duration: Duration(seconds: data['duration'] ?? 0),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      testType: data['testType'] ?? 'quiz',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'duration': duration.inSeconds,
      'timestamp': Timestamp.fromDate(timestamp),
      'testType': testType,
    };
  }
}

class ProgressTrackingModel {
  final String userId;
  final Map<String, SubjectProgress> subjectProgress;
  final List<TestResult> recentTests;
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final int cbtHighScore;
  final DateTime lastActivity;
  final Map<String, int> weeklyStats; // day -> minutes studied

  const ProgressTrackingModel({
    required this.userId,
    required this.subjectProgress,
    required this.recentTests,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXp,
    required this.cbtHighScore,
    required this.lastActivity,
    required this.weeklyStats,
  });

  factory ProgressTrackingModel.fromMap(Map<String, dynamic> data, String userId) {
    final subjectProgressData = data['subjectProgress'] as Map<String, dynamic>? ?? {};
    final subjectProgress = <String, SubjectProgress>{};
    
    subjectProgressData.forEach((key, value) {
      subjectProgress[key] = SubjectProgress.fromMap(value as Map<String, dynamic>);
    });

    final recentTestsData = data['recentTests'] as List<dynamic>? ?? [];
    final recentTests = recentTestsData
        .map((test) => TestResult.fromMap(test as Map<String, dynamic>))
        .toList();

    final weeklyStatsData = data['weeklyStats'] as Map<String, dynamic>? ?? {};
    final weeklyStats = <String, int>{};
    weeklyStatsData.forEach((key, value) {
      weeklyStats[key] = value as int;
    });

    return ProgressTrackingModel(
      userId: userId,
      subjectProgress: subjectProgress,
      recentTests: recentTests,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalXp: data['totalXp'] ?? 0,
      cbtHighScore: data['cbtHighScore'] ?? 0,
      lastActivity: (data['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weeklyStats: weeklyStats,
    );
  }

  Map<String, dynamic> toMap() {
    final subjectProgressMap = <String, dynamic>{};
    subjectProgress.forEach((key, value) {
      subjectProgressMap[key] = value.toMap();
    });

    final recentTestsMap = recentTests.map((test) => test.toMap()).toList();

    return {
      'subjectProgress': subjectProgressMap,
      'recentTests': recentTestsMap,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalXp': totalXp,
      'cbtHighScore': cbtHighScore,
      'lastActivity': Timestamp.fromDate(lastActivity),
      'weeklyStats': weeklyStats,
    };
  }

  factory ProgressTrackingModel.empty(String userId) {
    return ProgressTrackingModel(
      userId: userId,
      subjectProgress: {},
      recentTests: [],
      currentStreak: 0,
      longestStreak: 0,
      totalXp: 0,
      cbtHighScore: 0,
      lastActivity: DateTime.now(),
      weeklyStats: {},
    );
  }

  ProgressTrackingModel copyWith({
    Map<String, SubjectProgress>? subjectProgress,
    List<TestResult>? recentTests,
    int? currentStreak,
    int? longestStreak,
    int? totalXp,
    int? cbtHighScore,
    DateTime? lastActivity,
    Map<String, int>? weeklyStats,
  }) {
    return ProgressTrackingModel(
      userId: userId,
      subjectProgress: subjectProgress ?? this.subjectProgress,
      recentTests: recentTests ?? this.recentTests,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalXp: totalXp ?? this.totalXp,
      cbtHighScore: cbtHighScore ?? this.cbtHighScore,
      lastActivity: lastActivity ?? this.lastActivity,
      weeklyStats: weeklyStats ?? this.weeklyStats,
    );
  }

  double get averageScore {
    if (recentTests.isEmpty) return 0.0;
    return recentTests.map((test) => test.percentage).reduce((a, b) => a + b) / recentTests.length;
  }

  Duration get totalStudyTime {
    return recentTests.fold(Duration.zero, (total, test) => total + test.duration);
  }

  bool get isActiveToday {
    final today = DateTime.now();
    return lastActivity.year == today.year &&
           lastActivity.month == today.month &&
           lastActivity.day == today.day;
  }
}
