import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../tables/note_tags_table.dart';
import '../tables/notes_table.dart';
import '../tables/tags_table.dart';

part 'notes_dao.g.dart';

/// DAO für Notizen-Operationen
@DriftAccessor(tables: [NotesTable, TagsTable, NoteTagsTable])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  // ============================================================================
  // Notes CRUD
  // ============================================================================

  /// Alle Notizen abrufen (ohne archivierte)
  Future<List<NoteData>> getAllNotes({bool includeArchived = false}) {
    final query = select(notesTable)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);

    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }

    return query.get();
  }

  /// Alle Notizen beobachten (ohne archivierte)
  Stream<List<NoteData>> watchAllNotes({bool includeArchived = false}) {
    final query = select(notesTable)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);

    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }

    return query.watch();
  }

  /// Notiz nach ID abrufen
  Future<NoteData?> getNoteById(int id) {
    return (select(notesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Notiz nach ID beobachten
  Stream<NoteData?> watchNoteById(int id) {
    return (select(notesTable)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Notizen nach Freitext durchsuchen
  Future<List<NoteData>> searchNotes(String query, {bool includeArchived = false}) {
    final searchQuery = select(notesTable)
      ..where((t) {
        final titleMatch = t.title.like('%$query%');
        final contentMatch = t.content.like('%$query%');
        final archivedFilter = includeArchived ? const Constant(true) : t.isArchived.equals(false);
        return (titleMatch | contentMatch) & archivedFilter;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);

    return searchQuery.get();
  }

  /// Notiz erstellen
  Future<int> createNote(NotesTableCompanion note) {
    return into(notesTable).insert(note);
  }

  /// Notiz aktualisieren
  Future<bool> updateNote(NoteData note) {
    return update(notesTable).replace(
      note.copyWith(updatedAt: DateTime.now()),
    );
  }

  /// Notiz löschen
  Future<int> deleteNote(int id) {
    return (delete(notesTable)..where((t) => t.id.equals(id))).go();
  }

  /// Notiz archivieren/dearchivieren
  Future<void> toggleArchive(int id, bool isArchived) async {
    await (update(notesTable)..where((t) => t.id.equals(id))).write(
      NotesTableCompanion(
        isArchived: Value(isArchived),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // Tags CRUD
  // ============================================================================

  /// Alle Tags abrufen
  Future<List<TagData>> getAllTags() {
    return (select(tagsTable)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  /// Alle Tags beobachten
  Stream<List<TagData>> watchAllTags() {
    return (select(tagsTable)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  /// Tag nach ID abrufen
  Future<TagData?> getTagById(int id) {
    return (select(tagsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Tag nach Name abrufen
  Future<TagData?> getTagByName(String name) {
    return (select(tagsTable)..where((t) => t.name.equals(name))).getSingleOrNull();
  }

  /// Tag erstellen
  Future<int> createTag(TagsTableCompanion tag) {
    return into(tagsTable).insert(tag);
  }

  /// Tag aktualisieren
  Future<bool> updateTag(TagData tag) {
    return update(tagsTable).replace(tag);
  }

  /// Tag löschen
  Future<int> deleteTag(int id) {
    return (delete(tagsTable)..where((t) => t.id.equals(id))).go();
  }

  // ============================================================================
  // Note-Tag Associations
  // ============================================================================

  /// Tags einer Notiz abrufen
  Future<List<TagData>> getTagsForNote(int noteId) async {
    final query = select(tagsTable).join([
      innerJoin(
        noteTagsTable,
        noteTagsTable.tagId.equalsExp(tagsTable.id),
      ),
    ])
      ..where(noteTagsTable.noteId.equals(noteId))
      ..orderBy([OrderingTerm.asc(tagsTable.name)]);

    final result = await query.get();
    return result.map((row) => row.readTable(tagsTable)).toList();
  }

  /// Tags einer Notiz beobachten
  Stream<List<TagData>> watchTagsForNote(int noteId) {
    final query = select(tagsTable).join([
      innerJoin(
        noteTagsTable,
        noteTagsTable.tagId.equalsExp(tagsTable.id),
      ),
    ])
      ..where(noteTagsTable.noteId.equals(noteId))
      ..orderBy([OrderingTerm.asc(tagsTable.name)]);

    return query.watch().map(
          (rows) => rows.map((row) => row.readTable(tagsTable)).toList(),
        );
  }

  /// Notizen nach Tag filtern
  Future<List<NoteData>> getNotesByTag(int tagId, {bool includeArchived = false}) async {
    final query = select(notesTable).join([
      innerJoin(
        noteTagsTable,
        noteTagsTable.noteId.equalsExp(notesTable.id),
      ),
    ])
      ..where(noteTagsTable.tagId.equals(tagId))
      ..orderBy([OrderingTerm.desc(notesTable.updatedAt)]);

    if (!includeArchived) {
      query.where(notesTable.isArchived.equals(false));
    }

    final result = await query.get();
    return result.map((row) => row.readTable(notesTable)).toList();
  }

  /// Notizen nach mehreren Tags filtern (AND-Verknüpfung)
  Future<List<NoteData>> getNotesByTags(List<int> tagIds, {bool includeArchived = false}) async {
    if (tagIds.isEmpty) {
      return getAllNotes(includeArchived: includeArchived);
    }

    // Finde alle Notizen, die alle ausgewählten Tags haben
    // Hierfür prüfen wir für jede Notiz, ob sie genau die Anzahl der gewünschten Tags hat
    final allNotes = await getAllNotes(includeArchived: includeArchived);
    final result = <NoteData>[];

    for (final note in allNotes) {
      // Hole Tags für diese Notiz
      final noteTags = await (select(noteTagsTable)
            ..where((t) => t.noteId.equals(note.id)))
          .get();

      final noteTagIds = noteTags.map((t) => t.tagId).toSet();

      // Prüfe ob alle gesuchten Tags vorhanden sind
      if (tagIds.every((id) => noteTagIds.contains(id))) {
        result.add(note);
      }
    }

    return result;
  }

  /// Tag zu Notiz hinzufügen
  Future<void> addTagToNote(int noteId, int tagId) async {
    await into(noteTagsTable).insert(
      NoteTagsTableCompanion.insert(
        noteId: noteId,
        tagId: tagId,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Tag von Notiz entfernen
  Future<void> removeTagFromNote(int noteId, int tagId) async {
    await (delete(noteTagsTable)
          ..where((t) => t.noteId.equals(noteId) & t.tagId.equals(tagId)))
        .go();
  }

  /// Alle Tags einer Notiz ersetzen
  Future<void> setTagsForNote(int noteId, List<int> tagIds) async {
    await transaction(() async {
      // Erst alle bestehenden Tags entfernen
      await (delete(noteTagsTable)..where((t) => t.noteId.equals(noteId))).go();

      // Dann neue Tags hinzufügen
      for (final tagId in tagIds) {
        await addTagToNote(noteId, tagId);
      }
    });
  }
}
