import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/get_all_tags.dart';

/// Dialog zum Erstellen einer neuen Notiz
class NoteFormDialog extends StatefulWidget {
  const NoteFormDialog({
    required this.onSave,
    super.key,
  });

  final Future<void> Function(String title, String content, List<int> tagIds) onSave;

  @override
  State<NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<NoteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _getAllTags = getIt<GetAllTags>();
  final List<int> _selectedTagIds = [];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      await widget.onSave(
        _titleController.text,
        _contentController.text,
        _selectedTagIds,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Neue Notiz'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Titel eingeben';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Inhalt',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Inhalt eingeben';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Tag>>(
                future: _getAllTags(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final tags = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tags:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: tags.map((tag) {
                          final isSelected = _selectedTagIds.contains(tag.id);
                          return FilterChip(
                            label: Text(tag.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTagIds.add(tag.id);
                                } else {
                                  _selectedTagIds.remove(tag.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Erstellen'),
        ),
      ],
    );
  }
}
