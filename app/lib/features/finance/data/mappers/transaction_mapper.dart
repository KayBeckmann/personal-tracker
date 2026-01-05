import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction.dart' as domain;

/// Mapper zwischen TransactionData (Data Layer) und Transaction (Domain Layer)
class TransactionMapper {
  /// Konvertiert TransactionData zu Transaction
  static domain.Transaction toEntity(TransactionData data) {
    return domain.Transaction(
      id: data.id,
      type: data.type,
      accountId: data.accountId,
      toAccountId: data.toAccountId,
      categoryId: data.categoryId,
      amount: data.amount,
      currency: data.currency,
      date: data.date,
      payee: data.payee,
      description: data.description,
      isPlanned: data.isPlanned,
      isTemplate: data.isTemplate,
      templateName: data.templateName,
      isBooked: data.isBooked,
      recurringTransactionId: data.recurringTransactionId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Konvertiert Transaction zu TransactionData
  static TransactionData toData(domain.Transaction entity) {
    return TransactionData(
      id: entity.id,
      type: entity.type,
      accountId: entity.accountId,
      toAccountId: entity.toAccountId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      currency: entity.currency,
      date: entity.date,
      payee: entity.payee,
      description: entity.description,
      isPlanned: entity.isPlanned,
      isTemplate: entity.isTemplate,
      templateName: entity.templateName,
      isBooked: entity.isBooked,
      recurringTransactionId: entity.recurringTransactionId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Konvertiert eine Liste von TransactionData zu Transaction
  static List<domain.Transaction> toEntityList(List<TransactionData> dataList) {
    return dataList.map(toEntity).toList();
  }

  /// Konvertiert eine Liste von Transaction zu TransactionData
  static List<TransactionData> toDataList(List<domain.Transaction> entityList) {
    return entityList.map(toData).toList();
  }
}
