import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';
import 'transactions_table.dart';

/// Intervall für wiederkehrende Buchungen
enum RecurrenceInterval {
  /// Täglich
  daily,

  /// Wöchentlich
  weekly,

  /// Zweiwöchentlich
  biweekly,

  /// Monatlich
  monthly,

  /// Vierteljährlich
  quarterly,

  /// Halbjährlich
  semiannually,

  /// Jährlich
  yearly,
}

/// Tabelle für Daueraufträge
///
/// Speichert wiederkehrende Buchungen, die automatisch erstellt werden sollen.
@DataClassName('RecurringTransactionData')
class RecurringTransactionsTable extends Table {
  @override
  String get tableName => 'recurring_transactions';

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

  /// Empfänger/Zahlungsempfänger
  TextColumn get payee => text().withLength(max: 200).nullable()();

  /// Beschreibung/Notiz zur Buchung
  TextColumn get description => text().nullable()();

  /// Intervall der Wiederholung
  IntColumn get interval => intEnum<RecurrenceInterval>()();

  /// Tag im Monat, an dem die Buchung erstellt werden soll (1-31)
  IntColumn get dayOfMonth => integer()();

  /// Startdatum des Dauerauftrags
  DateTimeColumn get startDate => dateTime()();

  /// Enddatum des Dauerauftrags (null = unbegrenzt)
  DateTimeColumn get endDate => dateTime().nullable()();

  /// Datum der letzten automatischen Erstellung
  DateTimeColumn get lastExecuted => dateTime().nullable()();

  /// Ob der Dauerauftrag aktiv ist
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Zeitstempel der Erstellung
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Zeitstempel der letzten Änderung
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
