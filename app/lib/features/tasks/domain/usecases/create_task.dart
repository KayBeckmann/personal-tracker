import 'package:injectable/injectable.dart';

import '../../data/database/tables/tasks_table.dart';
import '../repositories/task_repository.dart';

/// UseCase zum Erstellen einer neuen Aufgabe
@lazySingleton
class CreateTask {
  CreateTask(this._repository);

  final TaskRepository _repository;

  Future<int> call({
    required String title,
    String description = '',
    TaskStatus status = TaskStatus.open,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    int? noteId,
  }) {
    return _repository.createTask(
      title: title,
      description: description,
      status: status,
      priority: priority,
      dueDate: dueDate,
      noteId: noteId,
    );
  }
}
