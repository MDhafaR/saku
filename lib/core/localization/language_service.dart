import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layanan persistensi dan cache untuk preferensi bahasa aplikasi Saku.
class LanguageService {
  static const String _languageKey = 'app_language';
  static String _currentLanguageCode = 'id'; // Default Bahasa Indonesia

  static String get currentLanguageCode => _currentLanguageCode;
  static Locale get currentLocale => Locale(_currentLanguageCode);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguageCode = prefs.getString(_languageKey) ?? 'id';
  }

  static Future<void> setLanguage(String languageCode) async {
    if (_currentLanguageCode == languageCode) return;
    _currentLanguageCode = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static bool get isIndonesian => _currentLanguageCode == 'id';
  static bool get isEnglish => _currentLanguageCode == 'en';
}
