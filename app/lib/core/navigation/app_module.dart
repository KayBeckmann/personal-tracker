import 'package:flutter/material.dart';

import '../localization/generated/app_localizations.dart';

/// Repräsentiert ein Feature-Modul in der App
///
/// Jedes Modul kann aktiviert/deaktiviert werden und hat:
/// - Eine eindeutige ID
/// - Icon und Route
/// - Eine optionale Initialisierungs-Logik
class AppModule {
  const AppModule({
    required this.id,
    required this.icon,
    required this.route,
    this.isEnabledByDefault = true,
  });

  /// Eindeutige ID des Moduls
  final String id;

  /// Icon für Navigation
  final IconData icon;

  /// Route-Pfad für Navigation
  final String route;

  /// Ist das Modul standardmäßig aktiviert?
  final bool isEnabledByDefault;

  /// Gibt den lokalisierten Namen des Moduls zurück
  String getName(AppLocalizations l10n) {
    switch (id) {
      case 'dashboard':
        return l10n.dashboard;
      case 'finance':
        return l10n.finances;
      case 'notes':
        return l10n.notes;
      case 'tasks':
        return l10n.tasks;
      case 'habits':
        return l10n.habits;
      case 'journal':
        return l10n.journal;
      case 'time_tracking':
        return l10n.timeTracking;
      case 'settings':
        return l10n.settings;
      default:
        return id;
    }
  }
}

/// Verfügbare Module in der App
class AppModules {
  const AppModules._();

  static const dashboard = AppModule(
    id: 'dashboard',
    icon: Icons.dashboard,
    route: '/dashboard',
  );

  static const finance = AppModule(
    id: 'finance',
    icon: Icons.account_balance_wallet,
    route: '/finance',
  );

  static const notes = AppModule(
    id: 'notes',
    icon: Icons.note,
    route: '/notes',
  );

  static const tasks = AppModule(
    id: 'tasks',
    icon: Icons.check_box,
    route: '/tasks',
  );

  static const habits = AppModule(
    id: 'habits',
    icon: Icons.track_changes,
    route: '/habits',
  );

  static const journal = AppModule(
    id: 'journal',
    icon: Icons.book,
    route: '/journal',
  );

  static const timeTracking = AppModule(
    id: 'time_tracking',
    icon: Icons.access_time,
    route: '/time-tracking',
  );

  static const settings = AppModule(
    id: 'settings',
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
