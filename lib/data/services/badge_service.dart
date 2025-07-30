import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sample badge data
  static const List<Map<String, dynamic>> _sampleBadges = [
    {
      'name': 'First Steps',
      'description': 'Complete your first study session',
      'type': 'streak',
      'rarity': 'common',
      'requirement': 1,
      'xpReward': 50,
      'isActive': true,
    },
    {
      'name': 'Week Warrior',
      'description': 'Maintain a 7-day study streak',
      'type': 'streak',
      'rarity': 'rare',
      'requirement': 7,
      'xpReward': 100,
      'isActive': true,
    },
    {
      'name': 'Month Master',
      'description': 'Maintain a 30-day study streak',
      'type': 'streak',
      'rarity': 'epic',
      'requirement': 30,
      'xpReward': 500,
      'isActive': true,
    },
    {
      'name': 'XP Novice',
      'description': 'Earn your first 100 XP',
      'type': 'xp',
      'rarity': 'common',
      'requirement': 100,
      'xpReward': 25,
      'isActive': true,
    },
    {
      'name': 'XP Explorer',
      'description': 'Earn 500 XP',
      'type': 'xp',
      'rarity': 'rare',
      'requirement': 500,
      'xpReward': 100,
      'isActive': true,
    },
    {
      'name': 'XP Master',
      'description': 'Earn 1000 XP',
      'type': 'xp',
      'rarity': 'epic',
      'requirement': 1000,
      'xpReward': 250,
      'isActive': true,
    },
    {
      'name': 'XP Legend',
      'description': 'Earn 5000 XP',
      'type': 'xp',
      'rarity': 'legendary',
      'requirement': 5000,
      'xpReward': 1000,
      'isActive': true,
    },
    {
      'name': 'Study Beginner',
      'description': 'Study for 1 hour total',
      'type': 'studyTime',
      'rarity': 'common',
      'requirement': 1,
      'xpReward': 50,
      'isActive': true,
    },
    {
      'name': 'Study Enthusiast',
      'description': 'Study for 10 hours total',
      'type': 'studyTime',
      'rarity': 'rare',
      'requirement': 10,
      'xpReward': 200,
      'isActive': true,
    },
    {
      'name': 'Study Master',
      'description': 'Study for 50 hours total',
      'type': 'studyTime',
      'rarity': 'epic',
      'requirement': 50,
      'xpReward': 500,
      'isActive': true,
    },
    {
      'name': 'Accuracy Ace',
      'description': 'Achieve 90% accuracy in quizzes',
      'type': 'accuracy',
      'rarity': 'rare',
      'requirement': 90,
      'xpReward': 150,
      'isActive': true,
    },
    {
      'name': 'Perfect Score',
      'description': 'Achieve 100% accuracy in a quiz',
      'type': 'accuracy',
      'rarity': 'epic',
      'requirement': 100,
      'xpReward': 300,
      'isActive': true,
    },
    {
      'name': 'English Expert',
      'description': 'Earn 200 XP in English',
      'type': 'subject',
      'rarity': 'rare',
      'requirement': 200,
      'subjectId': 'English',
      'xpReward': 100,
      'isActive': true,
    },
    {
      'name': 'Math Master',
      'description': 'Earn 200 XP in Mathematics',
      'type': 'subject',
      'rarity': 'rare',
      'requirement': 200,
      'subjectId': 'Mathematics',
      'xpReward': 100,
      'isActive': true,
    },
    {
      'name': 'Science Scholar',
      'description': 'Earn 200 XP in Physics',
      'type': 'subject',
      'rarity': 'rare',
      'requirement': 200,
      'subjectId': 'Physics',
      'xpReward': 100,
      'isActive': true,
    },
    {
      'name': 'Chemistry Champion',
      'description': 'Earn 200 XP in Chemistry',
      'type': 'subject',
      'rarity': 'rare',
      'requirement': 200,
      'subjectId': 'Chemistry',
      'xpReward': 100,
      'isActive': true,
    },
    {
      'name': 'Biology Buff',
      'description': 'Earn 200 XP in Biology',
      'type': 'subject',
      'rarity': 'rare',
      'requirement': 200,
      'subjectId': 'Biology',
      'xpReward': 100,
      'isActive': true,
    },
    {
      'name': 'Quiz Champion',
      'description': 'Complete 10 quizzes',
      'type': 'special',
      'rarity': 'rare',
      'requirement': 10,
      'xpReward': 200,
      'isActive': true,
    },
    {
      'name': 'Early Bird',
      'description': 'Study before 8 AM',
      'type': 'special',
      'rarity': 'common',
      'requirement': 1,
      'xpReward': 50,
      'isActive': true,
    },
    {
      'name': 'Night Owl',
      'description': 'Study after 10 PM',
      'type': 'special',
      'rarity': 'common',
      'requirement': 1,
      'xpReward': 50,
      'isActive': true,
    },
  ];

  /// Initialize sample badges in Firebase
  static Future<void> initializeSampleBadges() async {
    try {
      final batch = _firestore.batch();
      
      for (int i = 0; i < _sampleBadges.length; i++) {
        final badge = _sampleBadges[i];
        final docRef = _firestore.collection('badges').doc('badge_${i + 1}');
        batch.set(docRef, {
          ...badge,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      print('Sample badges initialized successfully');
    } catch (e) {
      print('Error initializing sample badges: $e');
    }
  }

  /// Get all badges
  static Future<List<Map<String, dynamic>>> getAllBadges() async {
    try {
      final snapshot = await _firestore.collection('badges').get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting badges: $e');
      return [];
    }
  }

  /// Get badge by ID
  static Future<Map<String, dynamic>?> getBadgeById(String badgeId) async {
    try {
      final doc = await _firestore.collection('badges').doc(badgeId).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
        };
      }
      return null;
    } catch (e) {
      print('Error getting badge: $e');
      return null;
    }
  }
} 