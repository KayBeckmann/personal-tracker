import 'package:drift/drift.dart';

/// Tabelle für Kontotypen
///
/// Speichert verschiedene Typen von Konten (z.B. Bargeld, Bankkonto, Depot).
/// Der Nutzer kann eigene Typen erstellen und bearbeiten.
@DataClassName('AccountTypeData')
class AccountTypesTable extends Table {
  @override
  String get tableName => 'account_types';

  /// Primärschlüssel
  IntColumn get id => integer().autoIncrement()();

  /// Name des Kontotyps (z.B. "Bargeld", "Bankkonto", "Depot")
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Icon-Name aus Material Icons
  TextColumn get icon => text().withLength(min: 1, max: 50)();

  /// Sortierreihenfolge
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Ob dies ein Standard-Typ ist (kann nicht gelöscht werden)
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Zeitstempel der Erstellung
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Zeitstempel der letzten Änderung
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
