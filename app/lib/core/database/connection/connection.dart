import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Plattform-unabhängige Funktion zum Öffnen der Datenbank
///
/// Verwendet drift_flutter, das automatisch die richtige Implementierung
/// für die jeweilige Plattform wählt:
/// - Web: WasmDatabase mit IndexedDB/OPFS
/// - Native (Mobile/Desktop): NativeDatabase mit SQLite-Datei
QueryExecutor openConnection() {
  return driftDatabase(
    name: 'personal_tracker_db',
    // Für Web werden diese Optionen automatisch verwendet
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      // Fallback auf IndexedDB wenn SharedArrayBuffers nicht verfügbar sind
      // Dies ist langsamer, aber funktioniert in allen Browsern
    ),
  );
}
