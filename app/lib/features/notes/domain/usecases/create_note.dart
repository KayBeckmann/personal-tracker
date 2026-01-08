import 'package:injectable/injectable.dart';

import '../repositories/note_repository.dart';

/// UseCase zum Erstellen einer neuen Notiz
@lazySingleton
class CreateNote {
  CreateNote(this._repository);

  final NoteRepository _repository;

  Future<int> call({
    required String title,
    required String content,
    List<int> tagIds = const [],
    bool isArchived = false,
  }) {
    return _repository.createNote(
      title: title,
      content: content,
      tagIds: tagIds,
      isArchived: isArchived,
    );
  }
}
