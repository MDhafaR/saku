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
}
