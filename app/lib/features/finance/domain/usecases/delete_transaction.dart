import 'package:injectable/injectable.dart';

import '../repositories/transaction_repository.dart';

/// Use Case zum Löschen einer Buchung
@lazySingleton
class DeleteTransaction {
  DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(int id) => _repository.deleteTransaction(id);
}
