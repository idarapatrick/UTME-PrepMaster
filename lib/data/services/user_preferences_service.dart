import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserPreferencesService {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _dailyReminderTimeKey = 'daily_reminder_time';
  static const String _studySessionDurationKey = 'study_session_duration';
  static const String _soundEnabledKey = 'sound_enabled';

  // Theme Preferences
  static Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Default to light mode
  }

  // Language Preferences
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en'; // Default to English
  }

  // Notification Settings
  static Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true; // Default to enabled
  }

  // Study Preferences
  static Future<void> saveDailyReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = '${time.hour}:${time.minute}';
    await prefs.setString(_dailyReminderTimeKey, timeString);
  }

  static Future<TimeOfDay> getDailyReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_dailyReminderTimeKey) ?? '09:00';
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static Future<void> saveStudySessionDuration(int durationMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_studySessionDurationKey, durationMinutes);
  }

  static Future<int> getStudySessionDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_studySessionDurationKey) ?? 30; // Default to 30 minutes
  }

  // Sound Settings
  static Future<void> saveSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true; // Default to enabled
  }

  // Clear all preferences (useful for logout)
  static Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 