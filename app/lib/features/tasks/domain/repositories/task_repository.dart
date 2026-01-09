import '../../data/database/tables/tasks_table.dart';
import '../entities/task.dart';

/// Repository-Interface für Aufgaben
abstract class TaskRepository {
  // ============================================================================
  // CRUD Operations
  // ============================================================================

  /// Alle Aufgaben abrufen
  Future<List<Task>> getAllTasks();

  /// Alle Aufgaben beobachten
  Stream<List<Task>> watchAllTasks();

  /// Aufgabe nach ID abrufen
  Future<Task?> getTaskById(int id);

  /// Aufgabe nach ID beobachten
  Stream<Task?> watchTaskById(int id);

  /// Aufgabe erstellen
  Future<int> createTask({
    required String title,
    String description = '',
    TaskStatus status = TaskStatus.open,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    int? noteId,
  });

  /// Aufgabe aktualisieren
  Future<void> updateTask(Task task);

  /// Aufgabe löschen
  Future<void> deleteTask(int id);

  // ============================================================================
  // Status Operations
  // ============================================================================

  /// Aufgaben nach Status abrufen
  Future<List<Task>> getTasksByStatus(TaskStatus status);

  /// Aufgaben nach Status beobachten
  Stream<List<Task>> watchTasksByStatus(TaskStatus status);

  /// Status einer Aufgabe ändern
  Future<void> updateTaskStatus(int id, TaskStatus newStatus);

  // ============================================================================
  // Filter & Sort Operations
  // ============================================================================

  /// Aufgaben nach Priorität abrufen
  Future<List<Task>> getTasksByPriority(TaskPriority priority);

  /// Überfällige Aufgaben abrufen
  Future<List<Task>> getOverdueTasks();

  /// Aufgaben für heute abrufen
  Future<List<Task>> getTodayTasks();

  /// Aufgaben nach Titel durchsuchen
  Future<List<Task>> searchTasks(String query);

  // ============================================================================
  // Note Relations
  // ============================================================================

  /// Aufgaben zu einer Notiz abrufen
  Future<List<Task>> getTasksByNoteId(int noteId);

  /// Aufgaben zu einer Notiz beobachten
  Stream<List<Task>> watchTasksByNoteId(int noteId);

  /// Verknüpfung zu Notiz setzen/entfernen
  Future<void> setTaskNote(int taskId, int? noteId);
}
