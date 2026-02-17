import 'package:drift/drift.dart';

/// Table for storing import history records
class ImportHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text().withLength(min: 1, max: 255)();
  TextColumn get filePath => text().nullable()();
  IntColumn get totalRows => integer().withDefault(const Constant(0))();
  IntColumn get importedCount => integer().withDefault(const Constant(0))();
  IntColumn get skippedDuplicates => integer().withDefault(const Constant(0))();
  IntColumn get incomeCount => integer().withDefault(const Constant(0))();
  IntColumn get expenseCount => integer().withDefault(const Constant(0))();
  BoolColumn get isSuccess => boolean().withDefault(const Constant(true))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();
}
