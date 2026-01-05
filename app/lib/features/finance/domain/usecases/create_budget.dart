import 'package:injectable/injectable.dart';

import '../../data/database/tables/budgets_table.dart';
import '../repositories/budget_repository.dart';

/// Use Case zum Erstellen eines Budgets
@lazySingleton
class CreateBudget {
  CreateBudget(this._repository);

  final BudgetRepository _repository;

  Future<int> call({
    required String name,
    int? categoryId,
    int? accountId,
    required double amount,
    String currency = 'EUR',
    required BudgetPeriod period,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive = true,
  }) =>
      _repository.createBudget(
        name: name,
        categoryId: categoryId,
        accountId: accountId,
        amount: amount,
        currency: currency,
        period: period,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
      );
}
