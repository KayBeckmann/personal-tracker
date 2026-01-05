import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use Case zum Abrufen aller Unterkategorien einer Kategorie
@lazySingleton
class GetSubcategories {
  GetSubcategories(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> call(int parentId) =>
      _repository.getSubcategories(parentId);

  Stream<List<Category>> watch(int parentId) =>
      _repository.watchSubcategories(parentId);
}
