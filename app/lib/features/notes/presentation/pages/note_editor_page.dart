import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/tag.dart';
import '../../domain/services/image_storage_service.dart';
import '../../domain/usecases/get_all_notes.dart';
import '../../domain/usecases/get_all_tags.dart';
import '../../domain/usecases/get_note_by_id.dart';
import '../../domain/usecases/update_note.dart';
import '../widgets/note_markdown_builder.dart';

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
  final _getAllNotes = getIt<GetAllNotes>();
  final _imageStorage = getIt<ImageStorageService>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Note? _note;
  bool _isPreviewMode = false;
  bool _isLoading = true;
  bool _hasChanges = false;
  List<int> _backlinks = [];

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
      // Load backlinks
      final backlinks = await NoteLinkResolver.findBacklinks(note.id, note.title);

      setState(() {
        _note = note;
        _titleController.text = note.title;
        _contentController.text = note.content;
        _backlinks = backlinks;
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

  Future<void> _onNoteLinkTap(String noteTitle) async {
    final noteId = await NoteLinkResolver.findNoteIdByTitle(noteTitle);

    if (noteId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => NoteEditorPage(noteId: noteId),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notiz "$noteTitle" nicht gefunden')),
      );
    }
  }

  Future<void> _showBacklinks() async {
    if (_backlinks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Backlinks vorhanden')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => _BacklinksDialog(
        backlinks: _backlinks,
        onNoteTap: (noteId) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => NoteEditorPage(noteId: noteId),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showImagePicker() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bild hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Aus Galerie'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;

    String? imagePath;
    if (result == 'gallery') {
      imagePath = await _imageStorage.pickImageFromGallery();
    } else if (result == 'camera') {
      imagePath = await _imageStorage.pickImageFromCamera();
    }

    if (imagePath != null && mounted) {
      // Füge Markdown-Syntax in den Editor ein
      final markdownImage = '\n![]($imagePath)\n';
      final currentText = _contentController.text;
      final cursorPosition = _contentController.selection.baseOffset;

      if (cursorPosition < 0) {
        // Kein Cursor gesetzt, am Ende einfügen
        _contentController.text = currentText + markdownImage;
      } else {
        // An Cursor-Position einfügen
        final newText = currentText.substring(0, cursorPosition) +
            markdownImage +
            currentText.substring(cursorPosition);
        _contentController.text = newText;
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPosition + markdownImage.length),
        );
      }
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
            if (!_isPreviewMode)
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _showImagePicker,
                tooltip: 'Bild hinzufügen',
              ),
            IconButton(
              icon: const Icon(Icons.label),
              onPressed: _showTagDialog,
              tooltip: 'Tags verwalten',
            ),
            if (_backlinks.isNotEmpty)
              IconButton(
                icon: Badge(
                  label: Text('${_backlinks.length}'),
                  child: const Icon(Icons.link),
                ),
                onPressed: _showBacklinks,
                tooltip: 'Backlinks anzeigen',
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
                  ? NoteMarkdownViewer(
                      data: _contentController.text,
                      onNoteLinkTap: _onNoteLinkTap,
                    )
                  : TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Inhalt (Markdown & Wiki-Links [[Titel]] unterstützt)',
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

/// Dialog zur Anzeige von Backlinks
class _BacklinksDialog extends StatelessWidget {
  const _BacklinksDialog({
    required this.backlinks,
    required this.onNoteTap,
  });

  final List<int> backlinks;
  final void Function(int noteId) onNoteTap;

  @override
  Widget build(BuildContext context) {
    final getNoteById = getIt<GetNoteById>();

    return AlertDialog(
      title: const Text('Backlinks'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: backlinks.length,
          itemBuilder: (context, index) {
            final noteId = backlinks[index];

            return FutureBuilder<Note?>(
              future: getNoteById(noteId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const ListTile(
                    title: Text('Lädt...'),
                  );
                }

                final note = snapshot.data!;
                return ListTile(
                  leading: const Icon(Icons.link),
                  title: Text(note.title),
                  subtitle: Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onNoteTap(noteId),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}
