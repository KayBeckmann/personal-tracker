import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/note.dart';

/// Widget zur Anzeige einer Notiz in der Liste
class NoteListItem extends StatelessWidget {
  const NoteListItem({
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onToggleArchive,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleArchive;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isArchived)
                    const Icon(
                      Icons.archive,
                      size: 20,
                      color: Colors.grey,
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'archive') {
                        onToggleArchive();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(note.isArchived ? Icons.unarchive : Icons.archive),
                            const SizedBox(width: 8),
                            Text(note.isArchived ? 'Dearchivieren' : 'Archivieren'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Löschen', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  // Tags
                  if (note.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: note.tags.take(3).map((tag) {
                        return Chip(
                          label: Text(
                            tag.name,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: tag.color != null
                              ? Color(int.parse('0xFF${tag.color}'))
                              : Theme.of(context).colorScheme.secondaryContainer,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  if (note.tags.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '+${note.tags.length - 3}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
