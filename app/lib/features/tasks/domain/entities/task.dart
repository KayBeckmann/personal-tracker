import 'package:equatable/equatable.dart';

import '../../data/database/tables/tasks_table.dart';

/// Domain-Entity für eine Aufgabe
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.open,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.completedAt,
    this.noteId,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final int? noteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Ist die Aufgabe überfällig?
  bool get isOverdue {
    if (dueDate == null) return false;
    if (status == TaskStatus.completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// Ist die Aufgabe heute fällig?
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return dueDay.isAtSameMomentAs(today);
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? completedAt,
    int? noteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      noteId: noteId ?? this.noteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        dueDate,
        completedAt,
        noteId,
        createdAt,
        updatedAt,
      ];
}
