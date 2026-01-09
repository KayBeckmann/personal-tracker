import 'package:injectable/injectable.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// UseCase zum Abrufen der heutigen Aufgaben
@lazySingleton
class GetTodayTasks {
  GetTodayTasks(this._repository);

  final TaskRepository _repository;

  Future<List<Task>> call() {
    return _repository.getTodayTasks();
  }
}
