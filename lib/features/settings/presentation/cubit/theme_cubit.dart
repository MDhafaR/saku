import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeService.currentThemeMode);

  Future<void> toggleTheme() async {
    await ThemeService.toggleTheme();
    emit(ThemeService.currentThemeMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ThemeService.setThemeMode(mode);
    emit(mode);
  }

  bool get isDark => state == ThemeMode.dark;
}
