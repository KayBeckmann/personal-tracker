import 'package:injectable/injectable.dart';

import '../entities/recurring_transaction.dart';
import '../repositories/recurring_transaction_repository.dart';

/// Use Case zum Abrufen aller Daueraufträge
@lazySingleton
class GetAllRecurringTransactions {
  GetAllRecurringTransactions(this._repository);

  final RecurringTransactionRepository _repository;

  Future<List<RecurringTransaction>> call() =>
      _repository.getAllRecurringTransactions();

  Stream<List<RecurringTransaction>> watch() =>
      _repository.watchAllRecurringTransactions();
}
