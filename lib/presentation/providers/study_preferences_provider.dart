import 'package:flutter/material.dart';
import '../../data/services/user_preferences_service.dart';

class StudyPreferencesProvider extends ChangeNotifier {
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 9, minute: 0);
  int _studySessionDuration = 30; // minutes
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  TimeOfDay get dailyReminderTime => _dailyReminderTime;
  int get studySessionDuration => _studySessionDuration;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;

  // Initialize preferences from storage
  Future<void> initializePreferences() async {
    _dailyReminderTime = await UserPreferencesService.getDailyReminderTime();
    _studySessionDuration = await UserPreferencesService.getStudySessionDuration();
    _notificationsEnabled = await UserPreferencesService.getNotificationsEnabled();
    _soundEnabled = await UserPreferencesService.getSoundEnabled();
    notifyListeners();
  }

  // Update daily reminder time
  Future<void> updateDailyReminderTime(TimeOfDay time) async {
    _dailyReminderTime = time;
    await UserPreferencesService.saveDailyReminderTime(time);
    notifyListeners();
  }

  // Update study session duration
  Future<void> updateStudySessionDuration(int durationMinutes) async {
    _studySessionDuration = durationMinutes;
    await UserPreferencesService.saveStudySessionDuration(durationMinutes);
    notifyListeners();
  }

  // Update notifications enabled
  Future<void> updateNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await UserPreferencesService.saveNotificationsEnabled(enabled);
    notifyListeners();
  }

  // Update sound enabled
  Future<void> updateSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await UserPreferencesService.saveSoundEnabled(enabled);
    notifyListeners();
  }

  // Get formatted reminder time string
  String getFormattedReminderTime(BuildContext context) {
    return _dailyReminderTime.format(context);
  }

  // Get formatted session duration string
  String get formattedSessionDuration {
    if (_studySessionDuration < 60) {
      return '$_studySessionDuration minutes';
    } else {
      final hours = _studySessionDuration ~/ 60;
      final minutes = _studySessionDuration % 60;
      if (minutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} $minutes minutes';
      }
    }
  }
} 