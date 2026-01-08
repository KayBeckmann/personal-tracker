import 'package:injectable/injectable.dart';

import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// UseCase zum Abrufen einer Notiz nach ID
@lazySingleton
class GetNoteById {
  GetNoteById(this._repository);

  final NoteRepository _repository;

  Future<Note?> call(int id) {
    return _repository.getNoteById(id);
  }

  Stream<Note?> watch(int id) {
    return _repository.watchNoteById(id);
  }
}
