import 'package:injectable/injectable.dart';

import '../entities/recurring_transaction.dart';
import '../repositories/recurring_transaction_repository.dart';

/// Use Case zum Abrufen anstehender Daueraufträge
///
/// Gibt aktive Daueraufträge sortiert nach nächstem Fälligkeitsdatum zurück
@lazySingleton
class GetUpcomingRecurringTransactions {
  GetUpcomingRecurringTransactions(this._repository);

  final RecurringTransactionRepository _repository;

  /// Gibt anstehende Daueraufträge zurück
  ///
  /// [limit] - Maximale Anzahl zurückzugebender Daueraufträge
  Future<List<RecurringTransactionWithNextDate>> call({int limit = 5}) async {
    final active = await _repository.getActiveRecurringTransactions();

    // Berechne nächstes Fälligkeitsdatum für jeden Dauerauftrag
    final withDates = active
        .map((recurring) {
          final nextDate = _repository.getNextDueDate(recurring);
          if (nextDate == null) return null;
          return RecurringTransactionWithNextDate(
            recurring: recurring,
            nextDueDate: nextDate,
          );
        })
        .whereType<RecurringTransactionWithNextDate>()
        .toList();

    // Sortiere nach Fälligkeitsdatum
    withDates.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

    // Begrenze Anzahl
    return withDates.take(limit).toList();
  }

  /// Stream anstehender Daueraufträge
  Stream<List<RecurringTransactionWithNextDate>> watch({int limit = 5}) {
    return _repository.watchActiveRecurringTransactions().map((active) {
      final withDates = active
          .map((recurring) {
            final nextDate = _repository.getNextDueDate(recurring);
            if (nextDate == null) return null;
            return RecurringTransactionWithNextDate(
              recurring: recurring,
              nextDueDate: nextDate,
            );
          })
          .whereType<RecurringTransactionWithNextDate>()
          .toList();

      withDates.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      return withDates.take(limit).toList();
    });
  }
}

/// Hilfsklasse für Dauerauftrag mit berechnetem Fälligkeitsdatum
class RecurringTransactionWithNextDate {
  const RecurringTransactionWithNextDate({
    required this.recurring,
    required this.nextDueDate,
  });

  final RecurringTransaction recurring;
  final DateTime nextDueDate;
}
