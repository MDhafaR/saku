import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/language_service.dart';

/// Cubit untuk mengelola state preferensi bahasa (Locale) aplikasi Saku.
class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(LanguageService.currentLocale);

  /// Mengubah bahasa aplikasi ke [languageCode] ('id' atau 'en') dan menyimpan preferensi secara persisten.
  Future<void> changeLanguage(String languageCode) async {
    await LanguageService.setLanguage(languageCode);
    emit(Locale(languageCode));
  }

  /// Toggle cepat antara Bahasa Indonesia dan English
  Future<void> toggleLanguage() async {
    final nextLang = state.languageCode == 'id' ? 'en' : 'id';
    await changeLanguage(nextLang);
  }

  bool get isIndonesian => state.languageCode == 'id';
  bool get isEnglish => state.languageCode == 'en';
}
