import 'package:drift/drift.dart';

/// Table for transaction categories with optional parent for sub-categories
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type =>
      text().withLength(min: 1, max: 20)(); // income, expense
  TextColumn get icon => text().withDefault(const Constant('category'))();
  IntColumn get iconColor =>
      integer().withDefault(const Constant(0xFF2196F3))();
  IntColumn get parentId => integer().nullable().references(Categories, #id)();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
