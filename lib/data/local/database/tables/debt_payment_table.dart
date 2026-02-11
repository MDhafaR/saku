import 'package:drift/drift.dart';

import 'debt_table.dart';
import 'wallet_table.dart';

/// Table for tracking debt payments/installments
class DebtPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId => integer().references(Debts, #id)();
  IntColumn get walletId => integer().references(Wallets, #id)();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get paymentDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
