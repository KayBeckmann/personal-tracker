import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Plattform-unabhängige Funktion zum Öffnen der Datenbank
///
/// Verwendet drift_flutter, das automatisch die richtige Implementierung
/// für die jeweilige Plattform wählt:
/// - Web: IndexedDB (stabil, funktioniert ohne SharedArrayBuffers)
/// - Native (Mobile/Desktop): NativeDatabase mit SQLite-Datei
QueryExecutor openConnection() {
  return driftDatabase(
    name: 'personal_tracker_db',
    // Keine web-Optionen = Drift nutzt IndexedDB automatisch auf Web
    // Dies ist stabiler und funktioniert ohne WASM/SharedArrayBuffers
  );
}
