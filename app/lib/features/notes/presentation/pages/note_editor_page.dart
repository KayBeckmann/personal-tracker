import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/get_all_tags.dart';
import '../../domain/usecases/get_note_by_id.dart';
import '../../domain/usecases/update_note.dart';

/// Seite zum Bearbeiten einer Notiz mit Markdown-Editor und Vorschau
class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({
    required this.noteId,
    super.key,
  });

  final int noteId;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _getNoteById = getIt<GetNoteById>();
  final _updateNote = getIt<UpdateNote>();
  final _getAllTags = getIt<GetAllTags>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Note? _note;
  bool _isPreviewMode = false;
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final note = await _getNoteById(widget.noteId);
    if (note != null && mounted) {
      setState(() {
        _note = note;
        _titleController.text = note.title;
        _contentController.text = note.content;
        _isLoading = false;
      });

      _titleController.addListener(_onTextChanged);
      _contentController.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveNote() async {
    if (_note == null) return;

    final updatedNote = _note!.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );

    await _updateNote(updatedNote);

    setState(() {
      _note = updatedNote;
      _hasChanges = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notiz gespeichert')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Änderungen verwerfen?'),
        content: const Text('Sie haben ungespeicherte Änderungen. Möchten Sie diese verwerfen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verwerfen'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  Future<void> _showTagDialog() async {
    if (_note == null) return;

    final tags = await _getAllTags();
    final selectedTagIds = _note!.tags.map((t) => t.id).toList();

    final result = await showDialog<List<int>>(
      context: context,
      builder: (context) => _TagSelectionDialog(
        tags: tags,
        selectedTagIds: selectedTagIds,
      ),
    );

    if (result != null && mounted) {
      final updatedTags = tags.where((t) => result.contains(t.id)).toList();
      final updatedNote = _note!.copyWith(tags: updatedTags);

      await _updateNote(updatedNote);

      setState(() {
        _note = updatedNote;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notiz nicht gefunden')),
        body: const Center(child: Text('Diese Notiz existiert nicht mehr.')),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notiz bearbeiten'),
          actions: [
            IconButton(
              icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
              onPressed: () {
                setState(() => _isPreviewMode = !_isPreviewMode);
              },
              tooltip: _isPreviewMode ? 'Bearbeiten' : 'Vorschau',
            ),
            IconButton(
              icon: const Icon(Icons.label),
              onPressed: _showTagDialog,
              tooltip: 'Tags verwalten',
            ),
            if (_hasChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveNote,
                tooltip: 'Speichern',
              ),
          ],
        ),
        body: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Titel',
                  border: OutlineInputBorder(),
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            // Tags display
            if (_note!.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8,
                  children: _note!.tags.map((tag) {
                    return Chip(
                      label: Text(tag.name),
                      backgroundColor: tag.color != null
                          ? Color(int.parse('0xFF${tag.color}'))
                          : Theme.of(context).colorScheme.secondaryContainer,
                    );
                  }).toList(),
                ),
              ),

            const Divider(),

            // Editor or Preview
            Expanded(
              child: _isPreviewMode
                  ? Markdown(
                      data: _contentController.text,
                      padding: const EdgeInsets.all(16),
                    )
                  : TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Inhalt (Markdown unterstützt)',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog zur Tag-Auswahl
class _TagSelectionDialog extends StatefulWidget {
  const _TagSelectionDialog({
    required this.tags,
    required this.selectedTagIds,
  });

  final List<Tag> tags;
  final List<int> selectedTagIds;

  @override
  State<_TagSelectionDialog> createState() => _TagSelectionDialogState();
}

class _TagSelectionDialogState extends State<_TagSelectionDialog> {
  late final List<int> _selectedTagIds;

  @override
  void initState() {
    super.initState();
    _selectedTagIds = List.from(widget.selectedTagIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tags auswählen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.tags.map((tag) {
            final isSelected = _selectedTagIds.contains(tag.id);
            return CheckboxListTile(
              title: Text(tag.name),
              value: isSelected,
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedTagIds.add(tag.id);
                  } else {
                    _selectedTagIds.remove(tag.id);
                  }
                });
              },
              secondary: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: tag.color != null
                      ? Color(int.parse('0xFF${tag.color}'))
                      : Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedTagIds),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
