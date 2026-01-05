import '../../data/database/tables/categories_table.dart';
import '../entities/category.dart';

/// Repository-Interface für Kategorien
abstract class CategoryRepository {
  /// Gibt alle Kategorien zurück
  Future<List<Category>> getAllCategories();

  /// Stream aller Kategorien
  Stream<List<Category>> watchAllCategories();

  /// Gibt alle Hauptkategorien (ohne Eltern) zurück
  Future<List<Category>> getMainCategories({CategoryType? type});

  /// Stream der Hauptkategorien
  Stream<List<Category>> watchMainCategories({CategoryType? type});

  /// Gibt alle Unterkategorien einer Kategorie zurück
  Future<List<Category>> getSubcategories(int parentId);

  /// Stream der Unterkategorien
  Stream<List<Category>> watchSubcategories(int parentId);

  /// Gibt Kategorien nach Typ zurück (income/expense)
  Future<List<Category>> getCategoriesByType(CategoryType type);

  /// Stream der Kategorien nach Typ
  Stream<List<Category>> watchCategoriesByType(CategoryType type);

  /// Gibt eine einzelne Kategorie zurück
  Future<Category?> getCategoryById(int id);

  /// Stream einer einzelnen Kategorie
  Stream<Category?> watchCategoryById(int id);

  /// Erstellt eine neue Kategorie
  Future<int> createCategory({
    required String name,
    required CategoryType type,
    int? parentId,
    required String icon,
    String? color,
    int sortOrder = 0,
  });

  /// Aktualisiert eine Kategorie
  Future<void> updateCategory(Category category);

  /// Löscht eine Kategorie
  Future<void> deleteCategory(int id);

  /// Prüft ob eine Kategorie Unterkategorien hat
  Future<bool> hasSubcategories(int id);
}
