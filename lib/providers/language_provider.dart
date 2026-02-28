import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _key = 'selected_language';
  Locale? _locale;

  Locale? get locale => _locale;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code != 'system') {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  Future<void> setLanguage(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null || languageCode == 'system') {
      _locale = null;
      await prefs.setString(_key, 'system');
    } else {
      _locale = Locale(languageCode);
      await prefs.setString(_key, languageCode);
    }
    notifyListeners();
  }

  String getLanguageDisplayName(String? code) {
    switch (code) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Español';
      case 'ru':
        return 'Русский';
      default:
        return '跟随系统';
    }
  }
}
