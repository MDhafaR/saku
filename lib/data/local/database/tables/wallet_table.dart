import 'package:drift/drift.dart';

/// Table for storing user wallets/accounts (bank accounts, cash, e-wallets)
class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type =>
      text().withLength(min: 1, max: 50)(); // cash, bank, e-wallet, credit_card
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  TextColumn get icon => text().withDefault(const Constant('wallet'))();
  IntColumn get iconColor =>
      integer().withDefault(const Constant(0xFF4CAF50))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get accountNumber => text().nullable()();
  BoolColumn get isMain => boolean().withDefault(const Constant(false))();
  BoolColumn get isNumberMasked =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
