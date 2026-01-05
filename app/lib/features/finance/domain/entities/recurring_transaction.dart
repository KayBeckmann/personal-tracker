import 'package:equatable/equatable.dart';

import '../../data/database/tables/recurring_transactions_table.dart';
import '../../data/database/tables/transactions_table.dart';

/// Domain-Entity für einen Dauerauftrag
class RecurringTransaction extends Equatable {
  const RecurringTransaction({
    required this.id,
    required this.type,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    required this.amount,
    required this.currency,
    this.payee,
    this.description,
    required this.interval,
    required this.dayOfMonth,
    required this.startDate,
    this.endDate,
    this.lastExecuted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final TransactionType type;
  final int accountId;
  final int? toAccountId;
  final int? categoryId;
  final double amount;
  final String currency;
  final String? payee;
  final String? description;
  final RecurrenceInterval interval;
  final int dayOfMonth;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastExecuted;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Erstellt eine Kopie mit geänderten Werten
  RecurringTransaction copyWith({
    int? id,
    TransactionType? type,
    int? accountId,
    int? toAccountId,
    int? categoryId,
    double? amount,
    String? currency,
    String? payee,
    String? description,
    RecurrenceInterval? interval,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastExecuted,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      payee: payee ?? this.payee,
      description: description ?? this.description,
      interval: interval ?? this.interval,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastExecuted: lastExecuted ?? this.lastExecuted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        accountId,
        toAccountId,
        categoryId,
        amount,
        currency,
        payee,
        description,
        interval,
        dayOfMonth,
        startDate,
        endDate,
        lastExecuted,
        isActive,
        createdAt,
        updatedAt,
      ];
}
