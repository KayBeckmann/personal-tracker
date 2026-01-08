import 'package:injectable/injectable.dart';

import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// UseCase zum Durchsuchen von Notizen nach Freitext
@lazySingleton
class SearchNotes {
  SearchNotes(this._repository);

  final NoteRepository _repository;

  Future<List<Note>> call(String query, {bool includeArchived = false}) {
    return _repository.searchNotes(query, includeArchived: includeArchived);
  }
}
