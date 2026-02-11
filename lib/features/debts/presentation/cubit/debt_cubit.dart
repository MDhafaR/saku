import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/local/database/app_database.dart';
import 'debt_state.dart';

class DebtCubit extends Cubit<DebtState> {
  final AppDatabase _db;
  StreamSubscription<List<Debt>>? _subscription;

  DebtCubit(this._db) : super(const DebtInitial());

  /// Start listening to all debts from database
  void start() {
    emit(const DebtLoading());
    _subscription?.cancel();
    _subscription = _db.debtDao.watchAllDebts().listen(
      (debts) async {
        // Load all persons for display
        final persons = await _db.debtDao.getAllPersons();
        final personMap = {for (var p in persons) p.id: p};
        emit(DebtLoaded(debts, personMap));
      },
      onError: (error) {
        emit(DebtError(error.toString()));
      },
    );
  }

  /// Create a new debt/loan
  Future<int> addDebt({
    required String contactName,
    required double totalAmount,
    required String type,
    required DateTime transactionDate,
    DateTime? dueDate,
    String description = '',
    int? walletId,
  }) async {
    // Find or create person
    final persons = await _db.debtDao.getAllPersons();
    int personId;
    final existingPerson = persons.where(
      (p) => p.name.toLowerCase() == contactName.toLowerCase(),
    );
    if (existingPerson.isNotEmpty) {
      personId = existingPerson.first.id;
    } else {
      personId = await _db.debtDao.createPerson(
        PersonsCompanion.insert(name: contactName),
      );
    }

    final entry = DebtsCompanion.insert(
      personId: personId,
      type: type,
      totalAmount: totalAmount,
      description: Value(description),
      dueDate: Value(dueDate),
      walletId: Value(walletId),
    );

    return _db.debtDao.createDebt(entry);
  }

  /// Delete a debt
  Future<int> deleteDebt(int debtId) async {
    return (_db.delete(_db.debts)..where((tbl) => tbl.id.equals(debtId))).go();
  }

  /// Add a payment to a debt
  Future<int> addPayment({
    required int debtId,
    required int walletId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  }) async {
    final entry = DebtPaymentsCompanion.insert(
      debtId: debtId,
      walletId: walletId,
      amount: amount,
      paymentDate: paymentDate,
      note: Value(note),
    );
    return _db.debtDao.createDebtPayment(entry);
  }

  /// Get payments for a specific debt
  Future<List<DebtPayment>> getPayments(int debtId) {
    return _db.debtDao.getPaymentsByDebt(debtId);
  }

  /// Get all wallets for wallet selection
  Future<List<Wallet>> getWallets() {
    return _db.walletDao.getAllWallets();
  }

  /// Get person by ID
  Future<Person?> getPersonById(int id) {
    return _db.debtDao.getPersonById(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
