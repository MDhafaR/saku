import 'package:get_it/get_it.dart';
import 'package:saku/features/dashboard/presentation/cubit/transaction_cubit.dart';
import '../data/local/saku_database.dart';
import '../data/remote/api_client.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/usecases/get_transactions.dart';
import '../domain/usecases/upsert_transaction.dart';

final GetIt locator = GetIt.instance;

/// Configure dependency injection.  Call this at application startup.
Future<void> setupLocator() async {
  // Database
  locator.registerLazySingleton<SakuDatabase>(() => SakuDatabase());
  // API client
  locator.registerLazySingleton<ApiClient>(() => ApiClient());
  // Cubit
  locator.registerFactory<TransactionCubit>(() => TransactionCubit());
  // Repository
  locator.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      locator<SakuDatabase>(),
      locator<ApiClient>(),
    ),
  );
  // Use cases
  locator.registerLazySingleton<GetTransactions>(
    () => GetTransactions(locator<TransactionRepository>()),
  );
  locator.registerLazySingleton<UpsertTransaction>(
    () => UpsertTransaction(locator<TransactionRepository>()),
  );
}
