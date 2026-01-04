import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/habits/presentation/pages/habits_page.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/time_tracking/presentation/pages/time_tracking_page.dart';
import 'app_module.dart';
import 'app_shell.dart';

/// Router-Konfiguration für die App
///
/// Verwendet go_router für deklaratives Routing mit:
/// - Shell-Route für Bottom Navigation
/// - Typsicheres Routing
/// - Deep-Linking Support
@lazySingleton
class AppRouter {
  AppRouter() {
    router = GoRouter(
      initialLocation: AppModules.dashboard.route,
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: AppModules.dashboard.route,
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: AppModules.finance.route,
              builder: (context, state) => const FinancePage(),
            ),
            GoRoute(
              path: AppModules.notes.route,
              builder: (context, state) => const NotesPage(),
            ),
            GoRoute(
              path: AppModules.tasks.route,
              builder: (context, state) => const TasksPage(),
            ),
            GoRoute(
              path: AppModules.habits.route,
              builder: (context, state) => const HabitsPage(),
            ),
            GoRoute(
              path: AppModules.journal.route,
              builder: (context, state) => const JournalPage(),
            ),
            GoRoute(
              path: AppModules.timeTracking.route,
              builder: (context, state) => const TimeTrackingPage(),
            ),
            GoRoute(
              path: AppModules.settings.route,
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    );
  }

  late final GoRouter router;
}
