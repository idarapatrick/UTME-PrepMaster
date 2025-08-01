import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates a notification for a user
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
            'title': title,
            'message': message,
            'type': type,
            'data': data ?? {},
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      // Error creating notification
    }
  }

  /// Creates welcome notification for new user
  static Future<void> createWelcomeNotification(
    String userId,
    String userName,
  ) async {
    await createNotification(
      userId: userId,
      title: 'Welcome to UTME PrepMaster! 🎉',
      message:
          'Hi $userName! Welcome to your learning journey. Start by selecting your subjects and take your first mock test!',
      type: 'welcome',
    );
  }

  /// Creates streak notification
  static Future<void> createStreakNotification(
    String userId,
    int streakDays,
  ) async {
    String title, message;

    if (streakDays == 1) {
      title = 'Streak Started! 🔥';
      message = 'Great! You\'ve started your study streak. Keep it going!';
    } else if (streakDays % 7 == 0) {
      title = 'Weekly Streak! 🎯';
      message =
          'Amazing! You\'ve maintained a $streakDays day streak. You\'re on fire!';
    } else {
      title = 'Streak Update! 🔥';
      message =
          'You\'re on a $streakDays day study streak. Keep up the great work!';
    }

    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'streak',
      data: {'streakDays': streakDays},
    );
  }

  /// Creates XP earned notification
  static Future<void> createXpNotification(
    String userId,
    int xpEarned,
    String reason,
  ) async {
    String title, message;

    switch (reason) {
      case 'cbt_completion':
        title = 'XP Earned! ⭐';
        message = 'You earned $xpEarned XP for completing a CBT test!';
        break;
      case 'quiz_completion':
        title = 'XP Earned! ⭐';
        message = 'You earned $xpEarned XP for completing a quiz!';
        break;
      case 'streak_bonus':
        title = 'Streak Bonus! 🔥';
        message = 'You earned $xpEarned XP as a streak bonus!';
        break;
      default:
        title = 'XP Earned! ⭐';
        message = 'You earned $xpEarned XP!';
    }

    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'xp',
      data: {'xpEarned': xpEarned, 'reason': reason},
    );
  }

  /// Creates leaderboard position change notification
  static Future<void> createLeaderboardNotification({
    required String userId,
    required int oldPosition,
    required int newPosition,
    required String changeType, // 'improved' or 'dropped'
  }) async {
    String title, message;

    if (changeType == 'improved') {
      title = 'Leaderboard Climb! 🏆';
      message =
          'Congratulations! You moved from #$oldPosition to #$newPosition on the leaderboard!';
    } else {
      title = 'Leaderboard Update 📊';
      message =
          'Your leaderboard position changed from #$oldPosition to #$newPosition. Keep studying to climb back up!';
    }

    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'leaderboard',
      data: {
        'oldPosition': oldPosition,
        'newPosition': newPosition,
        'changeType': changeType,
      },
    );
  }

  /// Gets all notifications for a user
  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Marks a notification as read
  static Future<void> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      // Ignore notification update errors
    }
  }

  /// Gets unread notification count
  static Stream<int> getUnreadNotificationCount(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Deletes a notification
  static Future<void> deleteNotification(
    String userId,
    String notificationId,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      // Ignore notification deletion errors
    }
  }

  /// Clears all notifications for a user
  static Future<void> clearAllNotifications(String userId) async {
    try {
      final notifications = await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();

      final batch = _db.batch();
      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Ignore notification clearing errors
    }
  }
}
