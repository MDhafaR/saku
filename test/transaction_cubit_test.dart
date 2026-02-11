import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saku/core/injection.dart';
import 'package:saku/data/local/database/app_database.dart';
import 'package:saku/features/dashboard/presentation/cubit/transaction_cubit.dart';
import 'package:saku/features/dashboard/presentation/cubit/transaction_state.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    await setupLocator();
    database = locator<AppDatabase>();
  });

  blocTest<TransactionCubit, TransactionState>(
    'emits [TransactionLoading, TransactionLoaded] when start is called',
    build: () => TransactionCubit(database),
    act: (cubit) => cubit.start(),
    expect: () => [isA<TransactionLoading>(), isA<TransactionLoaded>()],
  );
}
