import 'package:drift/drift.dart';

/// Tabelle für Tags
@DataClassName('TagData')
class TagsTable extends Table {
  @override
  String get tableName => 'tags';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50).unique()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
