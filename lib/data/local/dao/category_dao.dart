import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/category_table.dart';

part 'category_dao.g.dart';

/// Data Access Object for category operations
@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  /// Get all categories
  Future<List<Category>> getAllCategories() => (select(
    categories,
  )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();

  /// Get categories by type (income/expense)
  Future<List<Category>> getCategoriesByType(String type) =>
      (select(categories)
            ..where((tbl) => tbl.type.equals(type))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  /// Get expense categories
  Future<List<Category>> getExpenseCategories() =>
      getCategoriesByType('expense');

  /// Get income categories
  Future<List<Category>> getIncomeCategories() => getCategoriesByType('income');

  /// Get category by ID
  Future<Category?> getCategoryById(int id) =>
      (select(categories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Get parent categories (no parent)
  Future<List<Category>> getParentCategories(String type) =>
      (select(categories)
            ..where((tbl) => tbl.type.equals(type) & tbl.parentId.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  /// Get sub-categories by parent ID
  Future<List<Category>> getSubCategories(int parentId) =>
      (select(categories)..where((tbl) => tbl.parentId.equals(parentId))).get();

  /// Watch categories by type for real-time updates
  Stream<List<Category>> watchCategoriesByType(String type) =>
      (select(categories)
            ..where((tbl) => tbl.type.equals(type))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch();

  /// Create a new category
  Future<int> createCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  /// Update existing category
  Future<bool> updateCategory(Category entry) =>
      update(categories).replace(entry);

  /// Update order of categories
  Future<void> updateCategoryOrder(List<Category> entries) async {
    await batch((batch) {
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        batch.update(
          categories,
          CategoriesCompanion(sortOrder: Value(i)),
          where: (tbl) => tbl.id.equals(entry.id),
        );
      }
    });
  }

  /// Delete category (only user-created)
  Future<int> deleteCategory(int id) => (delete(
    categories,
  )..where((tbl) => tbl.id.equals(id) & tbl.isDefault.equals(false))).go();
}
