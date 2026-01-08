import 'package:drift/drift.dart';

import 'notes_table.dart';
import 'tags_table.dart';

/// Verknüpfungstabelle für Notizen und Tags (Many-to-Many)
@DataClassName('NoteTagData')
class NoteTagsTable extends Table {
  @override
  String get tableName => 'note_tags';

  IntColumn get noteId => integer().references(NotesTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId => integer().references(TagsTable, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}
