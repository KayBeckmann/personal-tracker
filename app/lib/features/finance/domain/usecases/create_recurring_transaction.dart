import 'package:injectable/injectable.dart';

import '../../data/database/tables/recurring_transactions_table.dart';
import '../../data/database/tables/transactions_table.dart';
import '../repositories/recurring_transaction_repository.dart';

/// Use Case zum Erstellen eines Dauerauftrags
@lazySingleton
class CreateRecurringTransaction {
  CreateRecurringTransaction(this._repository);

  final RecurringTransactionRepository _repository;

  Future<int> call({
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
  }) =>
      _repository.createRecurringTransaction(
        type: type,
        accountId: accountId,
        toAccountId: toAccountId,
        categoryId: categoryId,
        amount: amount,
        currency: currency,
        payee: payee,
        description: description,
        interval: interval,
        dayOfMonth: dayOfMonth,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
      );
}
