import '../../../../core/database/app_database.dart';
import '../../domain/entities/budget.dart';

/// Mapper für Budget-Entity <-> BudgetData
class BudgetMapper {
  /// Konvertiert BudgetData zu Budget-Entity
  static Budget toEntity(BudgetData data, {double actualSpending = 0.0}) {
    return Budget(
      id: data.id,
      name: data.name,
      categoryId: data.categoryId,
      accountId: data.accountId,
      amount: data.amount,
      currency: data.currency,
      period: data.period,
      startDate: data.startDate,
      endDate: data.endDate,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      actualSpending: actualSpending,
    );
  }

  /// Konvertiert Budget-Entity zu BudgetData
  static BudgetData toData(Budget entity) {
    return BudgetData(
      id: entity.id,
      name: entity.name,
      categoryId: entity.categoryId,
      accountId: entity.accountId,
      amount: entity.amount,
      currency: entity.currency,
      period: entity.period,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
