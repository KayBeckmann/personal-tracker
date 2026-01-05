import 'package:injectable/injectable.dart';

import '../../data/database/tables/transactions_table.dart';
import '../repositories/transaction_repository.dart';

/// Use Case zum Erstellen einer Buchung
@lazySingleton
class CreateTransaction {
  CreateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<int> call({
    required TransactionType type,
    required int accountId,
    int? toAccountId,
    int? categoryId,
    required double amount,
    String currency = 'EUR',
    required DateTime date,
    String? payee,
    String? description,
    bool isPlanned = false,
    bool isTemplate = false,
    String? templateName,
    bool isBooked = true,
  }) =>
      _repository.createTransaction(
        type: type,
        accountId: accountId,
        toAccountId: toAccountId,
        categoryId: categoryId,
        amount: amount,
        currency: currency,
        date: date,
        payee: payee,
        description: description,
        isPlanned: isPlanned,
        isTemplate: isTemplate,
        templateName: templateName,
        isBooked: isBooked,
      );
}
