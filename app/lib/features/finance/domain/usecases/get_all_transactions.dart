import 'package:injectable/injectable.dart';

import '../../data/database/daos/transactions_dao.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use Case zum Abrufen aller Buchungen
@lazySingleton
class GetAllTransactions {
  GetAllTransactions(this._repository);

  final TransactionRepository _repository;

  Future<List<Transaction>> call({TransactionFilter? filter}) =>
      _repository.getAllTransactions(filter: filter);

  Stream<List<Transaction>> watch({TransactionFilter? filter}) =>
      _repository.watchAllTransactions(filter: filter);
}
