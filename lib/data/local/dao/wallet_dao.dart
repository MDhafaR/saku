import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/wallet_table.dart';

part 'wallet_dao.g.dart';

/// Data Access Object for wallet operations
@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  /// Get all non-archived wallets
  Future<List<Wallet>> getAllWallets() =>
      (select(wallets)..where((tbl) => tbl.isArchived.equals(false))).get();

  /// Get all visible (non-hidden) wallets
  Future<List<Wallet>> getVisibleWallets() =>
      (select(wallets)..where(
            (tbl) => tbl.isHidden.equals(false) & tbl.isArchived.equals(false),
          ))
          .get();

  /// Get wallet by ID
  Future<Wallet?> getWalletById(int id) =>
      (select(wallets)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Watch all wallets for real-time updates
  Stream<List<Wallet>> watchAllWallets() =>
      (select(wallets)..where((tbl) => tbl.isArchived.equals(false))).watch();

  /// Watch visible wallets for dashboard
  Stream<List<Wallet>> watchVisibleWallets() =>
      (select(wallets)..where(
            (tbl) => tbl.isHidden.equals(false) & tbl.isArchived.equals(false),
          ))
          .watch();

  /// Create a new wallet
  Future<int> createWallet(WalletsCompanion entry) =>
      into(wallets).insert(entry);

  /// Update existing wallet
  Future<bool> updateWallet(Wallet entry) => update(wallets).replace(entry);

  /// Update wallet balance
  Future<int> updateBalance(int id, double newBalance) =>
      (update(wallets)..where((tbl) => tbl.id.equals(id))).write(
        WalletsCompanion(
          currentBalance: Value(newBalance),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Soft delete (archive) a wallet
  Future<int> archiveWallet(int id) =>
      (update(wallets)..where((tbl) => tbl.id.equals(id))).write(
        WalletsCompanion(
          isArchived: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Toggle wallet visibility
  Future<int> toggleHidden(int id, bool isHidden) =>
      (update(wallets)..where((tbl) => tbl.id.equals(id))).write(
        WalletsCompanion(
          isHidden: Value(isHidden),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Get total balance across all visible wallets
  Future<double> getTotalBalance() async {
    final visible = await getVisibleWallets();
    return visible.fold<double>(
      0.0,
      (sum, wallet) => sum + wallet.currentBalance,
    );
  }

  /// Delete wallet permanently
  Future<int> deleteWallet(Wallet entry) => delete(wallets).delete(entry);

  /// Delete a wallet and ALL associated data (transactions, debts, debt payments).
  /// This is a destructive operation — all data is permanently lost.
  Future<void> deleteWalletWithAllData(int walletId) async {
    final txns = attachedDatabase.transactions;
    final debts = attachedDatabase.debts;
    final debtPayments = attachedDatabase.debtPayments;

    // Delete all debt payments linked to this wallet
    await (delete(
      debtPayments,
    )..where((tbl) => tbl.walletId.equals(walletId))).go();

    // Delete all debts linked to this wallet (nullable walletId)
    await (delete(debts)..where((tbl) => tbl.walletId.equals(walletId))).go();

    // Delete all transactions linked to this wallet
    await (delete(txns)..where((tbl) => tbl.walletId.equals(walletId))).go();

    // Delete the wallet itself
    await (delete(wallets)..where((tbl) => tbl.id.equals(walletId))).go();
  }

  /// Reassign all transactions from one wallet to another
  Future<int> reassignTransactions(int fromWalletId, int toWalletId) {
    final txns = attachedDatabase.transactions;
    return (update(txns)..where((tbl) => tbl.walletId.equals(fromWalletId)))
        .write(TransactionsCompanion(walletId: Value(toWalletId)));
  }

  /// Delete a wallet and reassign its transactions to another wallet.
  /// Also transfers the balance to the target wallet.
  Future<void> deleteWalletAndReassign(
    Wallet wallet, {
    required int targetWalletId,
  }) async {
    // Reassign all transactions
    await reassignTransactions(wallet.id, targetWalletId);

    // Transfer remaining balance to target wallet
    final targetWallet = await getWalletById(targetWalletId);
    if (targetWallet != null) {
      await updateBalance(
        targetWalletId,
        targetWallet.currentBalance + wallet.currentBalance,
      );
    }

    // Delete the wallet
    await deleteWallet(wallet);
  }
}
