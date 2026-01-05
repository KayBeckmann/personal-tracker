import 'package:injectable/injectable.dart';

import '../../data/database/tables/categories_table.dart';
import '../repositories/category_repository.dart';

/// Use Case zum Erstellen einer Kategorie
@lazySingleton
class CreateCategory {
  CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<int> call({
    required String name,
    required CategoryType type,
    int? parentId,
    required String icon,
    String? color,
    int sortOrder = 0,
  }) =>
      _repository.createCategory(
        name: name,
        type: type,
        parentId: parentId,
        icon: icon,
        color: color,
        sortOrder: sortOrder,
      );
}
