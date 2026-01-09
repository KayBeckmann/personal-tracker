import 'package:injectable/injectable.dart';

import '../../data/database/tables/tasks_table.dart';
import '../repositories/task_repository.dart';

/// UseCase zum Ändern des Status einer Aufgabe
@lazySingleton
class UpdateTaskStatus {
  UpdateTaskStatus(this._repository);

  final TaskRepository _repository;

  Future<void> call(int id, TaskStatus newStatus) {
    return _repository.updateTaskStatus(id, newStatus);
  }
}
