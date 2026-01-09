import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../database/daos/tasks_dao.dart';
import '../database/tables/tasks_table.dart';
import '../mappers/task_mapper.dart';

/// Implementierung des Task-Repositories
@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._db);

  final AppDatabase _db;

  // ============================================================================
  // CRUD Operations
  // ============================================================================

  @override
  Future<List<Task>> getAllTasks() async {
    final tasks = await _db.tasksDao.getAllTasks();
    return tasks.map(TaskMapper.toEntity).toList();
  }

  @override
  Stream<List<Task>> watchAllTasks() {
    return _db.tasksDao.watchAllTasks().map(
          (tasks) => tasks.map(TaskMapper.toEntity).toList(),
        );
  }

  @override
  Future<Task?> getTaskById(int id) async {
    final taskData = await _db.tasksDao.getTaskById(id);
    if (taskData == null) return null;
    return TaskMapper.toEntity(taskData);
  }

  @override
  Stream<Task?> watchTaskById(int id) {
    return _db.tasksDao.watchTaskById(id).map(
          (taskData) => taskData != null ? TaskMapper.toEntity(taskData) : null,
        );
  }

  @override
  Future<int> createTask({
    required String title,
    String description = '',
    TaskStatus status = TaskStatus.open,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    int? noteId,
  }) {
    return _db.tasksDao.createTask(
      TasksTableCompanion.insert(
        title: title,
        description: Value(description),
        status: Value(status),
        priority: Value(priority),
        dueDate: Value(dueDate),
        noteId: Value(noteId),
      ),
    );
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskData = TaskMapper.toData(task);
    await _db.tasksDao.updateTask(taskData);
  }

  @override
  Future<void> deleteTask(int id) async {
    await _db.tasksDao.deleteTask(id);
  }

  // ============================================================================
  // Status Operations
  // ============================================================================

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final tasks = await _db.tasksDao.getTasksByStatus(status);
    return tasks.map(TaskMapper.toEntity).toList();
  }

  @override
  Stream<List<Task>> watchTasksByStatus(TaskStatus status) {
    return _db.tasksDao.watchTasksByStatus(status).map(
          (tasks) => tasks.map(TaskMapper.toEntity).toList(),
        );
  }

  @override
  Future<void> updateTaskStatus(int id, TaskStatus newStatus) async {
    await _db.tasksDao.updateTaskStatus(id, newStatus);
  }

  // ============================================================================
  // Filter & Sort Operations
  // ============================================================================

  @override
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final tasks = await _db.tasksDao.getTasksByPriority(priority);
    return tasks.map(TaskMapper.toEntity).toList();
  }

  @override
  Future<List<Task>> getOverdueTasks() async {
    final tasks = await _db.tasksDao.getOverdueTasks();
    return tasks.map(TaskMapper.toEntity).toList();
  }

  @override
  Future<List<Task>> getTodayTasks() async {
    final tasks = await _db.tasksDao.getTodayTasks();
    return tasks.map(TaskMapper.toEntity).toList();
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    final tasks = await _db.tasksDao.searchTasks(query);
    return tasks.map(TaskMapper.toEntity).toList();
  }

  // ============================================================================
  // Note Relations
  // ============================================================================

  @override
  Future<List<Task>> getTasksByNoteId(int noteId) async {
    final tasks = await _db.tasksDao.getTasksByNoteId(noteId);
    return tasks.map(TaskMapper.toEntity).toList();
  }

  @override
  Stream<List<Task>> watchTasksByNoteId(int noteId) {
    return _db.tasksDao.watchTasksByNoteId(noteId).map(
          (tasks) => tasks.map(TaskMapper.toEntity).toList(),
        );
  }

  @override
  Future<void> setTaskNote(int taskId, int? noteId) async {
    await _db.tasksDao.setTaskNote(taskId, noteId);
  }
}
