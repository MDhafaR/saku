import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/local/database/app_database.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final AppDatabase _db;
  StreamSubscription<List<Transaction>>? _subscription;

  TransactionCubit(this._db) : super(const TransactionInitial());

  /// Start listening to transactions from database
  void start() {
    emit(const TransactionLoading());
    _subscription?.cancel();
    _subscription = _db.transactionDao.watchAllTransactions().listen(
      (transactions) {
        emit(TransactionLoaded(transactions));
      },
      onError: (error) {
        emit(TransactionError(error.toString()));
      },
    );
  }

  /// Create a new transaction
  Future<int> addTransaction({
    required int walletId,
    required int categoryId,
    required double amount,
    required String type,
    required DateTime transactionDate,
    String description = '',
    String? note,
  }) async {
    final entry = TransactionsCompanion.insert(
      walletId: walletId,
      categoryId: categoryId,
      amount: amount,
      type: type,
      transactionDate: transactionDate,
      description: Value(description),
      note: Value(note),
    );
    return _db.transactionDao.createTransaction(entry);
  }

  /// Update an existing transaction
  Future<bool> updateTransaction(Transaction transaction) async {
    return _db.transactionDao.updateTransaction(transaction);
  }

  /// Delete a transaction
  Future<int> deleteTransaction(int id) async {
    return _db.transactionDao.deleteTransaction(id);
  }

  /// Get all categories by type
  Future<List<Category>> getCategories(String type) {
    return _db.categoryDao.getCategoriesByType(type);
  }

  /// Get all wallets
  Future<List<Wallet>> getWallets() {
    return _db.walletDao.getAllWallets();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
