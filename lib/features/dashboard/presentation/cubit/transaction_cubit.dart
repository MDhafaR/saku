import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/saku_home_widget_service.dart';
import '../../../../data/local/database/app_database.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final AppDatabase _db;
  StreamSubscription<List<Transaction>>? _transactionSubscription;
  StreamSubscription<List<Transfer>>? _transferSubscription;
  List<Transaction> _latestTransactions = const [];
  List<Transfer> _latestTransfers = const [];

  TransactionCubit(this._db) : super(const TransactionInitial());

  /// Start listening to both transactions and transfers from database
  void start() {
    _transactionSubscription?.cancel();
    _transferSubscription?.cancel();

    _transactionSubscription = _db.transactionDao.watchAllTransactions().listen(
      (transactions) {
        _latestTransactions = transactions;
        emit(TransactionLoaded(_latestTransactions, _latestTransfers));
        SakuHomeWidgetService.updateAllWidgets(_db);
      },
      onError: (error) {
        emit(TransactionError(error.toString()));
      },
    );

    _transferSubscription = _db.transferDao.watchAllTransfers().listen(
      (transfers) {
        _latestTransfers = transfers;
        emit(TransactionLoaded(_latestTransactions, _latestTransfers));
        SakuHomeWidgetService.updateAllWidgets(_db);
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

  /// Delete a transfer and revert wallet balances
  Future<int> deleteTransfer(int id) async {
    return _db.transferDao.deleteTransfer(id);
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
    _transactionSubscription?.cancel();
    _transferSubscription?.cancel();
    return super.close();
  }
}
