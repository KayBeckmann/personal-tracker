import 'package:drift/drift.dart';

/// Tabelle für App-weite Einstellungen
///
/// Speichert Key-Value Paare für Einstellungen wie:
/// - Theme-Modus (light/dark/system)
/// - Ausgewählte Sprache
/// - Aktivierte Module
/// - Sonstige Präferenzen
@DataClassName('AppSetting')
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  /// Eindeutiger Schlüssel für die Einstellung
  TextColumn get key => text()();

  /// Wert der Einstellung (als JSON String für komplexe Werte)
  TextColumn get value => text()();

  /// Wann wurde die Einstellung erstellt
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Wann wurde die Einstellung zuletzt geändert
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
