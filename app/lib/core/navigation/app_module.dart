import 'package:flutter/material.dart';

/// Repräsentiert ein Feature-Modul in der App
///
/// Jedes Modul kann aktiviert/deaktiviert werden und hat:
/// - Eine eindeutige ID
/// - Einen Namen und Icon
/// - Einen Hauptbildschirm
/// - Eine optionale Initialisierungs-Logik
class AppModule {
  const AppModule({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    this.isEnabledByDefault = true,
  });

  /// Eindeutige ID des Moduls
  final String id;

  /// Anzeigename des Moduls
  final String name;

  /// Icon für Navigation
  final IconData icon;

  /// Route-Pfad für Navigation
  final String route;

  /// Ist das Modul standardmäßig aktiviert?
  final bool isEnabledByDefault;
}

/// Verfügbare Module in der App
class AppModules {
  const AppModules._();

  static const dashboard = AppModule(
    id: 'dashboard',
    name: 'Dashboard',
    icon: Icons.dashboard,
    route: '/dashboard',
  );

  static const finance = AppModule(
    id: 'finance',
    name: 'Finanzen',
    icon: Icons.account_balance_wallet,
    route: '/finance',
  );

  static const notes = AppModule(
    id: 'notes',
    name: 'Notizen',
    icon: Icons.note,
    route: '/notes',
  );

  static const tasks = AppModule(
    id: 'tasks',
    name: 'Aufgaben',
    icon: Icons.check_box,
    route: '/tasks',
  );

  static const habits = AppModule(
    id: 'habits',
    name: 'Gewohnheiten',
    icon: Icons.track_changes,
    route: '/habits',
  );

  static const journal = AppModule(
    id: 'journal',
    name: 'Journal',
    icon: Icons.book,
    route: '/journal',
  );

  static const timeTracking = AppModule(
    id: 'time_tracking',
    name: 'Zeiterfassung',
    icon: Icons.access_time,
    route: '/time-tracking',
  );

  static const settings = AppModule(
    id: 'settings',
    name: 'Einstellungen',
    icon: Icons.settings,
    route: '/settings',
    // Immer aktiviert (isEnabledByDefault ist true per default)
  );

  /// Liste aller verfügbaren Module
  static const List<AppModule> all = [
    dashboard,
    finance,
    notes,
    tasks,
    habits,
    journal,
    timeTracking,
    settings,
  ];

  /// Module die in der Bottom Navigation angezeigt werden
  static List<AppModule> get bottomNavigation => [
        dashboard,
        finance,
        notes,
        tasks,
      ];
}
