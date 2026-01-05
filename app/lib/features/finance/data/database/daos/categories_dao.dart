import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

/// DAO für Kategorien
@DriftAccessor(tables: [CategoriesTable])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  /// Gibt alle Kategorien sortiert zurück
  Future<List<CategoryData>> getAllCategories() {
    return (select(categoriesTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.type),
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Stream aller Kategorien
  Stream<List<CategoryData>> watchAllCategories() {
    return (select(categoriesTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.type),
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Gibt alle Hauptkategorien (ohne Eltern) zurück
  Future<List<CategoryData>> getMainCategories({CategoryType? type}) {
    final query = select(categoriesTable)
      ..where((t) => t.parentId.isNull());

    if (type != null) {
      query.where((t) => t.type.equals(type.index));
    }

    return (query
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Stream der Hauptkategorien
  Stream<List<CategoryData>> watchMainCategories({CategoryType? type}) {
    final query = select(categoriesTable)
      ..where((t) => t.parentId.isNull());

    if (type != null) {
      query.where((t) => t.type.equals(type.index));
    }

    return (query
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Gibt alle Unterkategorien einer Kategorie zurück
  Future<List<CategoryData>> getSubcategories(int parentId) {
    return (select(categoriesTable)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Stream der Unterkategorien
  Stream<List<CategoryData>> watchSubcategories(int parentId) {
    return (select(categoriesTable)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Gibt Kategorien nach Typ zurück (income/expense)
  Future<List<CategoryData>> getCategoriesByType(CategoryType type) {
    return (select(categoriesTable)
          ..where((t) => t.type.equals(type.index))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Stream der Kategorien nach Typ
  Stream<List<CategoryData>> watchCategoriesByType(CategoryType type) {
    return (select(categoriesTable)
          ..where((t) => t.type.equals(type.index))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Gibt eine einzelne Kategorie zurück
  Future<CategoryData?> getCategoryById(int id) {
    return (select(categoriesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Stream einer einzelnen Kategorie
  Stream<CategoryData?> watchCategoryById(int id) {
    return (select(categoriesTable)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Erstellt eine neue Kategorie
  Future<int> createCategory(CategoriesTableCompanion entry) {
    return into(categoriesTable).insert(entry);
  }

  /// Aktualisiert eine Kategorie
  Future<bool> updateCategory(CategoryData category) {
    return update(categoriesTable).replace(category);
  }

  /// Löscht eine Kategorie (nur wenn nicht Standard-Kategorie)
  Future<int> deleteCategory(int id) async {
    final category = await getCategoryById(id);
    if (category == null) return 0;

    // Standard-Kategorien können nicht gelöscht werden
    if (category.isDefault) {
      throw Exception('Default categories cannot be deleted');
    }

    // Prüfen ob Unterkategorien existieren
    final subcategories = await getSubcategories(id);
    if (subcategories.isNotEmpty) {
      throw Exception('Cannot delete category with subcategories');
    }

    // TODO: Prüfen ob Buchungen mit dieser Kategorie existieren
    // (wird in Meilenstein 2.4 implementiert)

    return (delete(categoriesTable)..where((t) => t.id.equals(id))).go();
  }

  /// Prüft ob eine Kategorie Unterkategorien hat
  Future<bool> hasSubcategories(int id) async {
    final subcategories = await getSubcategories(id);
    return subcategories.isNotEmpty;
  }
}
