import 'package:injectable/injectable.dart';

import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

/// Use Case zum Abrufen aller Budgets
@lazySingleton
class GetAllBudgets {
  GetAllBudgets(this._repository);

  final BudgetRepository _repository;

  Future<List<Budget>> call() => _repository.getAllBudgets();

  Stream<List<Budget>> watch() => _repository.watchAllBudgets();
}
