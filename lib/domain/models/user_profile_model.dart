import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final int studyStreak;
  final int totalStudyTime; // in minutes
  final int badgesCount;
  final String? avatarUrl;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.studyStreak = 0,
    this.totalStudyTime = 0,
    this.badgesCount = 0,
    this.avatarUrl,
  });

  /// Factory constructor: Map from Firestore → UserProfile
  factory UserProfile.fromMap(Map<String, dynamic> data, String documentId) {
    return UserProfile(
      uid: documentId,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      studyStreak: data['studyStreak'] ?? 0,
      totalStudyTime: data['totalStudyTime'] ?? 0,
      badgesCount: data['badgesCount'] ?? 0,
      avatarUrl: data['avatarUrl'],
    );
  }

  /// Convert UserProfile to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'studyStreak': studyStreak,
      'totalStudyTime': totalStudyTime,
      'badgesCount': badgesCount,
      'avatarUrl': avatarUrl,
    };
  }
}
