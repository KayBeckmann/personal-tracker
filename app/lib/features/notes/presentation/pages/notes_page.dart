import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/create_tag.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_all_notes.dart';
import '../../domain/usecases/get_all_tags.dart';
import '../../domain/usecases/get_notes_by_tags.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/toggle_note_archive.dart';
import '../widgets/note_form_dialog.dart';
import '../widgets/note_list_item.dart';
import '../widgets/tag_filter_chip.dart';
import '../widgets/tag_form_dialog.dart';
import 'note_editor_page.dart';

/// Notizen-Übersicht mit Suche und Tag-Filter
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _getAllNotes = getIt<GetAllNotes>();
  final _searchNotes = getIt<SearchNotes>();
  final _getNotesByTags = getIt<GetNotesByTags>();
  final _createNote = getIt<CreateNote>();
  final _deleteNote = getIt<DeleteNote>();
  final _toggleArchive = getIt<ToggleNoteArchive>();
  final _getAllTags = getIt<GetAllTags>();
  final _createTag = getIt<CreateTag>();

  final _searchController = TextEditingController();
  final List<int> _selectedTagIds = [];
  bool _showArchived = false;
  bool _isSpeedDialOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});
  }

  void _toggleTagFilter(int tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTagIds.clear();
    });
  }

  Future<void> _showCreateNoteDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => NoteFormDialog(
        onSave: (title, content, tagIds) async {
          await _createNote(
            title: title,
            content: content,
            tagIds: tagIds,
          );
        },
      ),
    );
  }

  Future<void> _showCreateTagDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => TagFormDialog(
        onSave: (name, color) async {
          await _createTag(name: name, color: color);
        },
      ),
    );
  }

  Future<void> _confirmAndDeleteNote(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notiz löschen?'),
        content: const Text('Möchten Sie diese Notiz wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteNote(id);
    }
  }

  Widget _buildSpeedDialOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          onPressed: () {
            setState(() => _isSpeedDialOpen = false);
            onTap();
          },
          child: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notes),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.unarchive : Icons.archive),
            onPressed: () {
              setState(() => _showArchived = !_showArchived);
            },
            tooltip: _showArchived ? 'Aktive anzeigen' : 'Archiv anzeigen',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Notizen durchsuchen...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty || _selectedTagIds.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilters,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Tag filter chips
          StreamBuilder<List<Tag>>(
            stream: _getAllTags.watch(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final tags = snapshot.data!;

              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TagFilterChip(
                        tag: tag,
                        isSelected: _selectedTagIds.contains(tag.id),
                        onTap: () => _toggleTagFilter(tag.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const Divider(),

          // Notes list
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _getAllNotes.watch(includeArchived: _showArchived),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Keine Notizen vorhanden',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Erstellen Sie Ihre erste Notiz',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                var notes = snapshot.data!;

                // Apply search filter
                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  notes = notes.where((note) {
                    return note.title.toLowerCase().contains(query) ||
                        note.content.toLowerCase().contains(query);
                  }).toList();
                }

                // Apply tag filter
                if (_selectedTagIds.isNotEmpty) {
                  notes = notes.where((note) {
                    final noteTagIds = note.tags.map((t) => t.id).toSet();
                    return _selectedTagIds.every((id) => noteTagIds.contains(id));
                  }).toList();
                }

                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Keine passenden Notizen gefunden',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteListItem(
                      note: note,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => NoteEditorPage(noteId: note.id),
                          ),
                        );
                      },
                      onDelete: () => _confirmAndDeleteNote(note.id),
                      onToggleArchive: () => _toggleArchive(note.id, !note.isArchived),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_isSpeedDialOpen) ...[
            Positioned(
              bottom: 80,
              child: _buildSpeedDialOption(
                icon: Icons.note_add,
                label: 'Notiz',
                onTap: _showCreateNoteDialog,
              ),
            ),
            Positioned(
              bottom: 160,
              child: _buildSpeedDialOption(
                icon: Icons.label,
                label: 'Tag',
                onTap: _showCreateTagDialog,
              ),
            ),
          ],
          FloatingActionButton(
            onPressed: () {
              setState(() => _isSpeedDialOpen = !_isSpeedDialOpen);
            },
            child: AnimatedRotation(
              turns: _isSpeedDialOpen ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(_isSpeedDialOpen ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
