import '../../data/database/tables/recurring_transactions_table.dart';
import '../../data/database/tables/transactions_table.dart';
import '../entities/recurring_transaction.dart';

/// Repository-Interface für Daueraufträge
abstract class RecurringTransactionRepository {
  /// Gibt alle Daueraufträge zurück
  Future<List<RecurringTransaction>> getAllRecurringTransactions();

  /// Stream aller Daueraufträge
  Stream<List<RecurringTransaction>> watchAllRecurringTransactions();

  /// Gibt aktive Daueraufträge zurück
  Future<List<RecurringTransaction>> getActiveRecurringTransactions();

  /// Stream aktiver Daueraufträge
  Stream<List<RecurringTransaction>> watchActiveRecurringTransactions();

  /// Gibt fällige Daueraufträge zurück
  Future<List<RecurringTransaction>> getDueRecurringTransactions(DateTime date);

  /// Gibt einen einzelnen Dauerauftrag zurück
  Future<RecurringTransaction?> getRecurringTransactionById(int id);

  /// Stream eines einzelnen Dauerauftrags
  Stream<RecurringTransaction?> watchRecurringTransactionById(int id);

  /// Erstellt einen neuen Dauerauftrag
  Future<int> createRecurringTransaction({
    required TransactionType type,
    required int accountId,
    int? toAccountId,
    int? categoryId,
    required double amount,
    String currency = 'EUR',
    String? payee,
    String? description,
    required RecurrenceInterval interval,
    required int dayOfMonth,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive = true,
  });

  /// Aktualisiert einen Dauerauftrag
  Future<void> updateRecurringTransaction(RecurringTransaction transaction);

  /// Löscht einen Dauerauftrag
  Future<void> deleteRecurringTransaction(int id);

  /// Markiert einen Dauerauftrag als ausgeführt
  Future<void> markAsExecuted(int id, DateTime executedDate);

  /// Berechnet das nächste Fälligkeitsdatum
  DateTime? getNextDueDate(RecurringTransaction transaction);
}
