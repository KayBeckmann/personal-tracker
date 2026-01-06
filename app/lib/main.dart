import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/finance/domain/services/recurring_transaction_scheduler.dart';
import 'features/settings/domain/usecases/get_locale.dart';
import 'features/settings/domain/usecases/get_theme_mode.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  configureDependencies();

  // Process due recurring transactions
  await _initializeSchedulers();

  runApp(PersonalTrackerApp());
}

/// Initialisiert alle Scheduler (z.B. für Daueraufträge)
Future<void> _initializeSchedulers() async {
  final recurringScheduler = getIt<RecurringTransactionScheduler>();
  await recurringScheduler.initialize();
}

class PersonalTrackerApp extends StatefulWidget {
  const PersonalTrackerApp({super.key});

  @override
  State<PersonalTrackerApp> createState() => _PersonalTrackerAppState();
}

class _PersonalTrackerAppState extends State<PersonalTrackerApp> {
  final _router = getIt<AppRouter>();
  final _getLocale = getIt<GetLocale>();
  final _getThemeMode = getIt<GetThemeMode>();

  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _watchLocaleChanges();
    _loadThemeMode();
    _watchThemeModeChanges();
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

  Future<void> _loadThemeMode() async {
    final themeModeString = await _getThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = _parseThemeMode(themeModeString);
      });
    }
  }

  void _watchThemeModeChanges() {
    _getThemeMode.watch().listen((themeModeString) {
      if (mounted) {
        setState(() {
          _themeMode = _parseThemeMode(themeModeString);
        });
      }
    });
  }

  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    // DynamicColorBuilder ermöglicht System-Farbschema auf Android 12+
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
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

          // Theming mit Dynamic Color Support
          theme: AppTheme.light(lightDynamic),
          darkTheme: AppTheme.dark(darkDynamic),
          themeMode: _themeMode,

          // Router Configuration
          routerConfig: _router.router,
        );
      },
    );
  }
}
