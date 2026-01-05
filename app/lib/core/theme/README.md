# Material Design 3 Theme System

Dieses Verzeichnis enthält die vollständige Material Design 3 (Material You) Implementierung für Personal Tracker.

## Übersicht

### 📁 Dateien

- **`app_theme.dart`** - Haupt-Theme-Definition mit Light und Dark Theme
- **`responsive.dart`** - Responsive Layout Utilities für verschiedene Bildschirmgrößen
- **`accessibility.dart`** - Barrierefreiheits-Utilities und Widgets
- **`components.dart`** - Wiederverwendbare Material Design 3 Komponenten

## Features

### ✅ Material 3 (Material You)

- Material 3 ist aktiviert (`useMaterial3: true`)
- Vollständige ColorScheme-Unterstützung
- Dynamic Color Support für Android 12+ (via `dynamic_color` package)
- Automatische Systemfarben-Integration

### 🎨 Farbschema

```dart
// Standard-Theme mit Fallback-Farbe
final theme = AppTheme.light();

// Mit Dynamic Color (Android 12+)
DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) {
    return MaterialApp(
      theme: AppTheme.light(lightDynamic),
      darkTheme: AppTheme.dark(darkDynamic),
    );
  },
)
```

### 📝 Typografie

Vollständige Material Design 3 Typografie implementiert:

- **Display Styles**: displayLarge, displayMedium, displaySmall
- **Headline Styles**: headlineLarge, headlineMedium, headlineSmall
- **Title Styles**: titleLarge, titleMedium, titleSmall
- **Body Styles**: bodyLarge, bodyMedium, bodySmall
- **Label Styles**: labelLarge, labelMedium, labelSmall

Alle Styles folgen den [Material Design 3 Guidelines](https://m3.material.io/styles/typography/overview) mit korrekten:
- Font Sizes
- Font Weights
- Letter Spacing
- Line Heights

### 🎯 Komponenten

Alle wichtigen Material Design 3 Komponenten sind vordefiniert:

- **Cards** - Mit Outline-Style statt Elevation
- **Buttons** - ElevatedButton, FilledButton, OutlinedButton, TextButton
- **FABs** - Floating Action Buttons mit modernen Shapes
- **Input Fields** - Filled Style mit abgerundeten Ecken
- **App Bar** - Surface-basiert mit Scroll-Elevation
- **Navigation Bar** - 80dp Höhe mit Indicator
- **Dialogs** - 28dp Border Radius
- **Bottom Sheets** - Mit Drag Handle
- **Chips** - 8dp Border Radius
- **List Tiles** - Mit modernem Padding

### 📱 Responsive Layouts

Window Size Classes nach Material Design 3:

```dart
// Compact: < 600dp (Telefone)
final isCompact = Responsive.isCompact(context);

// Medium: 600-840dp (Tablets im Hochformat)
final isMedium = Responsive.isMedium(context);

// Expanded: > 840dp (Tablets im Querformat, Desktop)
final isExpanded = Responsive.isExpanded(context);

// Werte basierend auf Bildschirmgröße
final columns = Responsive.value(
  context: context,
  compact: 1,
  medium: 2,
  expanded: 3,
);
```

#### Responsive Widgets

```dart
// Container mit maximaler Breite
ResponsiveContainer(
  child: YourContent(),
)

// Grid mit automatischer Spaltenanzahl
ResponsiveGrid(
  compactColumns: 1,
  mediumColumns: 2,
  expandedColumns: 3,
  children: [/* ... */],
)
```

### ♿ Barrierefreiheit

Umfassende Accessibility-Unterstützung:

```dart
// Mindest-Touch-Target-Größe (48x48dp)
AccessibleTouchTarget(
  child: Icon(Icons.close),
)

// Semantisch verbesserter Button
AccessibleButton(
  onPressed: () {},
  semanticLabel: 'Schließen',
  tooltip: 'Dialog schließen',
  child: Icon(Icons.close),
)

// Überschriften für Screen Reader
AccessibleHeading(
  level: 1,
  child: Text('Hauptüberschrift'),
)

// Fokus-Highlight für Tastaturnavigation
FocusHighlight(
  child: YourWidget(),
)

// Live Region für dynamische Inhalte
LiveRegion(
  child: Text('Wird aktualisiert...'),
)
```

#### Accessibility Checks

```dart
// Bold Text aktiviert?
final boldText = Accessibility.isBoldTextEnabled(context);

// High Contrast aktiviert?
final highContrast = Accessibility.isHighContrastEnabled(context);

// Animationen reduzieren?
final reduceMotion = Accessibility.isReduceMotionEnabled(context);

// Text-Skalierungsfaktor
final textScale = Accessibility.getTextScaleFactor(context);
```

### 🎭 Wiederverwendbare Komponenten

```dart
// Standard Card
AppCard(
  child: Text('Content'),
  onTap: () {},
)

// Info Card mit Icon
InfoCard(
  icon: Icons.info,
  title: 'Titel',
  subtitle: 'Beschreibung',
  trailing: Icon(Icons.chevron_right),
)

// Statistik Card
StatCard(
  label: 'Ausgaben',
  value: '1.234 €',
  icon: Icons.euro,
  trend: -5.2,
)

// Section Header
SectionHeader(
  title: 'Überschrift',
  subtitle: 'Beschreibung',
  action: TextButton(
    onPressed: () {},
    child: Text('Alle anzeigen'),
  ),
)

// Empty State
EmptyState(
  icon: Icons.inbox,
  title: 'Keine Einträge',
  message: 'Füge einen neuen Eintrag hinzu',
  action: FilledButton(
    onPressed: () {},
    child: Text('Hinzufügen'),
  ),
)

// Loading Indicator
LoadingIndicator(
  message: 'Lädt...',
)

// Error View
ErrorView(
  message: 'Verbindung fehlgeschlagen',
  onRetry: () {},
)

// Badge
AppBadge(
  count: 5,
)

// Fade-In Animation
FadeIn(
  duration: Duration(milliseconds: 300),
  delay: Duration(milliseconds: 100),
  child: YourWidget(),
)
```

### 🎬 Motion & Animationen

Page Transitions nach Material Specs:

- **Android**: PredictiveBackPageTransitionsBuilder
- **iOS/macOS**: CupertinoPageTransitionsBuilder
- **Linux/Windows**: FadeUpwardsPageTransitionsBuilder

Zusätzliche Animations-Widgets:
- `FadeIn` - Einfache Fade-In Animation mit Delay-Support

### 🎨 Icon-Set

- Verwendet Material Icons (standard Flutter Icons)
- Material Symbols können optional über `material_symbols_icons` Package hinzugefügt werden

## Best Practices

### Theme-Farben verwenden

```dart
// ✅ Richtig
Container(
  color: Theme.of(context).colorScheme.primary,
)

// ❌ Falsch
Container(
  color: Colors.blue,
)
```

### Text-Styles verwenden

```dart
// ✅ Richtig
Text(
  'Titel',
  style: Theme.of(context).textTheme.headlineMedium,
)

// ❌ Falsch
Text(
  'Titel',
  style: TextStyle(fontSize: 28),
)
```

### Responsive Layouts

```dart
// ✅ Richtig
final columns = Responsive.getGridColumns(context);

// ✅ Auch richtig
ResponsiveGrid(children: [...])
```

### Accessibility

```dart
// ✅ Richtig - Semantik hinzufügen
Semantics(
  label: 'Schließen',
  button: true,
  child: IconButton(
    onPressed: () {},
    icon: Icon(Icons.close),
  ),
)

// ✅ Richtig - Touch-Target-Größe beachten
AccessibleTouchTarget(
  child: SmallWidget(),
)
```

## Weitere Ressourcen

- [Material Design 3](https://m3.material.io/)
- [Flutter Material 3](https://docs.flutter.dev/ui/design/material)
- [Material Design Typography](https://m3.material.io/styles/typography/overview)
- [Material Design Color System](https://m3.material.io/styles/color/overview)
- [Material Design Components](https://m3.material.io/components)
- [Accessibility Guidelines](https://m3.material.io/foundations/accessible-design/overview)
