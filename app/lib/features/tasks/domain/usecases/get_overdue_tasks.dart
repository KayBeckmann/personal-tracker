import 'package:injectable/injectable.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// UseCase zum Abrufen überfälliger Aufgaben
@lazySingleton
class GetOverdueTasks {
  GetOverdueTasks(this._repository);

  final TaskRepository _repository;

  Future<List<Task>> call() {
    return _repository.getOverdueTasks();
  }
}
