import 'package:drift/drift.dart';

import 'wallet_table.dart';
import 'category_table.dart';

/// Table for income and expense transactions
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get walletId => integer().references(Wallets, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get type =>
      text().withLength(min: 1, max: 20)(); // income, expense
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringType =>
      text().nullable()(); // daily, weekly, monthly, yearly
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
