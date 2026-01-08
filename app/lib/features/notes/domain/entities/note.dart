import 'package:equatable/equatable.dart';

import 'tag.dart';

/// Domain-Entity für eine Notiz
class Note extends Equatable {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.tags = const [],
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String content;
  final List<Tag> tags;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    int? id,
    String? title,
    String? content,
    List<Tag>? tags,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, content, tags, isArchived, createdAt, updatedAt];
}
