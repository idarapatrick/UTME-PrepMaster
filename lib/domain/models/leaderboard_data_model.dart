import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int score;
  final int rank;
  final DateTime lastUpdated;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.score,
    required this.rank,
    required this.lastUpdated,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> data, int rank) {
    return LeaderboardEntry(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? 'Anonymous',
      photoUrl: data['photoUrl'],
      score: data['score'] ?? 0,
      rank: rank,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'score': score,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

class LeaderboardDataModel {
  final List<LeaderboardEntry> xpLeaderboard;
  final List<LeaderboardEntry> cbtLeaderboard;
  final DateTime lastFetched;
  final LeaderboardEntry? userXpEntry;
  final LeaderboardEntry? userCbtEntry;

  const LeaderboardDataModel({
    required this.xpLeaderboard,
    required this.cbtLeaderboard,
    required this.lastFetched,
    this.userXpEntry,
    this.userCbtEntry,
  });

  factory LeaderboardDataModel.empty() {
    return LeaderboardDataModel(
      xpLeaderboard: [],
      cbtLeaderboard: [],
      lastFetched: DateTime.now(),
    );
  }

  LeaderboardDataModel copyWith({
    List<LeaderboardEntry>? xpLeaderboard,
    List<LeaderboardEntry>? cbtLeaderboard,
    DateTime? lastFetched,
    LeaderboardEntry? userXpEntry,
    LeaderboardEntry? userCbtEntry,
  }) {
    return LeaderboardDataModel(
      xpLeaderboard: xpLeaderboard ?? this.xpLeaderboard,
      cbtLeaderboard: cbtLeaderboard ?? this.cbtLeaderboard,
      lastFetched: lastFetched ?? this.lastFetched,
      userXpEntry: userXpEntry ?? this.userXpEntry,
      userCbtEntry: userCbtEntry ?? this.userCbtEntry,
    );
  }

  bool get needsRefresh {
    return DateTime.now().difference(lastFetched).inMinutes > 5;
  }
}
