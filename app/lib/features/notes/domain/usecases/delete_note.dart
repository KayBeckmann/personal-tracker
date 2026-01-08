import 'package:injectable/injectable.dart';

import '../repositories/note_repository.dart';

/// UseCase zum Löschen einer Notiz
@lazySingleton
class DeleteNote {
  DeleteNote(this._repository);

  final NoteRepository _repository;

  Future<void> call(int id) {
    return _repository.deleteNote(id);
  }
}
