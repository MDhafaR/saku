import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/transaction_table.dart';
import '../database/tables/wallet_table.dart';
import '../database/tables/category_table.dart';

part 'transaction_dao.g.dart';

/// Data Access Object for transaction operations
@DriftAccessor(tables: [Transactions, Wallets, Categories])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  /// Get all transactions ordered by date (newest first)
  Future<List<Transaction>> getAllTransactions() => (select(
    transactions,
  )..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])).get();

  /// Get transactions for a specific wallet
  Future<List<Transaction>> getTransactionsByWallet(int walletId) =>
      (select(transactions)
            ..where((tbl) => tbl.walletId.equals(walletId))
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .get();

  /// Get transactions by type (income/expense)
  Future<List<Transaction>> getTransactionsByType(String type) =>
      (select(transactions)
            ..where((tbl) => tbl.type.equals(type))
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .get();

  /// Get transactions within a date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) =>
      (select(transactions)
            ..where(
              (tbl) =>
                  tbl.transactionDate.isBiggerOrEqualValue(start) &
                  tbl.transactionDate.isSmallerOrEqualValue(end),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .get();

  /// Get transactions for a specific category
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) =>
      (select(transactions)
            ..where((tbl) => tbl.categoryId.equals(categoryId))
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .get();

  /// Watch all transactions for real-time updates
  Stream<List<Transaction>> watchAllTransactions() => (select(
    transactions,
  )..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])).watch();

  /// Watch transactions by wallet
  Stream<List<Transaction>> watchTransactionsByWallet(int walletId) =>
      (select(transactions)
            ..where((tbl) => tbl.walletId.equals(walletId))
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .watch();

  /// Create a new transaction and update wallet balance
  Future<int> createTransaction(TransactionsCompanion entry) async {
    final transactionId = await into(transactions).insert(entry);

    // Update wallet balance
    final wallet = await (select(
      wallets,
    )..where((tbl) => tbl.id.equals(entry.walletId.value))).getSingle();

    final change = entry.type.value == 'income'
        ? entry.amount.value
        : -entry.amount.value;
    final newBalance = wallet.currentBalance + change;

    await (update(wallets)..where((tbl) => tbl.id.equals(wallet.id))).write(
      WalletsCompanion(
        currentBalance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return transactionId;
  }

  /// Update existing transaction
  Future<bool> updateTransaction(Transaction entry) async {
    // Get old transaction to calculate balance difference
    final oldTransaction = await (select(
      transactions,
    )..where((tbl) => tbl.id.equals(entry.id))).getSingle();

    // Calculate balance change
    final oldChange = oldTransaction.type == 'income'
        ? oldTransaction.amount
        : -oldTransaction.amount;
    final newChange = entry.type == 'income' ? entry.amount : -entry.amount;
    final balanceDiff = newChange - oldChange;

    // Update transaction
    final success = await update(transactions).replace(entry);

    // Update wallet balance
    if (success && balanceDiff != 0) {
      final wallet = await (select(
        wallets,
      )..where((tbl) => tbl.id.equals(entry.walletId))).getSingle();

      await (update(wallets)..where((tbl) => tbl.id.equals(wallet.id))).write(
        WalletsCompanion(
          currentBalance: Value(wallet.currentBalance + balanceDiff),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    return success;
  }

  /// Delete transaction and revert wallet balance
  Future<int> deleteTransaction(int id) async {
    final transaction = await (select(
      transactions,
    )..where((tbl) => tbl.id.equals(id))).getSingle();

    // Revert wallet balance
    final change = transaction.type == 'income'
        ? -transaction.amount
        : transaction.amount;
    final wallet = await (select(
      wallets,
    )..where((tbl) => tbl.id.equals(transaction.walletId))).getSingle();

    await (update(wallets)..where((tbl) => tbl.id.equals(wallet.id))).write(
      WalletsCompanion(
        currentBalance: Value(wallet.currentBalance + change),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Get total income for a date range
  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    final incomes =
        await (select(transactions)..where(
              (tbl) =>
                  tbl.type.equals('income') &
                  tbl.transactionDate.isBiggerOrEqualValue(start) &
                  tbl.transactionDate.isSmallerOrEqualValue(end),
            ))
            .get();
    return incomes.fold<double>(0.0, (double sum, t) => sum + t.amount);
  }

  /// Get total expense for a date range
  Future<double> getTotalExpense(DateTime start, DateTime end) async {
    final expenses =
        await (select(transactions)..where(
              (tbl) =>
                  tbl.type.equals('expense') &
                  tbl.transactionDate.isBiggerOrEqualValue(start) &
                  tbl.transactionDate.isSmallerOrEqualValue(end),
            ))
            .get();
    return expenses.fold<double>(0.0, (double sum, t) => sum + t.amount);
  }
}
