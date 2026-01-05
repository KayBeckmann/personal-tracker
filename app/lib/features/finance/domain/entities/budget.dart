import 'package:equatable/equatable.dart';

import '../../data/database/tables/budgets_table.dart';

/// Domain-Entity für ein Budget
class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.name,
    this.categoryId,
    this.accountId,
    required this.amount,
    required this.currency,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.actualSpending = 0.0,
  });

  final int id;
  final String name;
  final int? categoryId;
  final int? accountId;
  final double amount; // SOLL
  final String currency;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double actualSpending; // IST

  /// Prozentsatz der Budgetnutzung (0-100+)
  double get percentage => amount > 0 ? (actualSpending / amount * 100) : 0;

  /// Verbleibender Betrag (kann negativ sein bei Überschreitung)
  double get remaining => amount - actualSpending;

  /// Ob das Budget überschritten wurde
  bool get isExceeded => actualSpending > amount;

  /// Erstellt eine Kopie mit geänderten Werten
  Budget copyWith({
    int? id,
    String? name,
    int? categoryId,
    int? accountId,
    double? amount,
    String? currency,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? actualSpending,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      actualSpending: actualSpending ?? this.actualSpending,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        categoryId,
        accountId,
        amount,
        currency,
        period,
        startDate,
        endDate,
        isActive,
        createdAt,
        updatedAt,
        actualSpending,
      ];
}
