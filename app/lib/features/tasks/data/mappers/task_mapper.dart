import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/task.dart';
import '../database/tables/tasks_table.dart';

/// Mapper für Task-Konvertierungen zwischen Domain und Data Layer
class TaskMapper {
  /// Konvertiert TaskData zu Task Entity
  static Task toEntity(TaskData data) {
    return Task(
      id: data.id,
      title: data.title,
      description: data.description,
      status: data.status,
      priority: data.priority,
      dueDate: data.dueDate,
      completedAt: data.completedAt,
      noteId: data.noteId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Konvertiert Task Entity zu TaskData
  static TaskData toData(Task entity) {
    return TaskData(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      priority: entity.priority,
      dueDate: entity.dueDate,
      completedAt: entity.completedAt,
      noteId: entity.noteId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Konvertiert Task Entity zu TasksTableCompanion für Insert/Update
  static TasksTableCompanion toCompanion(Task entity, {bool forUpdate = false}) {
    if (forUpdate) {
      return TasksTableCompanion(
        id: Value(entity.id),
        title: Value(entity.title),
        description: Value(entity.description),
        status: Value(entity.status),
        priority: Value(entity.priority),
        dueDate: Value(entity.dueDate),
        completedAt: Value(entity.completedAt),
        noteId: Value(entity.noteId),
        updatedAt: Value(DateTime.now()),
      );
    } else {
      return TasksTableCompanion.insert(
        title: entity.title,
        description: Value(entity.description),
        status: Value(entity.status),
        priority: Value(entity.priority),
        dueDate: Value(entity.dueDate),
        completedAt: Value(entity.completedAt),
        noteId: Value(entity.noteId),
      );
    }
  }
}
