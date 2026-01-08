import 'package:injectable/injectable.dart';

import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// UseCase zum Aktualisieren einer Notiz
@lazySingleton
class UpdateNote {
  UpdateNote(this._repository);

  final NoteRepository _repository;

  Future<void> call(Note note) {
    return _repository.updateNote(note);
  }
}
