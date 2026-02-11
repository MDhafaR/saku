import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/transfer_table.dart';
import '../database/tables/wallet_table.dart';

part 'transfer_dao.g.dart';

/// Data Access Object for transfer operations between wallets
@DriftAccessor(tables: [Transfers, Wallets])
class TransferDao extends DatabaseAccessor<AppDatabase>
    with _$TransferDaoMixin {
  TransferDao(super.db);

  /// Get all transfers ordered by date (newest first)
  Future<List<Transfer>> getAllTransfers() => (select(
    transfers,
  )..orderBy([(t) => OrderingTerm.desc(t.transferDate)])).get();

  /// Get transfers from a specific wallet
  Future<List<Transfer>> getTransfersFromWallet(int walletId) =>
      (select(transfers)
            ..where((tbl) => tbl.fromWalletId.equals(walletId))
            ..orderBy([(t) => OrderingTerm.desc(t.transferDate)]))
          .get();

  /// Get transfers to a specific wallet
  Future<List<Transfer>> getTransfersToWallet(int walletId) =>
      (select(transfers)
            ..where((tbl) => tbl.toWalletId.equals(walletId))
            ..orderBy([(t) => OrderingTerm.desc(t.transferDate)]))
          .get();

  /// Get all transfers involving a wallet (from or to)
  Future<List<Transfer>> getTransfersByWallet(int walletId) =>
      (select(transfers)
            ..where(
              (tbl) =>
                  tbl.fromWalletId.equals(walletId) |
                  tbl.toWalletId.equals(walletId),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.transferDate)]))
          .get();

  /// Get transfers within a date range
  Future<List<Transfer>> getTransfersByDateRange(
    DateTime start,
    DateTime end,
  ) =>
      (select(transfers)
            ..where(
              (tbl) =>
                  tbl.transferDate.isBiggerOrEqualValue(start) &
                  tbl.transferDate.isSmallerOrEqualValue(end),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.transferDate)]))
          .get();

  /// Watch all transfers for real-time updates
  Stream<List<Transfer>> watchAllTransfers() => (select(
    transfers,
  )..orderBy([(t) => OrderingTerm.desc(t.transferDate)])).watch();

  /// Create a new transfer and update both wallet balances
  Future<int> createTransfer(TransfersCompanion entry) async {
    final transferId = await into(transfers).insert(entry);

    // Get both wallets
    final fromWallet = await (select(
      wallets,
    )..where((tbl) => tbl.id.equals(entry.fromWalletId.value))).getSingle();
    final toWallet = await (select(
      wallets,
    )..where((tbl) => tbl.id.equals(entry.toWalletId.value))).getSingle();

    // Calculate new balances
    final totalDeduction = entry.amount.value + (entry.fee.value ?? 0);
    final newFromBalance = fromWallet.currentBalance - totalDeduction;
    final newToBalance = toWallet.currentBalance + entry.amount.value;

    // Update source wallet
    await (update(wallets)..where((tbl) => tbl.id.equals(fromWallet.id))).write(
      WalletsCompanion(
        currentBalance: Value(newFromBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Update destination wallet
    await (update(wallets)..where((tbl) => tbl.id.equals(toWallet.id))).write(
      WalletsCompanion(
        currentBalance: Value(newToBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return transferId;
  }

  /// Delete transfer and revert wallet balances
  Future<int> deleteTransfer(int id) async {
    final transfer = await (select(
      transfers,
    )..where((tbl) => tbl.id.equals(id))).getSingle();

    // Get both wallets
    final fromWallet = await (select(
      wallets,
    )..where((tbl) => tbl.id.equals(transfer.fromWalletId))).getSingle();
    final toWallet = await (select(
      wallets,
    )..where((tbl) => tbl.id.equals(transfer.toWalletId))).getSingle();

    // Revert source wallet (add back amount + fee)
    final totalDeduction = transfer.amount + transfer.fee;
    await (update(wallets)..where((tbl) => tbl.id.equals(fromWallet.id))).write(
      WalletsCompanion(
        currentBalance: Value(fromWallet.currentBalance + totalDeduction),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Revert destination wallet (remove amount)
    await (update(wallets)..where((tbl) => tbl.id.equals(toWallet.id))).write(
      WalletsCompanion(
        currentBalance: Value(toWallet.currentBalance - transfer.amount),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return (delete(transfers)..where((tbl) => tbl.id.equals(id))).go();
  }
}
