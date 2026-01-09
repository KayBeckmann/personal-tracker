import 'package:drift/drift.dart';

import '../../../../notes/data/database/tables/notes_table.dart';

/// Status einer Aufgabe
enum TaskStatus {
  open,
  inProgress,
  completed,
}

/// Priorität einer Aufgabe
enum TaskPriority {
  low,
  medium,
  high,
}

/// Tabelle für Aufgaben
@DataClassName('TaskData')
class TasksTable extends Table {
  @override
  String get tableName => 'tasks';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().withDefault(const Constant(''))();

  IntColumn get status => intEnum<TaskStatus>().withDefault(const Constant(0))();
  IntColumn get priority => intEnum<TaskPriority>().withDefault(const Constant(1))();

  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  // Verknüpfung zu einer Notiz (optional)
  IntColumn get noteId => integer().nullable().references(NotesTable, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
