import 'package:injectable/injectable.dart';

import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// UseCase zum Abrufen aller Notizen
@lazySingleton
class GetAllNotes {
  GetAllNotes(this._repository);

  final NoteRepository _repository;

  Future<List<Note>> call({bool includeArchived = false}) {
    return _repository.getAllNotes(includeArchived: includeArchived);
  }

  Stream<List<Note>> watch({bool includeArchived = false}) {
    return _repository.watchAllNotes(includeArchived: includeArchived);
  }
}
