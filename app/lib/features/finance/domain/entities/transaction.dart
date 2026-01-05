import 'package:equatable/equatable.dart';

import '../../data/database/tables/transactions_table.dart';

/// Domain-Entity für eine Buchung
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.type,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    required this.amount,
    required this.currency,
    required this.date,
    this.payee,
    this.description,
    required this.isPlanned,
    required this.isTemplate,
    this.templateName,
    required this.isBooked,
    this.recurringTransactionId,
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
  final DateTime date;
  final String? payee;
  final String? description;
  final bool isPlanned;
  final bool isTemplate;
  final String? templateName;
  final bool isBooked;
  final int? recurringTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Erstellt eine Kopie mit geänderten Werten
  Transaction copyWith({
    int? id,
    TransactionType? type,
    int? accountId,
    int? toAccountId,
    int? categoryId,
    double? amount,
    String? currency,
    DateTime? date,
    String? payee,
    String? description,
    bool? isPlanned,
    bool? isTemplate,
    String? templateName,
    bool? isBooked,
    int? recurringTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      payee: payee ?? this.payee,
      description: description ?? this.description,
      isPlanned: isPlanned ?? this.isPlanned,
      isTemplate: isTemplate ?? this.isTemplate,
      templateName: templateName ?? this.templateName,
      isBooked: isBooked ?? this.isBooked,
      recurringTransactionId: recurringTransactionId ?? this.recurringTransactionId,
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
        date,
        payee,
        description,
        isPlanned,
        isTemplate,
        templateName,
        isBooked,
        recurringTransactionId,
        createdAt,
        updatedAt,
      ];
}
