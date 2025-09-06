import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case to insert or update a transaction.
class UpsertTransaction {
  final TransactionRepository repository;
  const UpsertTransaction(this.repository);

  Future<void> call(Transaction transaction) {
    return repository.upsert(transaction);
  }
}