import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static ThemeMode _currentThemeMode = ThemeMode.light;

  static ThemeMode get currentThemeMode => _currentThemeMode;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Default to explicit light (var 1) instead of system (0)
    int themeIndex = prefs.getInt(_themeKey) ?? 1; 
    if (themeIndex == 0) {
      themeIndex = 1; // Migrate system format to explicitly light
      await prefs.setInt(_themeKey, 1);
    }
    _currentThemeMode = ThemeMode.values[themeIndex];
  }

  static Future<void> setThemeMode(ThemeMode themeMode) async {
    _currentThemeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }

  static Future<void> toggleTheme() async {
    final newThemeMode = _currentThemeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newThemeMode);
  }

  static bool get isDarkMode => _currentThemeMode == ThemeMode.dark;
  static bool get isLightMode => _currentThemeMode == ThemeMode.light;
}
