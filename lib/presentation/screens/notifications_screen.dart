import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';

import '../../data/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF2A2D3E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearAllDialog(context),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: NotificationService.getUserNotifications(_user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading notifications',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  );
                }

                final notifications = snapshot.data?.docs ?? [];

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ll see notifications here when you earn XP, start streaks, or climb the leaderboard!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        notifications[index].data() as Map<String, dynamic>;
                    final notificationId = notifications[index].id;
                    final isRead = notification['isRead'] ?? false;
                    final title = notification['title'] ?? '';
                    final message = notification['message'] ?? '';
                    final type = notification['type'] ?? '';
                    final createdAt = notification['createdAt'] as Timestamp?;
                    final data = notification['data'] as Map<String, dynamic>?;

                    return _buildNotificationCard(
                      context,
                      notificationId,
                      title,
                      message,
                      type,
                      isRead,
                      createdAt,
                      data,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    String notificationId,
    String title,
    String message,
    String type,
    bool isRead,
    Timestamp? createdAt,
    Map<String, dynamic>? data,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _getNotificationIcon(type, data),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(createdAt),
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          onSelected: (value) =>
              _handleNotificationAction(value, notificationId),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_read',
              child: Row(
                children: [
                  Icon(
                    isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                    size: 16,
                    color: AppColors.dominantPurple,
                  ),
                  const SizedBox(width: 8),
                  Text(isRead ? 'Mark as unread' : 'Mark as read'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _markNotificationAsRead(notificationId),
      ),
    );
  }

  Widget _getNotificationIcon(String type, Map<String, dynamic>? data) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'welcome':
        iconData = Icons.celebration;
        iconColor = Colors.orange;
        break;
      case 'streak':
        iconData = Icons.local_fire_department;
        iconColor = Colors.red;
        break;
      case 'xp':
        iconData = Icons.star;
        iconColor = Colors.amber;
        break;
      case 'leaderboard':
        iconData = Icons.emoji_events;
        iconColor = Colors.yellow.shade700;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.dominantPurple;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';

    final now = DateTime.now();
    final notificationTime = timestamp.toDate();
    final difference = now.difference(notificationTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationAction(String action, String notificationId) {
    switch (action) {
      case 'mark_read':
        _markNotificationAsRead(notificationId);
        break;
      case 'delete':
        _deleteNotification(notificationId);
        break;
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    if (_user != null) {
      await NotificationService.markNotificationAsRead(
        _user!.uid,
        notificationId,
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    if (_user != null) {
      await NotificationService.deleteNotification(_user!.uid, notificationId);
    }
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text(
            'Are you sure you want to clear all notifications? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllNotifications();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllNotifications() async {
    if (_user != null) {
      await NotificationService.clearAllNotifications(_user!.uid);
    }
  }
}
