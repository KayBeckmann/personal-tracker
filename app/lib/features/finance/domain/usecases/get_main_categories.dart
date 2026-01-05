import 'package:injectable/injectable.dart';

import '../../data/database/tables/categories_table.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use Case zum Abrufen aller Hauptkategorien
@lazySingleton
class GetMainCategories {
  GetMainCategories(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> call({CategoryType? type}) =>
      _repository.getMainCategories(type: type);

  Stream<List<Category>> watch({CategoryType? type}) =>
      _repository.watchMainCategories(type: type);
}
