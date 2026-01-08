import 'package:drift/drift.dart';

/// Tabelle für Notizen
@DataClassName('NoteData')
class NotesTable extends Table {
  @override
  String get tableName => 'notes';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get content => text()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
