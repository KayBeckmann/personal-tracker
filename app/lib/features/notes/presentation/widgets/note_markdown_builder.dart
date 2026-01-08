import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_all_notes.dart';
import 'note_image_builder.dart';

/// Custom Markdown Builder mit Unterstützung für Wiki-Links [[Notiz-Titel]]
class NoteMarkdownBuilder extends MarkdownElementBuilder {
  NoteMarkdownBuilder({
    required this.onNoteLinkTap,
  });

  final void Function(String noteTitle) onNoteLinkTap;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'a' && element.attributes['href']?.startsWith('note://') == true) {
      final noteTitle = element.attributes['href']!.substring(7); // Remove "note://"

      return InkWell(
        onTap: () => onNoteLinkTap(noteTitle),
        child: Text(
          element.textContent,
          style: preferredStyle?.copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }
    return null;
  }
}

/// Inline Syntax für Wiki-Links: [[Notiz-Titel]]
class WikiLinkSyntax extends md.InlineSyntax {
  WikiLinkSyntax() : super(r'\[\[([^\]]+)\]\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final noteTitle = match[1]!;

    final anchor = md.Element.text('a', noteTitle);
    anchor.attributes['href'] = 'note://$noteTitle';

    parser.addNode(anchor);
    return true;
  }
}

/// Markdown Widget mit Wiki-Link-Unterstützung
class NoteMarkdownViewer extends StatelessWidget {
  const NoteMarkdownViewer({
    required this.data,
    required this.onNoteLinkTap,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final String data;
  final void Function(String noteTitle) onNoteLinkTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data,
      padding: padding,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [WikiLinkSyntax()],
      builders: {
        'a': NoteMarkdownBuilder(onNoteLinkTap: onNoteLinkTap),
        'img': NoteImageBuilder(),
      },
      onTapLink: (text, href, title) {
        // Handle regular links
        if (href != null && !href.startsWith('note://')) {
          // Could open URL in browser
        }
      },
    );
  }
}

/// Service zum Finden von Notizen nach Titel
class NoteLinkResolver {
  static final _getAllNotes = getIt<GetAllNotes>();

  /// Findet Notiz-ID anhand des Titels
  static Future<int?> findNoteIdByTitle(String title) async {
    final notes = await _getAllNotes(includeArchived: true);

    // Exakte Übereinstimmung
    for (final note in notes) {
      if (note.title.toLowerCase() == title.toLowerCase()) {
        return note.id;
      }
    }

    // Teilübereinstimmung
    for (final note in notes) {
      if (note.title.toLowerCase().contains(title.toLowerCase())) {
        return note.id;
      }
    }

    return null;
  }

  /// Extrahiert alle Wiki-Links aus einem Markdown-Text
  static List<String> extractWikiLinks(String markdown) {
    final regex = RegExp(r'\[\[([^\]]+)\]\]');
    final matches = regex.allMatches(markdown);
    return matches.map((m) => m.group(1)!).toList();
  }

  /// Findet alle Backlinks zu einer Notiz
  static Future<List<int>> findBacklinks(int noteId, String noteTitle) async {
    final allNotes = await _getAllNotes(includeArchived: true);
    final backlinks = <int>[];

    for (final note in allNotes) {
      if (note.id == noteId) continue;

      final links = extractWikiLinks(note.content);
      if (links.any((link) => link.toLowerCase() == noteTitle.toLowerCase())) {
        backlinks.add(note.id);
      }
    }

    return backlinks;
  }
}
