import 'package:equatable/equatable.dart';

/// Domain Entity für Kontotyp
class AccountType extends Equatable {
  const AccountType({
    required this.id,
    required this.name,
    required this.icon,
    required this.sortOrder,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String icon;
  final int sortOrder;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        sortOrder,
        isDefault,
        createdAt,
        updatedAt,
      ];

  AccountType copyWith({
    int? id,
    String? name,
    String? icon,
    int? sortOrder,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountType(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
