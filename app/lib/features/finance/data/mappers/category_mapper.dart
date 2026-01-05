import '../../../../core/database/app_database.dart';
import '../../domain/entities/category.dart';
import '../database/tables/categories_table.dart';

/// Mapper zwischen CategoryData (Data Layer) und Category (Domain Layer)
class CategoryMapper {
  /// Konvertiert CategoryData zu Category
  static Category toEntity(CategoryData data) {
    return Category(
      id: data.id,
      name: data.name,
      type: data.type,
      parentId: data.parentId,
      icon: data.icon,
      color: data.color,
      sortOrder: data.sortOrder,
      isDefault: data.isDefault,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Konvertiert Category zu CategoryData
  static CategoryData toData(Category entity) {
    return CategoryData(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      parentId: entity.parentId,
      icon: entity.icon,
      color: entity.color,
      sortOrder: entity.sortOrder,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Konvertiert eine Liste von CategoryData zu Category
  static List<Category> toEntityList(List<CategoryData> dataList) {
    return dataList.map(toEntity).toList();
  }

  /// Konvertiert eine Liste von Category zu CategoryData
  static List<CategoryData> toDataList(List<Category> entityList) {
    return entityList.map(toData).toList();
  }
}
