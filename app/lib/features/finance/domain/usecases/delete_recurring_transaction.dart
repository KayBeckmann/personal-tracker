import 'package:injectable/injectable.dart';

import '../repositories/recurring_transaction_repository.dart';

/// Use Case zum Löschen eines Dauerauftrags
@lazySingleton
class DeleteRecurringTransaction {
  DeleteRecurringTransaction(this._repository);

  final RecurringTransactionRepository _repository;

  Future<void> call(int id) => _repository.deleteRecurringTransaction(id);
}
