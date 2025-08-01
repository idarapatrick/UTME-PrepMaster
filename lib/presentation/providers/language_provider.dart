import 'package:flutter/material.dart';
import '../../data/services/user_preferences_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'fr': 'Français',
  };

  // Initialize language from preferences
  Future<void> initializeLanguage() async {
    _currentLanguage = await UserPreferencesService.getLanguage();
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (supportedLanguages.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      await UserPreferencesService.saveLanguage(languageCode);
      notifyListeners();
    }
  }

  // Get current language name
  String get currentLanguageName {
    return supportedLanguages[_currentLanguage] ?? 'English';
  }

  // Get all supported languages
  Map<String, String> get allLanguages => supportedLanguages;
} 