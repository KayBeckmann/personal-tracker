import 'package:injectable/injectable.dart';

import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// UseCase zum Filtern von Notizen nach Tags
@lazySingleton
class GetNotesByTags {
  GetNotesByTags(this._repository);

  final NoteRepository _repository;

  Future<List<Note>> call(List<int> tagIds, {bool includeArchived = false}) {
    return _repository.getNotesByTags(tagIds, includeArchived: includeArchived);
  }
}
