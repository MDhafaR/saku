import 'dart:async';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../local/saku_database.dart';
import '../remote/api_client.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final SakuDatabase _db;
  final ApiClient _api;

  TransactionRepositoryImpl(this._db, this._api);

  @override
  Stream<List<Transaction>> watchAll() {
    return _db.watchAllTransactions();
  }

  @override
  Future<void> upsert(Transaction transaction) async {
    // Save locally; mark as unsynced
    await _db.upsertTransaction(transaction, synced: false);
    // Try to send to server (fire and forget).  If it fails, the user can
    // trigger sync manually or automatically later.
    final payload = {
      'id': transaction.id,
      'description': transaction.description,
      'amount': transaction.amount,
      'category': transaction.category,
      'type': transaction.type,
      'timestamp': transaction.timestamp.millisecondsSinceEpoch,
    };
    try {
      await _api.sendTransaction(payload);
      // If successful, update local record to synced
      await _db.upsertTransaction(transaction, synced: true);
    } catch (_) {
      // ignore errors; the transaction will remain unsynced
    }
  }
}