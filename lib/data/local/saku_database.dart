import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/transaction.dart';

part 'saku_database.g.dart';

class TransactionsTable extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get type => text().withDefault(const Constant(''))();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TransactionsTable])
class SakuDatabase extends _$SakuDatabase {
  SakuDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactionsTable)..orderBy([
          (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
        ]))
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => Transaction(
                  id: row.id,
                  amount: row.amount,
                  description: row.description,
                  category: row.category,
                  type: row.type,
                  timestamp: row.timestamp,
                ),
              )
              .toList(),
        );
  }

  Future<void> upsertTransaction(
    Transaction transaction, {
    bool synced = false,
  }) async {
    into(transactionsTable).insertOnConflictUpdate(
      TransactionsTableCompanion(
        id: Value(transaction.id),
        amount: Value(transaction.amount),
        description: Value(transaction.description),
        category: Value(transaction.category),
        type: Value(transaction.type),
        timestamp: Value(transaction.timestamp),
        synced: Value(synced),
      ),
    );
  }
}

// Opens the database connection lazily.  Only call this from within SakuDatabase.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'saku.sqlite'));
    return NativeDatabase(file);
  });
}
