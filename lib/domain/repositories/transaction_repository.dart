import '../entities/transaction.dart';

/// Abstract repository interface for managing transactions.
///
/// Implementations combine local and remote data sources to provide
/// offline‑first behaviour.
abstract class TransactionRepository {
  /// Stream of transactions sorted by date descending.  Implementations should
  /// emit updates whenever the underlying data changes.
  Stream<List<Transaction>> watchAll();

  /// Insert or update a transaction.
  Future<void> upsert(Transaction transaction);
}