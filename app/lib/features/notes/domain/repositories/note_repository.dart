import '../entities/note.dart';
import '../entities/tag.dart';

/// Repository-Interface für Notizen
abstract class NoteRepository {
  // ============================================================================
  // Notes
  // ============================================================================

  /// Alle Notizen abrufen
  Future<List<Note>> getAllNotes({bool includeArchived = false});

  /// Alle Notizen beobachten
  Stream<List<Note>> watchAllNotes({bool includeArchived = false});

  /// Notiz nach ID abrufen
  Future<Note?> getNoteById(int id);

  /// Notiz nach ID beobachten
  Stream<Note?> watchNoteById(int id);

  /// Notizen nach Freitext durchsuchen
  Future<List<Note>> searchNotes(String query, {bool includeArchived = false});

  /// Notiz erstellen
  Future<int> createNote({
    required String title,
    required String content,
    List<int> tagIds = const [],
    bool isArchived = false,
  });

  /// Notiz aktualisieren
  Future<void> updateNote(Note note);

  /// Notiz löschen
  Future<void> deleteNote(int id);

  /// Notiz archivieren/dearchivieren
  Future<void> toggleArchive(int id, bool isArchived);

  // ============================================================================
  // Tags
  // ============================================================================

  /// Alle Tags abrufen
  Future<List<Tag>> getAllTags();

  /// Alle Tags beobachten
  Stream<List<Tag>> watchAllTags();

  /// Tag nach ID abrufen
  Future<Tag?> getTagById(int id);

  /// Tag nach Name abrufen
  Future<Tag?> getTagByName(String name);

  /// Tag erstellen
  Future<int> createTag({
    required String name,
    String? color,
  });

  /// Tag aktualisieren
  Future<void> updateTag(Tag tag);

  /// Tag löschen
  Future<void> deleteTag(int id);

  // ============================================================================
  // Note-Tag Associations
  // ============================================================================

  /// Notizen nach Tag filtern
  Future<List<Note>> getNotesByTag(int tagId, {bool includeArchived = false});

  /// Notizen nach mehreren Tags filtern (AND-Verknüpfung)
  Future<List<Note>> getNotesByTags(List<int> tagIds, {bool includeArchived = false});

  /// Tag zu Notiz hinzufügen
  Future<void> addTagToNote(int noteId, int tagId);

  /// Tag von Notiz entfernen
  Future<void> removeTagFromNote(int noteId, int tagId);

  /// Alle Tags einer Notiz ersetzen
  Future<void> setTagsForNote(int noteId, List<int> tagIds);
}
