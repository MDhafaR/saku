import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'features/onboarding/presentation/pages/onboarding_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  await ThemeService.init();
  runApp(const SakuApp());
}

class SakuApp extends StatelessWidget {
  const SakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saku',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeService.currentThemeMode,
      locale: const Locale('id'),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const OnboardingWrapper(),
    );
  }
}
