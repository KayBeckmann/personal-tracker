import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';

/// Typ der Buchung
enum TransactionType {
  /// Einnahme
  income,

  /// Ausgabe
  expense,

  /// Umbuchung zwischen Konten
  transfer,
}

/// Tabelle für Buchungen
///
/// Speichert alle Finanzbuchungen (Einnahmen, Ausgaben, Umbuchungen).
/// Kann als Vorlage markiert oder als geplante Buchung angelegt werden.
@DataClassName('TransactionData')
class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';

  /// Primärschlüssel
  IntColumn get id => integer().autoIncrement()();

  /// Typ der Buchung (income, expense, transfer)
  IntColumn get type => intEnum<TransactionType>()();

  /// Fremdschlüssel zum Quell-Konto
  IntColumn get accountId => integer().references(AccountsTable, #id)();

  /// Fremdschlüssel zum Ziel-Konto (nur bei Umbuchungen)
  IntColumn get toAccountId =>
      integer().nullable().references(AccountsTable, #id)();

  /// Fremdschlüssel zur Kategorie
  IntColumn get categoryId =>
      integer().nullable().references(CategoriesTable, #id)();

  /// Betrag der Buchung
  RealColumn get amount => real()();

  /// Währung (z.B. "EUR", "USD")
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('EUR'))();

  /// Buchungsdatum
  DateTimeColumn get date => dateTime()();

  /// Empfänger/Zahlungsempfänger
  TextColumn get payee => text().withLength(max: 200).nullable()();

  /// Beschreibung/Notiz zur Buchung
  TextColumn get description => text().nullable()();

  /// Ob dies eine geplante/zukünftige Buchung ist
  BoolColumn get isPlanned => boolean().withDefault(const Constant(false))();

  /// Ob dies eine Vorlage ist
  BoolColumn get isTemplate => boolean().withDefault(const Constant(false))();

  /// Name der Vorlage (nur wenn isTemplate = true)
  TextColumn get templateName => text().withLength(max: 100).nullable()();

  /// Ob diese Buchung bereits gebucht wurde (für geplante Buchungen)
  BoolColumn get isBooked => boolean().withDefault(const Constant(true))();

  /// Fremdschlüssel zum Dauerauftrag (wenn aus Dauerauftrag erstellt)
  IntColumn get recurringTransactionId => integer().nullable()();

  /// Zeitstempel der Erstellung
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Zeitstempel der letzten Änderung
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
