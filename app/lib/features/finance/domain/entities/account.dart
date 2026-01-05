import 'package:equatable/equatable.dart';

/// Domain Entity für Konto
class Account extends Equatable {
  const Account({
    required this.id,
    required this.accountTypeId,
    required this.name,
    required this.currency,
    required this.initialBalance,
    required this.includeInOverview,
    required this.isDefault,
    this.color,
    this.notes,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int accountTypeId;
  final String name;
  final String currency;
  final double initialBalance;
  final bool includeInOverview;
  final bool isDefault;
  final String? color;
  final String? notes;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        accountTypeId,
        name,
        currency,
        initialBalance,
        includeInOverview,
        isDefault,
        color,
        notes,
        sortOrder,
        createdAt,
        updatedAt,
      ];

  Account copyWith({
    int? id,
    int? accountTypeId,
    String? name,
    String? currency,
    double? initialBalance,
    bool? includeInOverview,
    bool? isDefault,
    String? color,
    String? notes,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      accountTypeId: accountTypeId ?? this.accountTypeId,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
      includeInOverview: includeInOverview ?? this.includeInOverview,
      isDefault: isDefault ?? this.isDefault,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
