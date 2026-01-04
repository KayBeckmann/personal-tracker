import 'package:flutter/material.dart';

import 'core/di/injection.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  configureDependencies();

  runApp(const PersonalTrackerApp());
}

class PersonalTrackerApp extends StatelessWidget {
  const PersonalTrackerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Personal Tracker',
    debugShowCheckedModeBanner: false,

    // Material 3 Design
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),

    // Dark Theme
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    ),

    // Placeholder Home bis Navigation eingerichtet ist
    // Theme Mode: ThemeMode.system ist default, wird später aus Settings geladen
    home: const _PlaceholderHome(),
  );
}

/// Temporäre Placeholder-Seite bis die Navigation in Meilenstein 1.3 eingerichtet ist
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Personal Tracker'), centerTitle: true),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Grundgerüst wird aufgebaut',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Meilenstein 1.1 - Projekt-Setup',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    ),
  );
}
