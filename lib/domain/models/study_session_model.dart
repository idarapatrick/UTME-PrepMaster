import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String id;
  final String userId;
  final String subjectId;
  final String subjectName;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final int xpEarned;
  final List<String> activities; // ['quiz', 'reading', 'practice']
  final Map<String, dynamic> metadata; // Additional session data

  StudySession({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.subjectName,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.xpEarned,
    required this.activities,
    required this.metadata,
  });

  factory StudySession.fromMap(Map<String, dynamic> map, String id) {
    return StudySession(
      id: id,
      userId: map['userId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null ? (map['endTime'] as Timestamp).toDate() : null,
      durationMinutes: map['durationMinutes'] ?? 0,
      xpEarned: map['xpEarned'] ?? 0,
      activities: List<String>.from(map['activities'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'xpEarned': xpEarned,
      'activities': activities,
      'metadata': metadata,
    };
  }

  StudySession copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? subjectName,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? xpEarned,
    List<String>? activities,
    Map<String, dynamic>? metadata,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      xpEarned: xpEarned ?? this.xpEarned,
      activities: activities ?? this.activities,
      metadata: metadata ?? this.metadata,
    );
  }
} 