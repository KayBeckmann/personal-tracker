import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/generated/app_localizations.dart';
import 'app_module.dart';

/// App-Shell mit Bottom Navigation
///
/// Umschließt alle Hauptseiten und zeigt die Bottom Navigation Bar.
/// Die Navigation zeigt nur die Module an, die in bottomNavigation definiert sind.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocation = GoRouterState.of(context).uri.path;

    // Finde den aktuell ausgewählten Index
    final currentIndex = _getCurrentIndex(currentLocation);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final destination = AppModules.bottomNavigation[index];
          context.go(destination.route);
        },
        destinations: AppModules.bottomNavigation
            .map(
              (module) => NavigationDestination(
                icon: Icon(module.icon),
                label: module.getName(l10n),
              ),
            )
            .toList(),
      ),
      drawer: _buildDrawer(context, currentLocation),
    );
  }

  int _getCurrentIndex(String location) {
    final index = AppModules.bottomNavigation
        .indexWhere((module) => location.startsWith(module.route));
    return index == -1 ? 0 : index;
  }

  Widget _buildDrawer(BuildContext context, String currentLocation) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.track_changes,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          // Alle Module (außer Settings, das kommt ans Ende)
          ...AppModules.all
              .where((m) => m.id != AppModules.settings.id)
              .map(
                (module) => ListTile(
                  leading: Icon(module.icon),
                  title: Text(module.getName(l10n)),
                  selected: currentLocation.startsWith(module.route),
                  onTap: () {
                    context.go(module.route);
                    Navigator.pop(context); // Drawer schließen
                  },
                ),
              ),
          const Divider(),
          // Settings am Ende
          ListTile(
            leading: Icon(AppModules.settings.icon),
            title: Text(AppModules.settings.getName(l10n)),
            selected: currentLocation.startsWith(AppModules.settings.route),
            onTap: () {
              context.go(AppModules.settings.route);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
