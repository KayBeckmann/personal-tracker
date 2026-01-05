import 'package:injectable/injectable.dart';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use Case zum Abrufen aller Vorlagen
@lazySingleton
class GetTemplates {
  GetTemplates(this._repository);

  final TransactionRepository _repository;

  Future<List<Transaction>> call() => _repository.getTemplates();

  Stream<List<Transaction>> watch() => _repository.watchTemplates();
}
