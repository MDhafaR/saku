import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/debt_table.dart';
import '../database/tables/debt_payment_table.dart';
import '../database/tables/person_table.dart';
import '../database/tables/wallet_table.dart';

part 'debt_dao.g.dart';

/// Data Access Object for debt/loan operations
@DriftAccessor(tables: [Debts, DebtPayments, Persons, Wallets])
class DebtDao extends DatabaseAccessor<AppDatabase> with _$DebtDaoMixin {
  DebtDao(super.db);

  // ===== PERSON OPERATIONS =====

  /// Get all persons
  Future<List<Person>> getAllPersons() => select(persons).get();

  /// Get person by ID
  Future<Person?> getPersonById(int id) =>
      (select(persons)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Create a new person
  Future<int> createPerson(PersonsCompanion entry) =>
      into(persons).insert(entry);

  /// Update existing person
  Future<bool> updatePerson(Person entry) => update(persons).replace(entry);

  // ===== DEBT OPERATIONS =====

  /// Get all debts/loans ordered by due date
  Future<List<Debt>> getAllDebts() =>
      (select(debts)..orderBy([(t) => OrderingTerm.asc(t.dueDate)])).get();

  /// Get debts by type (debt = we owe, loan = they owe us)
  Future<List<Debt>> getDebtsByType(String type) =>
      (select(debts)
            ..where((tbl) => tbl.type.equals(type))
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .get();

  /// Get debts by status
  Future<List<Debt>> getDebtsByStatus(String status) =>
      (select(debts)
            ..where((tbl) => tbl.status.equals(status))
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .get();

  /// Get unpaid debts
  Future<List<Debt>> getUnpaidDebts() =>
      (select(debts)
            ..where((tbl) => tbl.status.isNotIn(['paid']))
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .get();

  /// Get debts for a person
  Future<List<Debt>> getDebtsByPerson(int personId) =>
      (select(debts)
            ..where((tbl) => tbl.personId.equals(personId))
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .get();

  /// Get a single debt by ID
  Future<Debt?> getDebt(int id) =>
      (select(debts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Watch all debts for real-time updates
  Stream<List<Debt>> watchAllDebts() =>
      (select(debts)..orderBy([(t) => OrderingTerm.asc(t.dueDate)])).watch();

  /// Watch unpaid debts
  Stream<List<Debt>> watchUnpaidDebts() =>
      (select(debts)
            ..where((tbl) => tbl.status.isNotIn(['paid']))
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();

  /// Create a new debt and optionally update wallet balance
  Future<int> createDebt(
    DebtsCompanion entry, {
    bool updateWallet = true,
  }) async {
    final debtId = await into(debts).insert(entry);

    // Update wallet balance if wallet is specified
    if (updateWallet && entry.walletId.value != null) {
      final wallet = await (select(
        wallets,
      )..where((tbl) => tbl.id.equals(entry.walletId.value!))).getSingle();

      // Debt = we receive money, Loan = we give money
      final change = entry.type.value == 'debt'
          ? entry.totalAmount.value
          : -entry.totalAmount.value;

      await (update(wallets)..where((tbl) => tbl.id.equals(wallet.id))).write(
        WalletsCompanion(
          currentBalance: Value(wallet.currentBalance + change),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    return debtId;
  }

  /// Update debt status based on paid amount
  Future<void> updateDebtStatus(int debtId) async {
    final debt = await (select(
      debts,
    )..where((tbl) => tbl.id.equals(debtId))).getSingle();

    String newStatus;
    if (debt.paidAmount >= debt.totalAmount) {
      newStatus = 'paid';
    } else if (debt.dueDate != null && debt.dueDate!.isBefore(DateTime.now())) {
      newStatus = 'overdue';
    } else if (debt.dueDate != null &&
        debt.dueDate!.difference(DateTime.now()).inDays <= 7) {
      newStatus = 'due_soon';
    } else {
      newStatus = 'pending';
    }

    await (update(debts)..where((tbl) => tbl.id.equals(debtId))).write(
      DebtsCompanion(
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ===== DEBT PAYMENT OPERATIONS =====

  /// Get all payments for a debt
  Future<List<DebtPayment>> getPaymentsByDebt(int debtId) =>
      (select(debtPayments)
            ..where((tbl) => tbl.debtId.equals(debtId))
            ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
          .get();

  /// Create a debt payment
  Future<int> createDebtPayment(DebtPaymentsCompanion entry) async {
    final paymentId = await into(debtPayments).insert(entry);

    // Get the debt
    final debt = await (select(
      debts,
    )..where((tbl) => tbl.id.equals(entry.debtId.value))).getSingle();

    // Update paid amount on debt
    final newPaidAmount = debt.paidAmount + entry.amount.value;
    await (update(debts)..where((tbl) => tbl.id.equals(debt.id))).write(
      DebtsCompanion(
        paidAmount: Value(newPaidAmount),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Update wallet balance
    final wallet = await (select(
      wallets,
    )..where((tbl) => tbl.id.equals(entry.walletId.value))).getSingle();

    // Debt payment = we pay money out, Loan payment = we receive money
    final change = debt.type == 'debt'
        ? -entry.amount.value
        : entry.amount.value;

    await (update(wallets)..where((tbl) => tbl.id.equals(wallet.id))).write(
      WalletsCompanion(
        currentBalance: Value(wallet.currentBalance + change),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Update debt status
    await updateDebtStatus(debt.id);

    return paymentId;
  }

  /// Get total amount owed to us (loans)
  Future<double> getTotalLoanAmount() async {
    final loans = await getDebtsByType('loan');
    return loans.fold<double>(
      0.0,
      (sum, d) => sum + (d.totalAmount - d.paidAmount),
    );
  }

  /// Get total amount we owe (debts)
  Future<double> getTotalDebtAmount() async {
    final debts = await getDebtsByType('debt');
    return debts.fold<double>(
      0.0,
      (sum, d) => sum + (d.totalAmount - d.paidAmount),
    );
  }
}
