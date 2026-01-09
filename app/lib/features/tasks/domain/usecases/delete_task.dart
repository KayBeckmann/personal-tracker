import 'package:injectable/injectable.dart';

import '../repositories/task_repository.dart';

/// UseCase zum Löschen einer Aufgabe
@lazySingleton
class DeleteTask {
  DeleteTask(this._repository);

  final TaskRepository _repository;

  Future<void> call(int id) {
    return _repository.deleteTask(id);
  }
}
