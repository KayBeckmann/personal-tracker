import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../tables/recurring_transactions_table.dart';
import '../tables/transactions_table.dart';

part 'recurring_transactions_dao.g.dart';

/// DAO für Daueraufträge
@DriftAccessor(tables: [RecurringTransactionsTable])
class RecurringTransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringTransactionsDaoMixin {
  RecurringTransactionsDao(super.db);

  /// Gibt alle Daueraufträge sortiert zurück
  Future<List<RecurringTransactionData>> getAllRecurringTransactions() {
    return (select(recurringTransactionsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.startDate, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Stream aller Daueraufträge
  Stream<List<RecurringTransactionData>> watchAllRecurringTransactions() {
    return (select(recurringTransactionsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.startDate, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Gibt aktive Daueraufträge zurück
  Future<List<RecurringTransactionData>> getActiveRecurringTransactions() {
    return (select(recurringTransactionsTable)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.dayOfMonth),
          ]))
        .get();
  }

  /// Stream aktiver Daueraufträge
  Stream<List<RecurringTransactionData>> watchActiveRecurringTransactions() {
    return (select(recurringTransactionsTable)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.dayOfMonth),
          ]))
        .watch();
  }

  /// Gibt fällige Daueraufträge zurück
  Future<List<RecurringTransactionData>> getDueRecurringTransactions(
      DateTime date) {
    return (select(recurringTransactionsTable)
          ..where((t) =>
              t.isActive.equals(true) &
              t.startDate.isSmallerOrEqualValue(date) &
              (t.endDate.isNull() | t.endDate.isBiggerOrEqualValue(date))))
        .get();
  }

  /// Gibt eine einzelne wiederkehrende Buchung zurück
  Future<RecurringTransactionData?> getRecurringTransactionById(int id) {
    return (select(recurringTransactionsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Stream einer einzelnen wiederkehrenden Buchung
  Stream<RecurringTransactionData?> watchRecurringTransactionById(int id) {
    return (select(recurringTransactionsTable)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Erstellt einen neuen Dauerauftrag
  Future<int> createRecurringTransaction(
      RecurringTransactionsTableCompanion entry) {
    return into(recurringTransactionsTable).insert(entry);
  }

  /// Aktualisiert einen Dauerauftrag
  Future<bool> updateRecurringTransaction(
      RecurringTransactionData transaction) {
    return update(recurringTransactionsTable).replace(transaction);
  }

  /// Löscht einen Dauerauftrag
  Future<int> deleteRecurringTransaction(int id) {
    return (delete(recurringTransactionsTable)..where((t) => t.id.equals(id)))
        .go();
  }

  /// Aktualisiert das lastExecuted Datum
  Future<void> markAsExecuted(int id, DateTime executedDate) async {
    final transaction = await getRecurringTransactionById(id);
    if (transaction != null) {
      await updateRecurringTransaction(
        transaction.copyWith(lastExecuted: Value(executedDate)),
      );
    }
  }

  /// Berechnet das nächste Fälligkeitsdatum
  DateTime? getNextDueDate(RecurringTransactionData transaction) {
    final now = DateTime.now();
    final lastExecuted = transaction.lastExecuted ?? transaction.startDate;

    DateTime nextDate;
    switch (transaction.interval) {
      case RecurrenceInterval.daily:
        nextDate = lastExecuted.add(const Duration(days: 1));
        break;
      case RecurrenceInterval.weekly:
        nextDate = lastExecuted.add(const Duration(days: 7));
        break;
      case RecurrenceInterval.biweekly:
        nextDate = lastExecuted.add(const Duration(days: 14));
        break;
      case RecurrenceInterval.monthly:
        nextDate = DateTime(
          lastExecuted.year,
          lastExecuted.month + 1,
          transaction.dayOfMonth,
        );
        break;
      case RecurrenceInterval.quarterly:
        nextDate = DateTime(
          lastExecuted.year,
          lastExecuted.month + 3,
          transaction.dayOfMonth,
        );
        break;
      case RecurrenceInterval.semiannually:
        nextDate = DateTime(
          lastExecuted.year,
          lastExecuted.month + 6,
          transaction.dayOfMonth,
        );
        break;
      case RecurrenceInterval.yearly:
        nextDate = DateTime(
          lastExecuted.year + 1,
          lastExecuted.month,
          transaction.dayOfMonth,
        );
        break;
    }

    // Prüfen ob noch aktiv
    if (transaction.endDate != null && nextDate.isAfter(transaction.endDate!)) {
      return null;
    }

    return nextDate;
  }
}
