import 'package:injectable/injectable.dart';

import '../repositories/note_repository.dart';

/// UseCase zum Archivieren/Dearchivieren einer Notiz
@lazySingleton
class ToggleNoteArchive {
  ToggleNoteArchive(this._repository);

  final NoteRepository _repository;

  Future<void> call(int id, bool isArchived) {
    return _repository.toggleArchive(id, isArchived);
  }
}
