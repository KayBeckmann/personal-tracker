import 'package:injectable/injectable.dart';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use Case zum Abrufen aller geplanten Buchungen
@lazySingleton
class GetPlannedTransactions {
  GetPlannedTransactions(this._repository);

  final TransactionRepository _repository;

  Future<List<Transaction>> call() => _repository.getPlannedTransactions();

  Stream<List<Transaction>> watch() => _repository.watchPlannedTransactions();
}
