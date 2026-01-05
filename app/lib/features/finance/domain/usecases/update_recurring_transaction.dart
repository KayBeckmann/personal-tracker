import 'package:injectable/injectable.dart';

import '../entities/recurring_transaction.dart';
import '../repositories/recurring_transaction_repository.dart';

/// Use Case zum Aktualisieren eines Dauerauftrags
@lazySingleton
class UpdateRecurringTransaction {
  UpdateRecurringTransaction(this._repository);

  final RecurringTransactionRepository _repository;

  Future<void> call(RecurringTransaction transaction) =>
      _repository.updateRecurringTransaction(transaction);
}
