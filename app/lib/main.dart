import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  configureDependencies();

  runApp(PersonalTrackerApp());
}

class PersonalTrackerApp extends StatelessWidget {
  PersonalTrackerApp({super.key});

  final _router = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Personal Tracker',
        debugShowCheckedModeBanner: false,

        // Material 3 Design
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),

        // Dark Theme
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),

        // Theme Mode: ThemeMode.system ist default, wird später aus Settings geladen
        // Router Configuration
        routerConfig: _router.router,
      );
}
