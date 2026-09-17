import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saku/core/localization/app_localizations.dart';
import 'package:saku/core/localization/language_service.dart';
import 'package:saku/features/settings/presentation/cubit/language_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization & LanguageCubit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await LanguageService.init();
    });

    test('1. Default Language adalah Bahasa Indonesia', () {
      final cubit = LanguageCubit();
      expect(cubit.state.languageCode, 'id');
      expect(cubit.isIndonesian, true);
      expect(cubit.isEnglish, false);
    });

    test('2. Mengubah Bahasa ke English', () async {
      final cubit = LanguageCubit();
      await cubit.changeLanguage('en');
      expect(cubit.state.languageCode, 'en');
      expect(cubit.isEnglish, true);
      expect(cubit.isIndonesian, false);

      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.navHome, 'Home');
      expect(l10n.navTransactions, 'Transactions');
      expect(l10n.totalBalance, 'Total Balance');
      expect(l10n.settingsTitle, 'Settings');
      expect(l10n.settingLanguage, 'Language');
    });

    test('3. Kamus Bahasa Indonesia menghasilkan terjemahan yang tepat', () {
      final l10n = AppLocalizations(const Locale('id'));
      expect(l10n.navHome, 'Beranda');
      expect(l10n.navTransactions, 'Transaksi');
      expect(l10n.totalBalance, 'Total Saldo');
      expect(l10n.settingsTitle, 'Pengaturan');
      expect(l10n.settingLanguage, 'Bahasa');
      expect(l10n.adjustBalanceTitle, 'Ngepasin Saldo');
    });

    test('4. Toggle Bahasa bergantian antara ID dan EN', () async {
      final cubit = LanguageCubit();
      expect(cubit.state.languageCode, 'id');

      await cubit.toggleLanguage();
      expect(cubit.state.languageCode, 'en');

      await cubit.toggleLanguage();
      expect(cubit.state.languageCode, 'id');
    });
  });
}
