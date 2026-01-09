import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../tables/tasks_table.dart';

part 'tasks_dao.g.dart';

/// DAO für Aufgaben-Operationen
@DriftAccessor(tables: [TasksTable])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  // ============================================================================
  // CRUD Operations
  // ============================================================================

  /// Alle Aufgaben abrufen
  Future<List<TaskData>> getAllTasks() {
    return (select(tasksTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.status),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  /// Alle Aufgaben beobachten
  Stream<List<TaskData>> watchAllTasks() {
    return (select(tasksTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.status),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  /// Aufgabe nach ID abrufen
  Future<TaskData?> getTaskById(int id) {
    return (select(tasksTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Aufgabe nach ID beobachten
  Stream<TaskData?> watchTaskById(int id) {
    return (select(tasksTable)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Aufgabe erstellen
  Future<int> createTask(TasksTableCompanion task) {
    return into(tasksTable).insert(task);
  }

  /// Aufgabe aktualisieren
  Future<bool> updateTask(TaskData task) {
    return update(tasksTable).replace(
      task.copyWith(updatedAt: DateTime.now()),
    );
  }

  /// Aufgabe löschen
  Future<int> deleteTask(int id) {
    return (delete(tasksTable)..where((t) => t.id.equals(id))).go();
  }

  // ============================================================================
  // Status Operations
  // ============================================================================

  /// Aufgaben nach Status abrufen
  Future<List<TaskData>> getTasksByStatus(TaskStatus status) {
    return (select(tasksTable)
          ..where((t) => t.status.equals(status.index))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Aufgaben nach Status beobachten
  Stream<List<TaskData>> watchTasksByStatus(TaskStatus status) {
    return (select(tasksTable)
          ..where((t) => t.status.equals(status.index))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Status einer Aufgabe ändern
  Future<void> updateTaskStatus(int id, TaskStatus newStatus) async {
    final now = DateTime.now();
    final completedAt = newStatus == TaskStatus.completed ? Value(now) : const Value(null);

    await (update(tasksTable)..where((t) => t.id.equals(id))).write(
      TasksTableCompanion(
        status: Value(newStatus),
        completedAt: completedAt,
        updatedAt: Value(now),
      ),
    );
  }

  // ============================================================================
  // Filter & Sort Operations
  // ============================================================================

  /// Aufgaben nach Priorität abrufen
  Future<List<TaskData>> getTasksByPriority(TaskPriority priority) {
    return (select(tasksTable)
          ..where((t) => t.priority.equals(priority.index))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Überfällige Aufgaben abrufen
  Future<List<TaskData>> getOverdueTasks() {
    final now = DateTime.now();
    return (select(tasksTable)
          ..where((t) =>
              t.dueDate.isSmallerThanValue(now) &
              t.status.equals(TaskStatus.open.index) |
              t.status.equals(TaskStatus.inProgress.index))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Aufgaben für heute abrufen
  Future<List<TaskData>> getTodayTasks() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return (select(tasksTable)
          ..where((t) =>
              t.dueDate.isBiggerOrEqualValue(startOfDay) &
              t.dueDate.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Aufgaben nach Titel durchsuchen
  Future<List<TaskData>> searchTasks(String query) {
    return (select(tasksTable)
          ..where((t) {
            final titleMatch = t.title.like('%$query%');
            final descMatch = t.description.like('%$query%');
            return titleMatch | descMatch;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  // ============================================================================
  // Note Relations
  // ============================================================================

  /// Aufgaben zu einer Notiz abrufen
  Future<List<TaskData>> getTasksByNoteId(int noteId) {
    return (select(tasksTable)
          ..where((t) => t.noteId.equals(noteId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.status),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  /// Aufgaben zu einer Notiz beobachten
  Stream<List<TaskData>> watchTasksByNoteId(int noteId) {
    return (select(tasksTable)
          ..where((t) => t.noteId.equals(noteId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.status),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  /// Verknüpfung zu Notiz setzen/entfernen
  Future<void> setTaskNote(int taskId, int? noteId) async {
    await (update(tasksTable)..where((t) => t.id.equals(taskId))).write(
      TasksTableCompanion(
        noteId: Value(noteId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
