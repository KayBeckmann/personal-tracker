import 'package:injectable/injectable.dart';

import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

/// Use Case zum Aktualisieren eines Budgets
@lazySingleton
class UpdateBudget {
  UpdateBudget(this._repository);

  final BudgetRepository _repository;

  Future<void> call(Budget budget) => _repository.updateBudget(budget);
}
