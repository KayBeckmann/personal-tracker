import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility (Barrierefreiheit) Utilities
///
/// Stellt Hilfsfunktionen und Widgets für verbesserte Barrierefreiheit bereit.
class Accessibility {
  const Accessibility._();

  /// Mindestgröße für Touch-Targets nach Material Design (48x48dp)
  static const double minTouchTargetSize = 48.0;

  /// Empfohlene Mindestgröße für Touch-Targets (44x44dp für iOS)
  static const double recommendedTouchTargetSize = 44.0;

  /// Prüft, ob der Bold Text Modus aktiviert ist
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Prüft, ob der High Contrast Modus aktiviert ist
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Prüft, ob Animationen reduziert werden sollen
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Gibt die Text-Skalierung zurück
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Announcements für Screen Reader
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Berechnet die minimale Touch-Target-Größe
  static Size getMinTouchTargetSize(BuildContext context) {
    // iOS bevorzugt 44x44, Android 48x48
    return const Size(minTouchTargetSize, minTouchTargetSize);
  }
}

/// Wrapper-Widget für Touch-Targets mit minimaler Größe
///
/// Stellt sicher, dass das Kind mindestens die empfohlene Touch-Target-Größe hat
class AccessibleTouchTarget extends StatelessWidget {
  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.minSize = Accessibility.minTouchTargetSize,
  });

  final Widget child;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
}

/// Semantisch verbesserter Button
///
/// Fügt automatisch Semantik-Labels und Touch-Target-Größe hinzu
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget button = child;

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: onPressed != null,
        child: button,
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return AccessibleTouchTarget(child: button);
  }
}

/// Heading Widget für bessere Semantik
///
/// Markiert Text als Überschrift für Screen Reader
class AccessibleHeading extends StatelessWidget {
  const AccessibleHeading({
    super.key,
    required this.child,
    this.level = 1,
  });

  final Widget child;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: child,
    );
  }
}

/// Fokus-Highlight-Modus für Tastaturnavigation
class FocusHighlight extends StatelessWidget {
  const FocusHighlight({
    super.key,
    required this.child,
    this.borderRadius,
    this.color,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              border: hasFocus
                  ? Border.all(
                      color: effectiveColor,
                      width: 2,
                    )
                  : null,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// Skip-Link für Tastaturnavigation
///
/// Ermöglicht es Tastaturnutzern, direkt zu Hauptinhalten zu springen
class SkipLink extends StatelessWidget {
  const SkipLink({
    super.key,
    required this.targetKey,
    required this.label,
  });

  final GlobalKey targetKey;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;

            if (!hasFocus) {
              return const SizedBox.shrink();
            }

            return Material(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  final targetContext = targetKey.currentContext;
                  if (targetContext != null) {
                    Scrollable.ensureVisible(
                      targetContext,
                      duration: const Duration(milliseconds: 300),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(label),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Live Region für dynamische Inhalte
///
/// Informiert Screen Reader über Änderungen
class LiveRegion extends StatelessWidget {
  const LiveRegion({
    super.key,
    required this.child,
    this.politeness = Assertiveness.polite,
  });

  final Widget child;
  final Assertiveness politeness;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: child,
    );
  }
}
