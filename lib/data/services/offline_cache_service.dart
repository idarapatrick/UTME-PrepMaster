import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../../domain/models/user_profile_model.dart';
import '../../domain/models/progress_tracking_model.dart';
import '../../domain/models/leaderboard_data_model.dart';

class OfflineCacheService {
  static const String _userProfileKey = 'cached_user_profile';
  static const String _progressTrackingKey = 'cached_progress_tracking';
  static const String _leaderboardKey = 'cached_leaderboard';
  static const String _subjectsKey = 'cached_subjects';
  static const String _achievementsKey = 'cached_achievements';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  static SharedPreferences? _prefs;
  
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // USER PROFILE CACHING

  static Future<void> cacheUserProfile(UserProfile profile) async {
    try {
      await initialize();
      final jsonString = jsonEncode(profile.toMap());
      await _prefs!.setString(_userProfileKey, jsonString);
      await _updateLastSync();
    } catch (e) {
      developer.log('Error caching user profile: $e');
    }
  }

  static Future<UserProfile?> getCachedUserProfile() async {
    try {
      await initialize();
      final jsonString = _prefs!.getString(_userProfileKey);
      if (jsonString == null) return null;
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      // We need the user ID for the profile, get it from current user or cache
      final userId = _prefs!.getString('cached_user_id') ?? '';
      return UserProfile.fromMap(data, userId);
    } catch (e) {
      developer.log('Error getting cached user profile: $e');
      return null;
    }
  }

  // PROGRESS TRACKING CACHING

  static Future<void> cacheProgressTracking(ProgressTrackingModel progress) async {
    try {
      await initialize();
      final jsonString = jsonEncode(progress.toMap());
      await _prefs!.setString(_progressTrackingKey, jsonString);
      await _updateLastSync();
    } catch (e) {
      developer.log('Error caching progress tracking: $e');
    }
  }

  static Future<ProgressTrackingModel?> getCachedProgressTracking(String userId) async {
    try {
      await initialize();
      final jsonString = _prefs!.getString(_progressTrackingKey);
      if (jsonString == null) return null;
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return ProgressTrackingModel.fromMap(data, userId);
    } catch (e) {
      developer.log('Error getting cached progress tracking: $e');
      return null;
    }
  }

  // LEADERBOARD CACHING

  static Future<void> cacheLeaderboard(LeaderboardDataModel leaderboard) async {
    try {
      await initialize();
      final data = {
        'xpLeaderboard': leaderboard.xpLeaderboard.map((e) => e.toMap()).toList(),
        'cbtLeaderboard': leaderboard.cbtLeaderboard.map((e) => e.toMap()).toList(),
        'lastFetched': leaderboard.lastFetched.millisecondsSinceEpoch,
      };
      final jsonString = jsonEncode(data);
      await _prefs!.setString(_leaderboardKey, jsonString);
    } catch (e) {
      developer.log('Error caching leaderboard: $e');
    }
  }

  static Future<LeaderboardDataModel?> getCachedLeaderboard() async {
    try {
      await initialize();
      final jsonString = _prefs!.getString(_leaderboardKey);
      if (jsonString == null) return null;
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final xpLeaderboard = (data['xpLeaderboard'] as List)
          .asMap()
          .entries
          .map((entry) => LeaderboardEntry.fromMap(
              entry.value as Map<String, dynamic>, 
              entry.key + 1
          ))
          .toList();
      
      final cbtLeaderboard = (data['cbtLeaderboard'] as List)
          .asMap()
          .entries
          .map((entry) => LeaderboardEntry.fromMap(
              entry.value as Map<String, dynamic>, 
              entry.key + 1
          ))
          .toList();
      
      final lastFetched = DateTime.fromMillisecondsSinceEpoch(data['lastFetched']);
      
      return LeaderboardDataModel(
        xpLeaderboard: xpLeaderboard,
        cbtLeaderboard: cbtLeaderboard,
        lastFetched: lastFetched,
      );
    } catch (e) {
      developer.log('Error getting cached leaderboard: $e');
      return null;
    }
  }

  // SUBJECTS CACHING

  static Future<void> cacheUserSubjects(List<String> subjects) async {
    try {
      await initialize();
      await _prefs!.setStringList(_subjectsKey, subjects);
    } catch (e) {
      developer.log('Error caching user subjects: $e');
    }
  }

  static Future<List<String>> getCachedUserSubjects() async {
    try {
      await initialize();
      return _prefs!.getStringList(_subjectsKey) ?? [];
    } catch (e) {
      developer.log('Error getting cached user subjects: $e');
      return [];
    }
  }

  // ACHIEVEMENTS CACHING

  static Future<void> cacheUserAchievements(List<String> achievements) async {
    try {
      await initialize();
      await _prefs!.setStringList(_achievementsKey, achievements);
    } catch (e) {
      developer.log('Error caching user achievements: $e');
    }
  }

  static Future<List<String>> getCachedUserAchievements() async {
    try {
      await initialize();
      return _prefs!.getStringList(_achievementsKey) ?? [];
    } catch (e) {
      developer.log('Error getting cached user achievements: $e');
      return [];
    }
  }

  // CACHE MANAGEMENT

  static Future<void> clearUserCache() async {
    try {
      await initialize();
      await _prefs!.remove(_userProfileKey);
      await _prefs!.remove(_progressTrackingKey);
      await _prefs!.remove(_leaderboardKey);
      await _prefs!.remove(_subjectsKey);
      await _prefs!.remove(_achievementsKey);
      await _prefs!.remove(_lastSyncKey);
      await _prefs!.remove('cached_user_id');
    } catch (e) {
      developer.log('Error clearing user cache: $e');
    }
  }

  static Future<void> clearExpiredCache() async {
    try {
      await initialize();
      final lastSync = await getLastSyncTime();
      final now = DateTime.now();
      
      // Clear cache if it's older than 24 hours
      if (now.difference(lastSync).inHours > 24) {
        await clearUserCache();
      }
    } catch (e) {
      developer.log('Error clearing expired cache: $e');
    }
  }

  static Future<DateTime> getLastSyncTime() async {
    try {
      await initialize();
      final timestamp = _prefs!.getInt(_lastSyncKey);
      if (timestamp == null) return DateTime(2000); // Very old date
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      developer.log('Error getting last sync time: $e');
      return DateTime(2000);
    }
  }

  static Future<void> _updateLastSync() async {
    try {
      await _prefs!.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      developer.log('Error updating last sync time: $e');
    }
  }

  // OFFLINE QUEUE MANAGEMENT
  
  static const String _offlineQueueKey = 'offline_queue';
  
  static Future<void> addToOfflineQueue(Map<String, dynamic> operation) async {
    try {
      await initialize();
      final queue = await getOfflineQueue();
      queue.add({
        ...operation,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      final jsonString = jsonEncode(queue);
      await _prefs!.setString(_offlineQueueKey, jsonString);
    } catch (e) {
      developer.log('Error adding to offline queue: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    try {
      await initialize();
      final jsonString = _prefs!.getString(_offlineQueueKey);
      if (jsonString == null) return [];
      
      final List<dynamic> queueData = jsonDecode(jsonString);
      return queueData.cast<Map<String, dynamic>>();
    } catch (e) {
      developer.log('Error getting offline queue: $e');
      return [];
    }
  }

  static Future<void> clearOfflineQueue() async {
    try {
      await initialize();
      await _prefs!.remove(_offlineQueueKey);
    } catch (e) {
      developer.log('Error clearing offline queue: $e');
    }
  }

  static Future<void> removeFromOfflineQueue(int index) async {
    try {
      await initialize();
      final queue = await getOfflineQueue();
      if (index >= 0 && index < queue.length) {
        queue.removeAt(index);
        final jsonString = jsonEncode(queue);
        await _prefs!.setString(_offlineQueueKey, jsonString);
      }
    } catch (e) {
      developer.log('Error removing from offline queue: $e');
    }
  }

  // CACHE HEALTH CHECK

  static Future<bool> isCacheHealthy() async {
    try {
      await initialize();
      final lastSync = await getLastSyncTime();
      final now = DateTime.now();
      
      // Cache is healthy if it's less than 12 hours old
      return now.difference(lastSync).inHours < 12;
    } catch (e) {
      developer.log('Error checking cache health: $e');
      return false;
    }
  }

  static Future<Map<String, bool>> getCacheStatus() async {
    await initialize();
    return {
      'hasUserProfile': _prefs!.containsKey(_userProfileKey),
      'hasProgressTracking': _prefs!.containsKey(_progressTrackingKey),
      'hasLeaderboard': _prefs!.containsKey(_leaderboardKey),
      'hasSubjects': _prefs!.containsKey(_subjectsKey),
      'hasAchievements': _prefs!.containsKey(_achievementsKey),
      'isHealthy': await isCacheHealthy(),
    };
  }

  // USER ID MANAGEMENT
  
  static Future<void> cacheUserId(String userId) async {
    try {
      await initialize();
      await _prefs!.setString('cached_user_id', userId);
    } catch (e) {
      developer.log('Error caching user ID: $e');
    }
  }

  static Future<String?> getCachedUserId() async {
    try {
      await initialize();
      return _prefs!.getString('cached_user_id');
    } catch (e) {
      developer.log('Error getting cached user ID: $e');
      return null;
    }
  }
}
