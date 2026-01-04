import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/navigation/app_router.dart';
import 'features/settings/domain/usecases/get_locale.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  configureDependencies();

  runApp(PersonalTrackerApp());
}

class PersonalTrackerApp extends StatefulWidget {
  const PersonalTrackerApp({super.key});

  @override
  State<PersonalTrackerApp> createState() => _PersonalTrackerAppState();
}

class _PersonalTrackerAppState extends State<PersonalTrackerApp> {
  final _router = getIt<AppRouter>();
  final _getLocale = getIt<GetLocale>();

  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _watchLocaleChanges();
  }

  Future<void> _loadLocale() async {
    final locale = await _getLocale();
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  void _watchLocaleChanges() {
    _getLocale.watch().listen((locale) {
      if (mounted) {
        setState(() {
          _locale = locale;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Personal Tracker',
        debugShowCheckedModeBanner: false,

        // Localization
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _locale,

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
