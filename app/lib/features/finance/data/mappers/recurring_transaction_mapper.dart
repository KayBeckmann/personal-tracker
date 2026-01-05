import '../../../../core/database/app_database.dart';
import '../../domain/entities/recurring_transaction.dart' as domain;

/// Mapper zwischen RecurringTransactionData (Data Layer) und RecurringTransaction (Domain Layer)
class RecurringTransactionMapper {
  /// Konvertiert RecurringTransactionData zu RecurringTransaction
  static domain.RecurringTransaction toEntity(RecurringTransactionData data) {
    return domain.RecurringTransaction(
      id: data.id,
      type: data.type,
      accountId: data.accountId,
      toAccountId: data.toAccountId,
      categoryId: data.categoryId,
      amount: data.amount,
      currency: data.currency,
      payee: data.payee,
      description: data.description,
      interval: data.interval,
      dayOfMonth: data.dayOfMonth,
      startDate: data.startDate,
      endDate: data.endDate,
      lastExecuted: data.lastExecuted,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Konvertiert RecurringTransaction zu RecurringTransactionData
  static RecurringTransactionData toData(domain.RecurringTransaction entity) {
    return RecurringTransactionData(
      id: entity.id,
      type: entity.type,
      accountId: entity.accountId,
      toAccountId: entity.toAccountId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      currency: entity.currency,
      payee: entity.payee,
      description: entity.description,
      interval: entity.interval,
      dayOfMonth: entity.dayOfMonth,
      startDate: entity.startDate,
      endDate: entity.endDate,
      lastExecuted: entity.lastExecuted,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Konvertiert eine Liste von RecurringTransactionData zu RecurringTransaction
  static List<domain.RecurringTransaction> toEntityList(
      List<RecurringTransactionData> dataList) {
    return dataList.map(toEntity).toList();
  }

  /// Konvertiert eine Liste von RecurringTransaction zu RecurringTransactionData
  static List<RecurringTransactionData> toDataList(
      List<domain.RecurringTransaction> entityList) {
    return entityList.map(toData).toList();
  }
}
