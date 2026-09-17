import 'package:get_it/get_it.dart';
import 'package:saku/features/dashboard/presentation/cubit/transaction_cubit.dart';
import 'package:saku/features/debts/presentation/cubit/debt_cubit.dart';
import 'package:saku/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:saku/features/settings/presentation/cubit/security_cubit.dart';
import 'package:saku/features/settings/presentation/cubit/backup_cubit.dart';
import 'package:saku/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:saku/features/settings/presentation/cubit/language_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/database/app_database.dart';
import 'services/google_drive_service.dart';
import 'services/backup_service.dart';
import 'services/smart_transaction_parser.dart';
import 'services/sharing_intent_service.dart';

final GetIt locator = GetIt.instance;

/// Configure dependency injection. Call this at application startup.
Future<void> setupLocator() async {
  // Database - using new AppDatabase with full schema
  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  // Services
  locator.registerLazySingleton<GoogleDriveService>(() => GoogleDriveService());
  locator.registerLazySingleton<BackupService>(
    () => BackupService(
      locator<GoogleDriveService>(),
      locator<AppDatabase>(),
      locator<SharedPreferences>(),
    ),
  );

  // Cubit - injected with database or prefs
  locator.registerFactory<TransactionCubit>(
    () => TransactionCubit(locator<AppDatabase>()),
  );

  locator.registerFactory<DebtCubit>(() => DebtCubit(locator<AppDatabase>()));
  locator.registerFactory<StatisticsCubit>(
    () => StatisticsCubit(locator<AppDatabase>()),
  );

  locator.registerLazySingleton<SecurityCubit>(
    () => SecurityCubit(locator<SharedPreferences>()),
  );

  locator.registerLazySingleton<BackupCubit>(
    () => BackupCubit(locator<BackupService>(), locator<GoogleDriveService>()),
  );

  locator.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  locator.registerLazySingleton<LanguageCubit>(() => LanguageCubit());

  // Mind Space & External Sharing Intent Services
  locator.registerLazySingleton<SmartTransactionParser>(() => SmartTransactionParser());
  locator.registerLazySingleton<SharingIntentService>(
    () => SharingIntentService(locator<SmartTransactionParser>()),
  );
}
