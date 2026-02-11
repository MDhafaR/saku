import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/wallet_table.dart';
import 'tables/category_table.dart';
import 'tables/transaction_table.dart';
import 'tables/transfer_table.dart';
import 'tables/person_table.dart';
import 'tables/debt_table.dart';
import 'tables/debt_payment_table.dart';
import '../dao/transaction_dao.dart';
import '../dao/category_dao.dart';
import '../dao/wallet_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Wallets,
    Categories,
    Transactions,
    Transfers,
    Persons,
    Debts,
    DebtPayments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Named constructor for testing with a custom executor
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed default categories
        await _seedDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          // Add new wallet columns: accountNumber, isMain, isNumberMasked
          await m.addColumn(wallets, wallets.accountNumber);
          await m.addColumn(wallets, wallets.isMain);
          await m.addColumn(wallets, wallets.isNumberMasked);
        }
      },
    );
  }

  // DAO Accessors
  TransactionDao get transactionDao => TransactionDao(this);
  CategoryDao get categoryDao => CategoryDao(this);
  WalletDao get walletDao => WalletDao(this);

  /// Seeds the database with default expense and income categories
  Future<void> _seedDefaultCategories() async {
    final defaultExpenseCategories = [
      CategoriesCompanion.insert(
        name: 'Food & Drinks',
        type: 'expense',
        icon: const Value('restaurant'),
        iconColor: const Value(0xFFFF5722),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Transportation',
        type: 'expense',
        icon: const Value('directions_car'),
        iconColor: const Value(0xFF2196F3),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Shopping',
        type: 'expense',
        icon: const Value('shopping_cart'),
        iconColor: const Value(0xFF9C27B0),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Bills & Utilities',
        type: 'expense',
        icon: const Value('receipt'),
        iconColor: const Value(0xFF607D8B),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Entertainment',
        type: 'expense',
        icon: const Value('movie'),
        iconColor: const Value(0xFFE91E63),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Health',
        type: 'expense',
        icon: const Value('medical_services'),
        iconColor: const Value(0xFFE53935),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Education',
        type: 'expense',
        icon: const Value('school'),
        iconColor: const Value(0xFF3F51B5),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Travel',
        type: 'expense',
        icon: const Value('flight'),
        iconColor: const Value(0xFF00BCD4),
        isDefault: const Value(true),
      ),
    ];

    final defaultIncomeCategories = [
      CategoriesCompanion.insert(
        name: 'Salary',
        type: 'income',
        icon: const Value('payments'),
        iconColor: const Value(0xFF4CAF50),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Business',
        type: 'income',
        icon: const Value('business'),
        iconColor: const Value(0xFF8BC34A),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Gift',
        type: 'income',
        icon: const Value('card_giftcard'),
        iconColor: const Value(0xFFFF9800),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Investment',
        type: 'income',
        icon: const Value('trending_up'),
        iconColor: const Value(0xFF009688),
        isDefault: const Value(true),
      ),
    ];

    await batch((batch) {
      batch.insertAll(categories, defaultExpenseCategories);
      batch.insertAll(categories, defaultIncomeCategories);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'saku.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
