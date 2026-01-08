import 'package:injectable/injectable.dart';

import '../entities/tag.dart';
import '../repositories/note_repository.dart';

/// UseCase zum Abrufen aller Tags
@lazySingleton
class GetAllTags {
  GetAllTags(this._repository);

  final NoteRepository _repository;

  Future<List<Tag>> call() {
    return _repository.getAllTags();
  }

  Stream<List<Tag>> watch() {
    return _repository.watchAllTags();
  }
}
