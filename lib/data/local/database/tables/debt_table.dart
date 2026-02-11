import 'package:drift/drift.dart';

import 'person_table.dart';
import 'wallet_table.dart';

/// Table for tracking debts and loans
class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId => integer().references(Persons, #id)();
  IntColumn get walletId => integer().nullable().references(Wallets, #id)();
  TextColumn get type => text().withLength(min: 1, max: 20)(); // debt, loan
  RealColumn get totalAmount => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // pending, paid, overdue, due_soon
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
