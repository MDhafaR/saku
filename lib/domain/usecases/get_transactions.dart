import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case to subscribe to all transactions.
class GetTransactions {
  final TransactionRepository repository;
  const GetTransactions(this.repository);

  Stream<List<Transaction>> call() {
    return repository.watchAll();
  }
}