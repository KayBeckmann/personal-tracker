import 'package:injectable/injectable.dart';

import '../repositories/note_repository.dart';

/// UseCase zum Erstellen eines neuen Tags
@lazySingleton
class CreateTag {
  CreateTag(this._repository);

  final NoteRepository _repository;

  Future<int> call({
    required String name,
    String? color,
  }) {
    return _repository.createTag(
      name: name,
      color: color,
    );
  }
}
