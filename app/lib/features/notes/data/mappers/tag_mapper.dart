import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/tag.dart';

/// Mapper für Tag-Konvertierungen zwischen Domain und Data Layer
class TagMapper {
  /// Konvertiert TagData zu Tag Entity
  static Tag toEntity(TagData data) {
    return Tag(
      id: data.id,
      name: data.name,
      color: data.color,
      createdAt: data.createdAt,
    );
  }

  /// Konvertiert Tag Entity zu TagData
  static TagData toData(Tag entity) {
    return TagData(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      createdAt: entity.createdAt,
    );
  }

  /// Konvertiert Tag Entity zu TagsTableCompanion für Insert/Update
  static TagsTableCompanion toCompanion(Tag entity, {bool forUpdate = false}) {
    if (forUpdate) {
      return TagsTableCompanion(
        id: Value(entity.id),
        name: Value(entity.name),
        color: Value(entity.color),
      );
    } else {
      return TagsTableCompanion.insert(
        name: entity.name,
        color: Value(entity.color),
      );
    }
  }
}
