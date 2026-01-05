import 'package:equatable/equatable.dart';

import '../../data/database/tables/categories_table.dart';

/// Domain-Entity für eine Kategorie
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    required this.icon,
    this.color,
    required this.sortOrder,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final CategoryType type;
  final int? parentId;
  final String icon;
  final String? color;
  final int sortOrder;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Erstellt eine Kopie mit geänderten Werten
  Category copyWith({
    int? id,
    String? name,
    CategoryType? type,
    int? parentId,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        parentId,
        icon,
        color,
        sortOrder,
        isDefault,
        createdAt,
        updatedAt,
      ];
}
