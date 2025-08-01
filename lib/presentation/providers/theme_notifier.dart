import 'package:flutter/material.dart';
import '../../data/services/user_preferences_service.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // Initialize theme from preferences
  Future<void> initializeTheme() async {
    final isDark = await UserPreferencesService.getThemeMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    // Save theme preference
    await UserPreferencesService.saveThemeMode(isDark);
    notifyListeners();
  }

  // Method to set theme without saving (for initialization)
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
