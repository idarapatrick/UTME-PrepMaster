import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final String userId;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastStudyDate;
  final int totalStudyTimeMinutes;
  final int totalSessions;
  final int quizzesCompleted;
  final int questionsAnswered;
  final int correctAnswers;
  final Map<String, int> subjectXp; // XP per subject
  final Map<String, int> subjectStudyTime; // Study time per subject
  final List<String> earnedBadges;
  final List<String> availableBadges;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserStats({
    required this.userId,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastStudyDate,
    required this.totalStudyTimeMinutes,
    required this.totalSessions,
    required this.quizzesCompleted,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.subjectXp,
    required this.subjectStudyTime,
    required this.earnedBadges,
    required this.availableBadges,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserStats.fromMap(Map<String, dynamic> map, String userId) {
    return UserStats(
      userId: userId,
      totalXp: map['totalXp'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastStudyDate: map['lastStudyDate'] != null 
          ? (map['lastStudyDate'] as Timestamp).toDate() 
          : DateTime.now(),
      totalStudyTimeMinutes: map['totalStudyTimeMinutes'] ?? 0,
      totalSessions: map['totalSessions'] ?? 0,
      quizzesCompleted: map['quizzesCompleted'] ?? 0,
      questionsAnswered: map['questionsAnswered'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      subjectXp: Map<String, int>.from(map['subjectXp'] ?? {}),
      subjectStudyTime: Map<String, int>.from(map['subjectStudyTime'] ?? {}),
      earnedBadges: List<String>.from(map['earnedBadges'] ?? []),
      availableBadges: List<String>.from(map['availableBadges'] ?? []),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalXp': totalXp,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStudyDate': Timestamp.fromDate(lastStudyDate),
      'totalStudyTimeMinutes': totalStudyTimeMinutes,
      'totalSessions': totalSessions,
      'quizzesCompleted': quizzesCompleted,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'subjectXp': subjectXp,
      'subjectStudyTime': subjectStudyTime,
      'earnedBadges': earnedBadges,
      'availableBadges': availableBadges,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserStats copyWith({
    String? userId,
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    int? totalStudyTimeMinutes,
    int? totalSessions,
    int? quizzesCompleted,
    int? questionsAnswered,
    int? correctAnswers,
    Map<String, int>? subjectXp,
    Map<String, int>? subjectStudyTime,
    List<String>? earnedBadges,
    List<String>? availableBadges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalStudyTimeMinutes: totalStudyTimeMinutes ?? this.totalStudyTimeMinutes,
      totalSessions: totalSessions ?? this.totalSessions,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      subjectXp: subjectXp ?? this.subjectXp,
      subjectStudyTime: subjectStudyTime ?? this.subjectStudyTime,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      availableBadges: availableBadges ?? this.availableBadges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  double get accuracyRate => questionsAnswered > 0 ? correctAnswers / questionsAnswered : 0.0;
  
  int get totalStudyHours => totalStudyTimeMinutes ~/ 60;
  
  int get totalStudyMinutes => totalStudyTimeMinutes % 60;
  
  String get formattedStudyTime {
    if (totalStudyHours > 0) {
      return '${totalStudyHours}h ${totalStudyMinutes}m';
    }
    return '${totalStudyMinutes}m';
  }

  int getXpForSubject(String subjectId) => subjectXp[subjectId] ?? 0;
  
  int getStudyTimeForSubject(String subjectId) => subjectStudyTime[subjectId] ?? 0;
  
  bool hasBadge(String badgeId) => earnedBadges.contains(badgeId);
} 