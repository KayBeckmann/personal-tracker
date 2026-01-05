import 'package:injectable/injectable.dart';

import '../../data/database/tables/categories_table.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use Case zum Abrufen von Kategorien nach Typ
@lazySingleton
class GetCategoriesByType {
  GetCategoriesByType(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> call(CategoryType type) =>
      _repository.getCategoriesByType(type);

  Stream<List<Category>> watch(CategoryType type) =>
      _repository.watchCategoriesByType(type);
}
