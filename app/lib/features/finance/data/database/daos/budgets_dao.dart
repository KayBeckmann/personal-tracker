import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../tables/budgets_table.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

part 'budgets_dao.g.dart';

/// DAO für Budgets
@DriftAccessor(tables: [BudgetsTable, TransactionsTable, CategoriesTable])
class BudgetsDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  /// Gibt alle Budgets zurück
  Future<List<BudgetData>> getAllBudgets() => select(budgetsTable).get();

  /// Stream aller Budgets
  Stream<List<BudgetData>> watchAllBudgets() => select(budgetsTable).watch();

  /// Gibt ein Budget anhand der ID zurück
  Future<BudgetData?> getBudgetById(int id) =>
      (select(budgetsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Stream eines Budgets anhand der ID
  Stream<BudgetData?> watchBudgetById(int id) =>
      (select(budgetsTable)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Erstellt ein neues Budget
  Future<int> createBudget(BudgetsTableCompanion budget) =>
      into(budgetsTable).insert(budget);

  /// Aktualisiert ein Budget
  Future<bool> updateBudget(BudgetData budget) =>
      update(budgetsTable).replace(budget);

  /// Löscht ein Budget
  Future<int> deleteBudget(int id) =>
      (delete(budgetsTable)..where((t) => t.id.equals(id))).go();

  /// Berechnet die IST-Ausgaben für ein Budget im aktuellen Zeitraum
  ///
  /// Summiert alle Ausgaben-Buchungen die:
  /// - zur Kategorie gehören (falls categoryId gesetzt)
  /// - zum Konto gehören (falls accountId gesetzt)
  /// - im aktuellen Budgetzeitraum liegen
  Future<double> getActualSpending(BudgetData budget) async {
    final now = DateTime.now();
    final periodDates = _calculatePeriodDates(budget, now);

    // Basis-Query für Transaktionen im Zeitraum
    var query = select(transactionsTable).join([]);

    // Filter: Nur Ausgaben
    query = query..where(transactionsTable.type.equalsValue(TransactionType.expense));

    // Filter: Zeitraum
    query = query
      ..where(transactionsTable.date.isBiggerOrEqualValue(periodDates.$1))
      ..where(transactionsTable.date.isSmallerOrEqualValue(periodDates.$2));

    // Filter: Kategorie (falls gesetzt)
    if (budget.categoryId != null) {
      query = query..where(transactionsTable.categoryId.equals(budget.categoryId!));
    }

    // Filter: Konto (falls gesetzt)
    if (budget.accountId != null) {
      query = query..where(transactionsTable.accountId.equals(budget.accountId!));
    }

    final results = await query.get();

    // Summiere Beträge
    double total = 0;
    for (final result in results) {
      final transaction = result.readTable(transactionsTable);
      total += transaction.amount;
    }

    return total;
  }

  /// Berechnet Start- und Enddatum für den aktuellen Budgetzeitraum
  ///
  /// Gibt ein Tuple (startDate, endDate) zurück
  (DateTime, DateTime) _calculatePeriodDates(BudgetData budget, DateTime now) {
    // Falls Budget ein Enddatum hat und dieses überschritten ist,
    // verwende das Enddatum als obere Grenze
    if (budget.endDate != null && now.isAfter(budget.endDate!)) {
      now = budget.endDate!;
    }

    // Berechne Start- und Enddatum basierend auf Periode
    DateTime periodStart;
    DateTime periodEnd;

    switch (budget.period) {
      case BudgetPeriod.weekly:
        // Aktuelle Woche (Montag bis Sonntag)
        final weekday = now.weekday;
        periodStart = DateTime(now.year, now.month, now.day - weekday + 1);
        periodEnd = DateTime(now.year, now.month, now.day + (7 - weekday));
        break;

      case BudgetPeriod.monthly:
        // Aktueller Monat
        periodStart = DateTime(now.year, now.month, 1);
        periodEnd = DateTime(now.year, now.month + 1, 0); // Letzter Tag des Monats
        break;

      case BudgetPeriod.quarterly:
        // Aktuelles Quartal
        final quarter = ((now.month - 1) / 3).floor();
        periodStart = DateTime(now.year, quarter * 3 + 1, 1);
        periodEnd = DateTime(now.year, (quarter + 1) * 3 + 1, 0);
        break;

      case BudgetPeriod.yearly:
        // Aktuelles Jahr
        periodStart = DateTime(now.year, 1, 1);
        periodEnd = DateTime(now.year, 12, 31);
        break;
    }

    // Sicherstellen, dass periodStart nicht vor Budget-Start liegt
    if (periodStart.isBefore(budget.startDate)) {
      periodStart = budget.startDate;
    }

    // Sicherstellen, dass periodEnd nicht nach Budget-Ende liegt
    if (budget.endDate != null && periodEnd.isAfter(budget.endDate!)) {
      periodEnd = budget.endDate!;
    }

    return (periodStart, periodEnd);
  }
}
