import 'package:injectable/injectable.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// UseCase zum Abrufen aller Aufgaben
@lazySingleton
class GetAllTasks {
  GetAllTasks(this._repository);

  final TaskRepository _repository;

  Future<List<Task>> call() {
    return _repository.getAllTasks();
  }

  Stream<List<Task>> watch() {
    return _repository.watchAllTasks();
  }
}
