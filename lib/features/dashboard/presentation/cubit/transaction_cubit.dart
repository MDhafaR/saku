import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/usecases/get_transactions.dart';
import '../../../../domain/usecases/upsert_transaction.dart';
import '../../../../core/injection.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final GetTransactions _getTransactions;
  final UpsertTransaction _upsertTransaction;
  StreamSubscription<List<Transaction>>? _subscription;

  TransactionCubit()
      : _getTransactions = locator<GetTransactions>(),
        _upsertTransaction = locator<UpsertTransaction>(),
        super(const TransactionInitial());

  void start() {
    emit(const TransactionLoading());
    _subscription?.cancel();
    _subscription = _getTransactions().listen(
      (transactions) {
        emit(TransactionLoaded(transactions));
      },
      onError: (error) {
        emit(TransactionError(error.toString()));
      },
    );
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _upsertTransaction(transaction);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}