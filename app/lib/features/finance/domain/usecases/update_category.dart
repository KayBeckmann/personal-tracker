import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use Case zum Aktualisieren einer Kategorie
@lazySingleton
class UpdateCategory {
  UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call(Category category) => _repository.updateCategory(category);
}
