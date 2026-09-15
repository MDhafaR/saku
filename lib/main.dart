import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/sharing_intent_service.dart';
import 'core/models/voice_intent_model.dart';
import 'features/onboarding/presentation/pages/onboarding_wrapper.dart';
import 'features/transactions/presentation/pages/smart_import_review_page.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/settings/presentation/cubit/security_cubit.dart';
import 'features/settings/presentation/cubit/security_state.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';
import 'features/settings/presentation/pages/pin_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  await ThemeService.init();
  await initializeDateFormatting('id_ID', null);
  await NotificationService().init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => locator<SecurityCubit>()),
        BlocProvider(create: (context) => locator<ThemeCubit>()),
      ],
      child: const AppLifecycleObserver(child: SakuApp()),
    ),
  );
}

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  const AppLifecycleObserver({super.key, required this.child});

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  StreamSubscription? _shareSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initShareListener();
  }

  void _initShareListener() {
    final shareService = locator<SharingIntentService>();
    shareService.initSharingListener();
    _shareSub = shareService.onIntentsReceived.listen((intents) {
      if (intents.isNotEmpty) {
        _navigateToReviewPage(intents);
      }
    });
  }

  void _navigateToReviewPage(List<VoiceIntentModel> intents) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => SmartImportReviewPage(
            initialIntents: intents,
            sourceName: 'Mind Space',
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    locator<SharingIntentService>().dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<SecurityCubit>().lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class SakuApp extends StatelessWidget {
  const SakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) => BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'Saku',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: const Locale('id'),
          supportedLocales: const [Locale('id'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return BlocBuilder<SecurityCubit, SecurityState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    child!,
                    if (state.isLocked) const PinPage(mode: PinMode.verify),
                  ],
                );
              },
            );
          },
          home: const OnboardingWrapper(),
        ),
      ),
    );
  }
}
