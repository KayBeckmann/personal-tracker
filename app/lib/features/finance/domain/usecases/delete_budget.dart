import 'package:injectable/injectable.dart';

import '../repositories/budget_repository.dart';

/// Use Case zum Löschen eines Budgets
@lazySingleton
class DeleteBudget {
  DeleteBudget(this._repository);

  final BudgetRepository _repository;

  Future<void> call(int id) => _repository.deleteBudget(id);
}
