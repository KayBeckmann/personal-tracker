import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';

/// Zeitraum für Budgets
enum BudgetPeriod {
  /// Wöchentlich
  weekly,

  /// Monatlich
  monthly,

  /// Vierteljährlich
  quarterly,

  /// Jährlich
  yearly,
}

/// Tabelle für Budgets
///
/// Speichert Budgets für Kategorien oder Konten zur Ausgabekontrolle.
@DataClassName('BudgetData')
class BudgetsTable extends Table {
  @override
  String get tableName => 'budgets';

  /// Primärschlüssel
  IntColumn get id => integer().autoIncrement()();

  /// Name des Budgets
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Fremdschlüssel zur Kategorie (null = über alle Kategorien)
  IntColumn get categoryId =>
      integer().nullable().references(CategoriesTable, #id)();

  /// Fremdschlüssel zum Konto (null = über alle Konten)
  IntColumn get accountId =>
      integer().nullable().references(AccountsTable, #id)();

  /// Budget-Betrag (SOLL)
  RealColumn get amount => real()();

  /// Währung (z.B. "EUR", "USD")
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('EUR'))();

  /// Zeitraum des Budgets
  IntColumn get period => intEnum<BudgetPeriod>()();

  /// Startdatum des Budgets
  DateTimeColumn get startDate => dateTime()();

  /// Enddatum des Budgets (null = unbegrenzt)
  DateTimeColumn get endDate => dateTime().nullable()();

  /// Ob das Budget aktiv ist
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Zeitstempel der Erstellung
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Zeitstempel der letzten Änderung
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
