import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saku/core/injection.dart';
import 'package:saku/data/local/database/app_database.dart';
import 'package:saku/features/dashboard/presentation/cubit/transaction_cubit.dart';
import 'package:saku/features/dashboard/presentation/cubit/transaction_state.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:drift/native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  blocTest<TransactionCubit, TransactionState>(
    'emits [TransactionLoaded] when start is called',
    build: () => TransactionCubit(database),
    act: (cubit) => cubit.start(),
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<TransactionLoaded>()],
  );
}
