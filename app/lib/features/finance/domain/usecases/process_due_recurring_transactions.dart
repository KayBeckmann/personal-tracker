import 'package:injectable/injectable.dart';

import '../repositories/recurring_transaction_repository.dart';
import '../repositories/transaction_repository.dart';

/// Use Case zum Verarbeiten fälliger Daueraufträge
///
/// Findet alle fälligen Daueraufträge und erstellt automatisch
/// die entsprechenden Buchungen.
@lazySingleton
class ProcessDueRecurringTransactions {
  ProcessDueRecurringTransactions(
    this._recurringTransactionRepository,
    this._transactionRepository,
  );

  final RecurringTransactionRepository _recurringTransactionRepository;
  final TransactionRepository _transactionRepository;

  /// Verarbeitet alle fälligen Daueraufträge bis zum angegebenen Datum
  ///
  /// Returns: Anzahl der erstellten Buchungen
  Future<int> call({DateTime? upToDate}) async {
    final targetDate = upToDate ?? DateTime.now();
    int createdCount = 0;

    // Hole alle fälligen Daueraufträge
    final dueTransactions =
        await _recurringTransactionRepository.getDueRecurringTransactions(
      targetDate,
    );

    for (final recurring in dueTransactions) {
      // Berechne, welche Buchungen erstellt werden müssen
      final lastExecuted = recurring.lastExecuted ?? recurring.startDate;
      DateTime? nextDue =
          _recurringTransactionRepository.getNextDueDate(recurring);

      // Erstelle Buchungen für alle fälligen Zeiträume
      while (nextDue != null &&
          !nextDue.isAfter(targetDate) &&
          nextDue.isAfter(lastExecuted)) {
        // Erstelle die Buchung
        await _transactionRepository.createTransaction(
          type: recurring.type,
          accountId: recurring.accountId,
          toAccountId: recurring.toAccountId,
          categoryId: recurring.categoryId,
          amount: recurring.amount,
          currency: recurring.currency,
          date: nextDue,
          payee: recurring.payee,
          description: recurring.description != null
              ? '${recurring.description} (Dauerauftrag)'
              : 'Dauerauftrag',
          isBooked: true,
        );

        createdCount++;

        // Markiere als ausgeführt
        await _recurringTransactionRepository.markAsExecuted(
          recurring.id,
          nextDue,
        );

        // Berechne das nächste Fälligkeitsdatum
        // Wichtig: Hole den aktualisierten Dauerauftrag nach markAsExecuted
        final updated =
            await _recurringTransactionRepository.getRecurringTransactionById(
          recurring.id,
        );
        if (updated == null) break;

        nextDue = _recurringTransactionRepository.getNextDueDate(updated);
      }
    }

    return createdCount;
  }
}
