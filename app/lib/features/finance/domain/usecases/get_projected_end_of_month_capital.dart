import 'package:injectable/injectable.dart';

import '../repositories/recurring_transaction_repository.dart';
import '../repositories/transaction_repository.dart';
import 'get_total_capital.dart';

/// Use Case zur Berechnung des voraussichtlichen Kapitals am Monatsende
///
/// Berücksichtigt:
/// - Aktuelles Gesamtkapital
/// - Geplante Buchungen bis Monatsende
/// - Fällige Daueraufträge bis Monatsende
@lazySingleton
class GetProjectedEndOfMonthCapital {
  GetProjectedEndOfMonthCapital(
    this._getTotalCapital,
    this._transactionRepository,
    this._recurringTransactionRepository,
  );

  final GetTotalCapital _getTotalCapital;
  final TransactionRepository _transactionRepository;
  final RecurringTransactionRepository _recurringTransactionRepository;

  /// Berechnet das voraussichtliche Kapital am Monatsende
  Future<double> call() async {
    // Aktuelles Kapital
    final currentCapital = await _getTotalCapital();

    // Monatsende berechnen
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Geplante Buchungen bis Monatsende
    final plannedTransactions =
        await _transactionRepository.getPlannedTransactions();
    final plannedSum = plannedTransactions
        .where((t) => t.date.isBefore(endOfMonth) || t.date.isAtSameMomentAs(endOfMonth))
        .fold<double>(0.0, (sum, t) {
      // Berücksichtige Transaktionstyp (Einnahme vs Ausgabe)
      switch (t.type.name) {
        case 'income':
          return sum + t.amount;
        case 'expense':
          return sum - t.amount;
        case 'transfer':
          return sum; // Transfers ändern Gesamtkapital nicht
        default:
          return sum;
      }
    });

    // Fällige Daueraufträge bis Monatsende
    final dueRecurring =
        await _recurringTransactionRepository.getDueRecurringTransactions(
      endOfMonth,
    );
    final recurringSum = dueRecurring.fold<double>(0.0, (sum, r) {
      // Berechne wie viele Ausführungen noch ausstehen
      final lastExecuted = r.lastExecuted ?? r.startDate;
      var nextDue = _recurringTransactionRepository.getNextDueDate(r);
      var count = 0.0;

      while (nextDue != null &&
          !nextDue.isAfter(endOfMonth) &&
          nextDue.isAfter(lastExecuted)) {
        count++;
        // Simuliere Ausführung für nächste Berechnung
        final tempR = r.copyWith(lastExecuted: nextDue);
        nextDue = _recurringTransactionRepository.getNextDueDate(tempR);
      }

      // Berücksichtige Transaktionstyp
      switch (r.type.name) {
        case 'income':
          return sum + (r.amount * count);
        case 'expense':
          return sum - (r.amount * count);
        case 'transfer':
          return sum; // Transfers ändern Gesamtkapital nicht
        default:
          return sum;
      }
    });

    return currentCapital + plannedSum + recurringSum;
  }
}
