import 'package:cloud_firestore/cloud_firestore.dart';

enum BadgeType {
  streak,      // Daily streak badges
  xp,          // XP milestone badges
  studyTime,   // Study time badges
  accuracy,    // Quiz accuracy badges
  subject,     // Subject-specific badges
  special,     // Special event badges
}

enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}

class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeType type;
  final BadgeRarity rarity;
  final String? imagePath;
  final int requirement; // XP, streak days, study hours, etc.
  final String? subjectId; // For subject-specific badges
  final DateTime? availableFrom;
  final DateTime? availableUntil;
  final bool isActive;
  final int xpReward; // XP given when badge is earned

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    this.imagePath,
    required this.requirement,
    this.subjectId,
    this.availableFrom,
    this.availableUntil,
    required this.isActive,
    required this.xpReward,
  });

  factory Badge.fromMap(Map<String, dynamic> map, String id) {
    return Badge(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: BadgeType.values.firstWhere(
        (e) => e.toString() == 'BadgeType.${map['type']}',
        orElse: () => BadgeType.streak,
      ),
      rarity: BadgeRarity.values.firstWhere(
        (e) => e.toString() == 'BadgeRarity.${map['rarity']}',
        orElse: () => BadgeRarity.common,
      ),
      imagePath: map['imagePath'],
      requirement: map['requirement'] ?? 0,
      subjectId: map['subjectId'],
      availableFrom: map['availableFrom'] != null 
          ? (map['availableFrom'] as Timestamp).toDate() 
          : null,
      availableUntil: map['availableUntil'] != null 
          ? (map['availableUntil'] as Timestamp).toDate() 
          : null,
      isActive: map['isActive'] ?? true,
      xpReward: map['xpReward'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'rarity': rarity.toString().split('.').last,
      'imagePath': imagePath,
      'requirement': requirement,
      'subjectId': subjectId,
      'availableFrom': availableFrom != null ? Timestamp.fromDate(availableFrom!) : null,
      'availableUntil': availableUntil != null ? Timestamp.fromDate(availableUntil!) : null,
      'isActive': isActive,
      'xpReward': xpReward,
    };
  }

  // Helper methods
  bool get isAvailable {
    final now = DateTime.now();
    if (!isActive) return false;
    if (availableFrom != null && now.isBefore(availableFrom!)) return false;
    if (availableUntil != null && now.isAfter(availableUntil!)) return false;
    return true;
  }

  String get rarityColor {
    switch (rarity) {
      case BadgeRarity.common:
        return '#9CA3AF'; // Gray
      case BadgeRarity.rare:
        return '#3B82F6'; // Blue
      case BadgeRarity.epic:
        return '#8B5CF6'; // Purple
      case BadgeRarity.legendary:
        return '#F59E0B'; // Orange
    }
  }

  String get requirementText {
    switch (type) {
      case BadgeType.streak:
        return '$requirement day${requirement > 1 ? 's' : ''} streak';
      case BadgeType.xp:
        return '$requirement XP';
      case BadgeType.studyTime:
        return '${requirement}h study time';
      case BadgeType.accuracy:
        return '$requirement% accuracy';
      case BadgeType.subject:
        return '$requirement questions in ${subjectId ?? 'subject'}';
      case BadgeType.special:
        return description;
    }
  }
} 