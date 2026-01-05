import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/category.dart' as domain;
import '../../domain/repositories/category_repository.dart';
import '../database/tables/categories_table.dart';
import '../mappers/category_mapper.dart';

/// Implementierung des CategoryRepository
@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<domain.Category>> getAllCategories() async {
    final categories = await _db.categoriesDao.getAllCategories();
    return CategoryMapper.toEntityList(categories);
  }

  @override
  Stream<List<domain.Category>> watchAllCategories() {
    return _db.categoriesDao
        .watchAllCategories()
        .map(CategoryMapper.toEntityList);
  }

  @override
  Future<List<domain.Category>> getMainCategories({CategoryType? type}) async {
    final categories = await _db.categoriesDao.getMainCategories(type: type);
    return CategoryMapper.toEntityList(categories);
  }

  @override
  Stream<List<domain.Category>> watchMainCategories({CategoryType? type}) {
    return _db.categoriesDao
        .watchMainCategories(type: type)
        .map(CategoryMapper.toEntityList);
  }

  @override
  Future<List<domain.Category>> getSubcategories(int parentId) async {
    final categories = await _db.categoriesDao.getSubcategories(parentId);
    return CategoryMapper.toEntityList(categories);
  }

  @override
  Stream<List<domain.Category>> watchSubcategories(int parentId) {
    return _db.categoriesDao
        .watchSubcategories(parentId)
        .map(CategoryMapper.toEntityList);
  }

  @override
  Future<List<domain.Category>> getCategoriesByType(CategoryType type) async {
    final categories = await _db.categoriesDao.getCategoriesByType(type);
    return CategoryMapper.toEntityList(categories);
  }

  @override
  Stream<List<domain.Category>> watchCategoriesByType(CategoryType type) {
    return _db.categoriesDao
        .watchCategoriesByType(type)
        .map(CategoryMapper.toEntityList);
  }

  @override
  Future<domain.Category?> getCategoryById(int id) async {
    final category = await _db.categoriesDao.getCategoryById(id);
    return category != null ? CategoryMapper.toEntity(category) : null;
  }

  @override
  Stream<domain.Category?> watchCategoryById(int id) {
    return _db.categoriesDao.watchCategoryById(id).map(
          (category) =>
              category != null ? CategoryMapper.toEntity(category) : null,
        );
  }

  @override
  Future<int> createCategory({
    required String name,
    required CategoryType type,
    int? parentId,
    required String icon,
    String? color,
    int sortOrder = 0,
  }) {
    return _db.categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: name,
        type: type,
        parentId: Value(parentId),
        icon: icon,
        color: Value(color),
        sortOrder: Value(sortOrder),
      ),
    );
  }

  @override
  Future<void> updateCategory(domain.Category category) async {
    final data = CategoryMapper.toData(category);
    await _db.categoriesDao.updateCategory(data);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _db.categoriesDao.deleteCategory(id);
  }

  @override
  Future<bool> hasSubcategories(int id) {
    return _db.categoriesDao.hasSubcategories(id);
  }
}
