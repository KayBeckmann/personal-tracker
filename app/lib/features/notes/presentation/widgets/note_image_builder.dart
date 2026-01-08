import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/di/injection.dart';
import '../../domain/services/image_storage_service.dart';

/// Custom Image Builder für lokale Bilder in Notizen
class NoteImageBuilder extends MarkdownElementBuilder {
  final _imageStorage = getIt<ImageStorageService>();

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final src = element.attributes['src'];
    if (src == null) return null;

    // Lokale Bilder (note_images/...)
    if (src.startsWith('note_images/')) {
      return FutureBuilder<String>(
        future: _imageStorage.getAbsolutePath(src),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final file = File(snapshot.data!);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onTap: () {
                // Bild in voller Größe anzeigen
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => _ImageViewer(file: file),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.broken_image, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Bild nicht gefunden',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    // Externe URLs (http/https)
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: () {
            // Externe Bilder nicht in Vollbild öffnen
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              src,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Bild konnte nicht geladen werden',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return null;
  }
}

/// Vollbild-Anzeige für Bilder
class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(file),
        ),
      ),
    );
  }
}
