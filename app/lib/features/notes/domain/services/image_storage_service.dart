import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service für die Speicherung und Verwaltung von Bildern in Notizen
@lazySingleton
class ImageStorageService {
  final ImagePicker _picker = ImagePicker();

  /// Verzeichnis für Notiz-Bilder
  Future<Directory> get _imagesDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'note_images'));

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// Bild aus Galerie auswählen
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _saveImage(image);
    } catch (e) {
      print('Fehler beim Auswählen des Bildes: $e');
      return null;
    }
  }

  /// Bild mit Kamera aufnehmen
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _saveImage(image);
    } catch (e) {
      print('Fehler beim Aufnehmen des Bildes: $e');
      return null;
    }
  }

  /// Speichert ein Bild und gibt den relativen Pfad zurück
  Future<String> _saveImage(XFile image) async {
    final imagesDir = await _imagesDirectory;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(image.path);
    final fileName = 'note_$timestamp$extension';
    final targetPath = path.join(imagesDir.path, fileName);

    // Kopiere Bild zum Ziel
    await File(image.path).copy(targetPath);

    // Rückgabe: relativer Pfad für Markdown
    return 'note_images/$fileName';
  }

  /// Gibt den absoluten Pfad zu einem Bild zurück
  Future<String> getAbsolutePath(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, relativePath);
  }

  /// Löscht ein Bild
  Future<void> deleteImage(String relativePath) async {
    try {
      final absolutePath = await getAbsolutePath(relativePath);
      final file = File(absolutePath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Fehler beim Löschen des Bildes: $e');
    }
  }

  /// Extrahiert alle Bild-Pfade aus einem Markdown-Text
  List<String> extractImagePaths(String markdown) {
    final regex = RegExp(r'!\[.*?\]\((note_images/[^)]+)\)');
    final matches = regex.allMatches(markdown);
    return matches.map((m) => m.group(1)!).toList();
  }

  /// Bereinigt nicht verwendete Bilder
  Future<void> cleanupUnusedImages(List<String> usedPaths) async {
    try {
      final imagesDir = await _imagesDirectory;
      final files = await imagesDir.list().toList();

      for (final file in files) {
        if (file is File) {
          final relativePath = 'note_images/${path.basename(file.path)}';
          if (!usedPaths.contains(relativePath)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Fehler beim Bereinigen der Bilder: $e');
    }
  }
}
