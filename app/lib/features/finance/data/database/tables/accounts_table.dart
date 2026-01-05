import 'package:drift/drift.dart';

import 'account_types_table.dart';

/// Tabelle für Konten
///
/// Speichert alle Finanzkonten des Nutzers (Bankkonten, Bargeld, Depots, etc.).
@DataClassName('AccountData')
class AccountsTable extends Table {
  @override
  String get tableName => 'accounts';

  /// Primärschlüssel
  IntColumn get id => integer().autoIncrement()();

  /// Fremdschlüssel zum Kontotyp
  IntColumn get accountTypeId =>
      integer().references(AccountTypesTable, #id)();

  /// Name des Kontos (z.B. "Hauptkonto", "Sparkasse", "Bargeld")
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Währung (z.B. "EUR", "USD")
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('EUR'))();

  /// Anfangssaldo beim Erstellen des Kontos
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))();

  /// Ob dieses Konto in der Finanzübersicht berücksichtigt werden soll
  BoolColumn get includeInOverview =>
      boolean().withDefault(const Constant(true))();

  /// Ob dies das Standard-Konto ist (für neue Buchungen)
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Farbe des Kontos (Hex-String, z.B. "#FF5733")
  TextColumn get color =>
      text().withLength(min: 7, max: 7).nullable()();

  /// Notizen zum Konto
  TextColumn get notes => text().nullable()();

  /// Sortierreihenfolge
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Zeitstempel der Erstellung
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Zeitstempel der letzten Änderung
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
