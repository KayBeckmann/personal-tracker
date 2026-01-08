import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/tag.dart';

/// Mapper für Note-Konvertierungen zwischen Domain und Data Layer
class NoteMapper {
  /// Konvertiert NoteData zu Note Entity
  static Note toEntity(NoteData data, {List<Tag> tags = const []}) {
    return Note(
      id: data.id,
      title: data.title,
      content: data.content,
      tags: tags,
      isArchived: data.isArchived,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Konvertiert Note Entity zu NoteData
  static NoteData toData(Note entity) {
    return NoteData(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Konvertiert Note Entity zu NotesTableCompanion für Insert/Update
  static NotesTableCompanion toCompanion(Note entity, {bool forUpdate = false}) {
    if (forUpdate) {
      return NotesTableCompanion(
        id: Value(entity.id),
        title: Value(entity.title),
        content: Value(entity.content),
        isArchived: Value(entity.isArchived),
        updatedAt: Value(DateTime.now()),
      );
    } else {
      return NotesTableCompanion.insert(
        title: entity.title,
        content: entity.content,
        isArchived: Value(entity.isArchived),
      );
    }
  }
}
