import 'package:injectable/injectable.dart';

import '../usecases/process_due_recurring_transactions.dart';

/// Service zum automatischen Verarbeiten fälliger Daueraufträge
///
/// Dieser Service sollte beim App-Start ausgeführt werden, um
/// alle fälligen Daueraufträge in tatsächliche Buchungen umzuwandeln.
@lazySingleton
class RecurringTransactionScheduler {
  RecurringTransactionScheduler(this._processDueRecurringTransactions);

  final ProcessDueRecurringTransactions _processDueRecurringTransactions;

  /// Initialisiert den Scheduler und verarbeitet fällige Daueraufträge
  ///
  /// Diese Methode sollte beim App-Start aufgerufen werden.
  Future<void> initialize() async {
    await processNow();
  }

  /// Verarbeitet sofort alle fälligen Daueraufträge
  ///
  /// Returns: Anzahl der erstellten Buchungen
  Future<int> processNow() async {
    try {
      final count = await _processDueRecurringTransactions();
      if (count > 0) {
        print(
            'RecurringTransactionScheduler: $count Buchungen aus Daueraufträgen erstellt');
      }
      return count;
    } catch (e) {
      print('RecurringTransactionScheduler: Fehler beim Verarbeiten: $e');
      return 0;
    }
  }
}
