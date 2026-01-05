import '../../data/database/tables/budgets_table.dart';
import '../entities/budget.dart';

/// Repository-Interface für Budgets
abstract class BudgetRepository {
  /// Gibt alle Budgets zurück
  Future<List<Budget>> getAllBudgets();

  /// Stream aller Budgets
  Stream<List<Budget>> watchAllBudgets();

  /// Gibt ein Budget anhand der ID zurück
  Future<Budget?> getBudgetById(int id);

  /// Stream eines Budgets anhand der ID
  Stream<Budget?> watchBudgetById(int id);

  /// Erstellt ein neues Budget
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
  });

  /// Aktualisiert ein Budget
  Future<void> updateBudget(Budget budget);

  /// Löscht ein Budget
  Future<void> deleteBudget(int id);
}
