import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use Case zum Abrufen aller Kategorien
@lazySingleton
class GetAllCategories {
  GetAllCategories(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> call() => _repository.getAllCategories();

  Stream<List<Category>> watch() => _repository.watchAllCategories();
}
