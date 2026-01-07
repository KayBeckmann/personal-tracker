import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../database/daos/budgets_dao.dart';
import '../database/tables/budgets_table.dart';
import '../mappers/budget_mapper.dart';

/// Implementierung des Budget-Repositories
@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Budget>> getAllBudgets() async {
    final budgets = await _db.budgetsDao.getAllBudgets();
    final result = <Budget>[];

    for (final budgetData in budgets) {
      final actualSpending = await _db.budgetsDao.getActualSpending(budgetData);
      result.add(BudgetMapper.toEntity(budgetData, actualSpending: actualSpending));
    }

    return result;
  }

  @override
  Stream<List<Budget>> watchAllBudgets() {
    // Kombiniere Streams von Budgets UND Transactions, damit Updates in beiden Tabellen getriggert werden
    final controller = StreamController<List<Budget>>();

    StreamSubscription? budgetSub;
    StreamSubscription? transactionSub;

    List<BudgetData>? latestBudgets;

    Future<void> updateBudgets() async {
      if (latestBudgets == null) return;

      final result = <Budget>[];
      for (final budgetData in latestBudgets!) {
        final actualSpending = await _db.budgetsDao.getActualSpending(budgetData);
        result.add(
          BudgetMapper.toEntity(budgetData, actualSpending: actualSpending),
        );
      }

      if (!controller.isClosed) {
        controller.add(result);
      }
    }

    budgetSub = _db.budgetsDao.watchAllBudgets().listen((budgets) {
      latestBudgets = budgets;
      updateBudgets();
    });

    transactionSub = _db.transactionsDao.watchAllTransactions().listen((_) {
      updateBudgets();
    });

    controller.onCancel = () {
      budgetSub?.cancel();
      transactionSub?.cancel();
    };

    return controller.stream;
  }

  @override
  Future<Budget?> getBudgetById(int id) async {
    final budgetData = await _db.budgetsDao.getBudgetById(id);
    if (budgetData == null) return null;

    final actualSpending = await _db.budgetsDao.getActualSpending(budgetData);
    return BudgetMapper.toEntity(budgetData, actualSpending: actualSpending);
  }

  @override
  Stream<Budget?> watchBudgetById(int id) {
    return _db.budgetsDao.watchBudgetById(id).asyncMap((budgetData) async {
      if (budgetData == null) return null;

      final actualSpending = await _db.budgetsDao.getActualSpending(budgetData);
      return BudgetMapper.toEntity(budgetData, actualSpending: actualSpending);
    });
  }

  @override
  Future<int> createBudget({
    required String name,
    int? categoryId,
    int? accountId,
    required double amount,
    String currency = 'EUR',
    required BudgetPeriod period,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive = true,
  }) {
    return _db.budgetsDao.createBudget(
      BudgetsTableCompanion.insert(
        name: name,
        categoryId: Value(categoryId),
        accountId: Value(accountId),
        amount: amount,
        currency: Value(currency),
        period: period,
        startDate: startDate,
        endDate: Value(endDate),
        isActive: Value(isActive),
      ),
    );
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final budgetData = BudgetMapper.toData(budget);
    await _db.budgetsDao.updateBudget(budgetData);
  }

  @override
  Future<void> deleteBudget(int id) async {
    await _db.budgetsDao.deleteBudget(id);
  }
}
