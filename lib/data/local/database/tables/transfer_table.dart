import 'package:drift/drift.dart';

import 'wallet_table.dart';

/// Table for transfers between wallets
class Transfers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fromWalletId => integer().references(Wallets, #id)();
  IntColumn get toWalletId => integer().references(Wallets, #id)();
  RealColumn get amount => real()();
  RealColumn get fee => real().withDefault(const Constant(0.0))();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get transferDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
