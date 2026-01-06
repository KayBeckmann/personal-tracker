import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Plattform-unabhängige Funktion zum Öffnen der Datenbank
///
/// Verwendet drift_flutter, das automatisch die richtige Implementierung
/// für die jeweilige Plattform wählt:
/// - Web: WASM + IndexedDB (nutzt sqlite3.wasm und drift_worker.js)
/// - Native (Mobile/Desktop): NativeDatabase mit SQLite-Datei
QueryExecutor openConnection() {
  return driftDatabase(
    name: 'personal_tracker_db',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
