import 'package:injectable/injectable.dart';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use Case zum Aktualisieren einer Buchung
@lazySingleton
class UpdateTransaction {
  UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(Transaction transaction) =>
      _repository.updateTransaction(transaction);
}
