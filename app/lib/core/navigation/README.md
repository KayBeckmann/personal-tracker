# Navigation & Routing

Personal Tracker verwendet **go_router** für deklaratives Routing mit Type-Safety und Deep-Linking Support.

## Architektur

### App-Shell
Die `AppShell` umschließt alle Haupt-Screens und bietet:
- **Bottom Navigation Bar** mit den wichtigsten Modulen
- **Navigation Drawer** mit allen verfügbaren Modulen
- Material 3 Design (NavigationBar)

### Modul-System
Jedes Feature ist als `AppModule` definiert mit:
- Eindeutiger ID
- Name und Icon
- Route
- Aktivierungsstatus (kann ein/ausgeschaltet werden)

### Module verwalten
Der `ModuleService` verwaltet, welche Module aktiv sind:
```dart
final moduleService = getIt<ModuleService>();

// Modul aktivieren
await moduleService.enableModule('finance');

// Modul deaktivieren
await moduleService.disableModule('finance');

// Prüfen ob Modul aktiv ist
final isEnabled = await moduleService.isModuleEnabled('finance');

// Alle aktiven Module
final enabledModules = await moduleService.getEnabledModules();

// Stream für reaktive UI
moduleService.watchEnabledModules().listen((modules) {
  print('Aktive Module: ${modules.map((m) => m.name).join(", ")}');
});
```

## Verfügbare Module

### In Bottom Navigation
- **Dashboard** - Zentrale Übersicht (Standard-Route)
- **Finanzen** - Haushaltsbuch
- **Notizen** - Notizen-Verwaltung
- **Aufgaben** - Task-Management

### Im Drawer (alle Module)
- Dashboard
- Finanzen
- Notizen
- Aufgaben
- Gewohnheiten
- Journal
- Zeiterfassung
- Einstellungen (immer aktiviert)

## Routing

### Programmatische Navigation
```dart
import 'package:go_router/go_router.dart';

// Zu einer Route navigieren
context.go('/finance');

// Zurück navigieren
context.pop();

// Mit Parametern
context.go('/finance/transaction/123');
```

### Route-Definitionen
Routen sind in `AppRouter` definiert:
```dart
GoRoute(
  path: AppModules.finance.route,
  builder: (context, state) => const FinancePage(),
),
```

### Shell-Route
Alle Haupt-Routes sind in einer `ShellRoute` verschachtelt, sodass die Bottom Navigation immer sichtbar bleibt:
```dart
ShellRoute(
  builder: (context, state, child) => AppShell(child: child),
  routes: [
    // Alle Haupt-Routen hier
  ],
)
```

## Neues Modul hinzufügen

### 1. Modul definieren
Füge das Modul zu `AppModules` in `app_module.dart` hinzu:
```dart
static const myNewModule = AppModule(
  id: 'my_module',
  name: 'Mein Modul',
  icon: Icons.star,
  route: '/my-module',
);
```

### 2. Zur Liste hinzufügen
```dart
static const List<AppModule> all = [
  // ... existing modules
  myNewModule,
];

// Optional: Zur Bottom Navigation hinzufügen
static List<AppModule> get bottomNavigation => [
  // ... existing modules
  myNewModule,
];
```

### 3. Route registrieren
Füge die Route in `AppRouter` hinzu:
```dart
GoRoute(
  path: AppModules.myNewModule.route,
  builder: (context, state) => const MyModulePage(),
),
```

### 4. Page erstellen
Erstelle die Page in `lib/features/my_module/presentation/pages/`:
```dart
class MyModulePage extends StatelessWidget {
  const MyModulePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mein Modul')),
        body: const Center(child: Text('Mein neues Modul')),
      );
}
```

## Deep-Linking

go_router unterstützt automatisch Deep-Linking:

**Web:**
```
https://app.example.com/finance
https://app.example.com/notes
```

**Mobile:**
```
personaltracker://finance
personaltracker://notes
```

## Best Practices

1. **Immer Named Routes verwenden**: Nutze `AppModules.xxx.route` statt hardcodierte Strings
2. **context.go() für Navigation**: Nicht Navigator.push()
3. **ShellRoute für persistente UI**: Bottom Nav, AppBar, etc.
4. **Modul-IDs sind unveränderlich**: Änderungen brechen Einstellungen

## Beispiele

### Navigation zwischen Seiten
```dart
// Von Dashboard zu Finanzen
ElevatedButton(
  onPressed: () => context.go(AppModules.finance.route),
  child: const Text('Zu Finanzen'),
)
```

### Aktuelle Route prüfen
```dart
final currentLocation = GoRouterState.of(context).uri.path;
final isOnDashboard = currentLocation.startsWith(AppModules.dashboard.route);
```

### Drawer-Item mit Auswahl
```dart
ListTile(
  leading: Icon(module.icon),
  title: Text(module.name),
  selected: currentLocation.startsWith(module.route),
  onTap: () {
    context.go(module.route);
    Navigator.pop(context); // Drawer schließen
  },
)
```

## Testing

Navigation-Tests mit go_router:
```dart
testWidgets('Navigation to Finance page', (tester) async {
  await tester.pumpWidget(PersonalTrackerApp());
  await tester.pumpAndSettle();

  // Tap Finance in bottom nav
  await tester.tap(find.text('Finanzen'));
  await tester.pumpAndSettle();

  // Verify we're on Finance page
  expect(find.text('Haushaltsbuch'), findsOneWidget);
});
```

## Ressourcen

- [go_router Dokumentation](https://pub.dev/packages/go_router)
- [Flutter Navigation Best Practices](https://docs.flutter.dev/ui/navigation)
