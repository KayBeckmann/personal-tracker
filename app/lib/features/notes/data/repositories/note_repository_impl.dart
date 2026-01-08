import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/note_repository.dart';
import '../database/daos/notes_dao.dart';
import '../database/tables/notes_table.dart';
import '../database/tables/tags_table.dart';
import '../mappers/note_mapper.dart';
import '../mappers/tag_mapper.dart';

/// Implementierung des Note-Repositories
@LazySingleton(as: NoteRepository)
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._db);

  final AppDatabase _db;

  // ============================================================================
  // Notes
  // ============================================================================

  @override
  Future<List<Note>> getAllNotes({bool includeArchived = false}) async {
    final notes = await _db.notesDao.getAllNotes(includeArchived: includeArchived);
    final result = <Note>[];

    for (final noteData in notes) {
      final tags = await _db.notesDao.getTagsForNote(noteData.id);
      result.add(NoteMapper.toEntity(
        noteData,
        tags: tags.map<Tag>(TagMapper.toEntity).toList(),
      ));
    }

    return result;
  }

  @override
  Stream<List<Note>> watchAllNotes({bool includeArchived = false}) {
    return _db.notesDao.watchAllNotes(includeArchived: includeArchived).asyncMap((notes) async {
      final result = <Note>[];

      for (final noteData in notes) {
        final tags = await _db.notesDao.getTagsForNote(noteData.id);
        result.add(NoteMapper.toEntity(
          noteData,
          tags: tags.map<Tag>(TagMapper.toEntity).toList(),
        ));
      }

      return result;
    });
  }

  @override
  Future<Note?> getNoteById(int id) async {
    final noteData = await _db.notesDao.getNoteById(id);
    if (noteData == null) return null;

    final tags = await _db.notesDao.getTagsForNote(id);
    return NoteMapper.toEntity(
      noteData,
      tags: tags.map(TagMapper.toEntity).toList(),
    );
  }

  @override
  Stream<Note?> watchNoteById(int id) {
    return _db.notesDao.watchNoteById(id).asyncMap((noteData) async {
      if (noteData == null) return null;

      final tags = await _db.notesDao.getTagsForNote(id);
      return NoteMapper.toEntity(
        noteData,
        tags: tags.map<Tag>(TagMapper.toEntity).toList(),
      );
    });
  }

  @override
  Future<List<Note>> searchNotes(String query, {bool includeArchived = false}) async {
    final notes = await _db.notesDao.searchNotes(query, includeArchived: includeArchived);
    final result = <Note>[];

    for (final noteData in notes) {
      final tags = await _db.notesDao.getTagsForNote(noteData.id);
      result.add(NoteMapper.toEntity(
        noteData,
        tags: tags.map<Tag>(TagMapper.toEntity).toList(),
      ));
    }

    return result;
  }

  @override
  Future<int> createNote({
    required String title,
    required String content,
    List<int> tagIds = const [],
    bool isArchived = false,
  }) async {
    final noteId = await _db.notesDao.createNote(
      NotesTableCompanion.insert(
        title: title,
        content: content,
        isArchived: Value(isArchived),
      ),
    );

    // Tags hinzufügen
    for (final tagId in tagIds) {
      await _db.notesDao.addTagToNote(noteId, tagId);
    }

    return noteId;
  }

  @override
  Future<void> updateNote(Note note) async {
    final noteData = NoteMapper.toData(note);
    await _db.notesDao.updateNote(noteData);

    // Tags aktualisieren
    await _db.notesDao.setTagsForNote(
      note.id,
      note.tags.map((t) => t.id).toList(),
    );
  }

  @override
  Future<void> deleteNote(int id) async {
    await _db.notesDao.deleteNote(id);
  }

  @override
  Future<void> toggleArchive(int id, bool isArchived) async {
    await _db.notesDao.toggleArchive(id, isArchived);
  }

  // ============================================================================
  // Tags
  // ============================================================================

  @override
  Future<List<Tag>> getAllTags() async {
    final tags = await _db.notesDao.getAllTags();
    return tags.map<Tag>(TagMapper.toEntity).toList();
  }

  @override
  Stream<List<Tag>> watchAllTags() {
    return _db.notesDao.watchAllTags().map(
          (tags) => tags.map<Tag>(TagMapper.toEntity).toList(),
        );
  }

  @override
  Future<Tag?> getTagById(int id) async {
    final tagData = await _db.notesDao.getTagById(id);
    if (tagData == null) return null;
    return TagMapper.toEntity(tagData);
  }

  @override
  Future<Tag?> getTagByName(String name) async {
    final tagData = await _db.notesDao.getTagByName(name);
    if (tagData == null) return null;
    return TagMapper.toEntity(tagData);
  }

  @override
  Future<int> createTag({
    required String name,
    String? color,
  }) {
    return _db.notesDao.createTag(
      TagsTableCompanion.insert(
        name: name,
        color: Value(color),
      ),
    );
  }

  @override
  Future<void> updateTag(Tag tag) async {
    final tagData = TagMapper.toData(tag);
    await _db.notesDao.updateTag(tagData);
  }

  @override
  Future<void> deleteTag(int id) async {
    await _db.notesDao.deleteTag(id);
  }

  // ============================================================================
  // Note-Tag Associations
  // ============================================================================

  @override
  Future<List<Note>> getNotesByTag(int tagId, {bool includeArchived = false}) async {
    final notes = await _db.notesDao.getNotesByTag(tagId, includeArchived: includeArchived);
    final result = <Note>[];

    for (final noteData in notes) {
      final tags = await _db.notesDao.getTagsForNote(noteData.id);
      result.add(NoteMapper.toEntity(
        noteData,
        tags: tags.map<Tag>(TagMapper.toEntity).toList(),
      ));
    }

    return result;
  }

  @override
  Future<List<Note>> getNotesByTags(List<int> tagIds, {bool includeArchived = false}) async {
    final notes = await _db.notesDao.getNotesByTags(tagIds, includeArchived: includeArchived);
    final result = <Note>[];

    for (final noteData in notes) {
      final tags = await _db.notesDao.getTagsForNote(noteData.id);
      result.add(NoteMapper.toEntity(
        noteData,
        tags: tags.map<Tag>(TagMapper.toEntity).toList(),
      ));
    }

    return result;
  }

  @override
  Future<void> addTagToNote(int noteId, int tagId) async {
    await _db.notesDao.addTagToNote(noteId, tagId);
  }

  @override
  Future<void> removeTagFromNote(int noteId, int tagId) async {
    await _db.notesDao.removeTagFromNote(noteId, tagId);
  }

  @override
  Future<void> setTagsForNote(int noteId, List<int> tagIds) async {
    await _db.notesDao.setTagsForNote(noteId, tagIds);
  }
}
