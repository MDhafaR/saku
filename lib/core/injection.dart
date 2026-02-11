import 'package:get_it/get_it.dart';
import 'package:saku/features/dashboard/presentation/cubit/transaction_cubit.dart';
import 'package:saku/features/debts/presentation/cubit/debt_cubit.dart';
import '../data/local/database/app_database.dart';

final GetIt locator = GetIt.instance;

/// Configure dependency injection. Call this at application startup.
Future<void> setupLocator() async {
  // Database - using new AppDatabase with full schema
  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Cubit - injected with database
  locator.registerFactory<TransactionCubit>(
    () => TransactionCubit(locator<AppDatabase>()),
  );

  locator.registerFactory<DebtCubit>(() => DebtCubit(locator<AppDatabase>()));
}
