import 'package:equatable/equatable.dart';

/// Domain-Entity für einen Tag
class Tag extends Equatable {
  const Tag({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? color;
  final DateTime createdAt;

  Tag copyWith({
    int? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, color, createdAt];
}
