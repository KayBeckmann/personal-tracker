import 'package:flutter/material.dart';

/// Responsive Layout nach Material Design 3 Guidelines
///
/// Definiert Breakpoints für verschiedene Bildschirmgrößen:
/// - Compact: < 600dp (Telefone)
/// - Medium: 600-840dp (Tablets im Hochformat, faltbare Geräte)
/// - Expanded: > 840dp (Tablets im Querformat, Desktop)
class Responsive {
  const Responsive._();

  /// Compact Breakpoint (Telefone)
  static const double compactBreakpoint = 600;

  /// Medium Breakpoint (Tablets)
  static const double mediumBreakpoint = 840;

  /// Prüft, ob die Bildschirmbreite compact ist (< 600dp)
  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < compactBreakpoint;
  }

  /// Prüft, ob die Bildschirmbreite medium ist (600-840dp)
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= compactBreakpoint && width < mediumBreakpoint;
  }

  /// Prüft, ob die Bildschirmbreite expanded ist (> 840dp)
  static bool isExpanded(BuildContext context) {
    return MediaQuery.of(context).size.width >= mediumBreakpoint;
  }

  /// Gibt die aktuelle WindowSize zurück
  static WindowSize getWindowSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < compactBreakpoint) {
      return WindowSize.compact;
    } else if (width < mediumBreakpoint) {
      return WindowSize.medium;
    } else {
      return WindowSize.expanded;
    }
  }

  /// Gibt einen Wert basierend auf der Bildschirmgröße zurück
  ///
  /// ```dart
  /// final columns = Responsive.value(
  ///   context: context,
  ///   compact: 1,
  ///   medium: 2,
  ///   expanded: 3,
  /// );
  /// ```
  static T value<T>({
    required BuildContext context,
    required T compact,
    T? medium,
    T? expanded,
  }) {
    final windowSize = getWindowSize(context);
    switch (windowSize) {
      case WindowSize.compact:
        return compact;
      case WindowSize.medium:
        return medium ?? compact;
      case WindowSize.expanded:
        return expanded ?? medium ?? compact;
    }
  }

  /// Berechnet die Anzahl der Spalten für ein GridView
  static int getGridColumns(BuildContext context, {int? compact, int? medium, int? expanded}) {
    return value(
      context: context,
      compact: compact ?? 1,
      medium: medium ?? 2,
      expanded: expanded ?? 3,
    );
  }

  /// Berechnet die maximale Breite für Content-Container
  ///
  /// Nach Material Design Guidelines:
  /// - Compact: Volle Breite
  /// - Medium: 840dp
  /// - Expanded: 1200dp
  static double getMaxContentWidth(BuildContext context) {
    return value(
      context: context,
      compact: double.infinity,
      medium: 840,
      expanded: 1200,
    );
  }

  /// Berechnet horizontale Polsterung
  static double getHorizontalPadding(BuildContext context) {
    return value(
      context: context,
      compact: 16,
      medium: 24,
      expanded: 32,
    );
  }

  /// Berechnet vertikale Polsterung
  static double getVerticalPadding(BuildContext context) {
    return value(
      context: context,
      compact: 16,
      medium: 20,
      expanded: 24,
    );
  }
}

/// Window Size Classes nach Material Design 3
enum WindowSize {
  /// Compact: < 600dp (Telefone)
  compact,

  /// Medium: 600-840dp (Tablets im Hochformat)
  medium,

  /// Expanded: > 840dp (Tablets im Querformat, Desktop)
  expanded,
}

/// Extension für einfachere WindowSize Checks
extension WindowSizeExtension on WindowSize {
  bool get isCompact => this == WindowSize.compact;
  bool get isMedium => this == WindowSize.medium;
  bool get isExpanded => this == WindowSize.expanded;
}

/// Responsive Container mit maximaler Breite
///
/// Zentriert den Content und begrenzt die Breite basierend auf der Bildschirmgröße
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? Responsive.getMaxContentWidth(context);
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: Responsive.getHorizontalPadding(context),
          vertical: Responsive.getVerticalPadding(context),
        );

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}

/// Responsive Grid mit automatischer Spaltenanzahl
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.compactColumns = 1,
    this.mediumColumns = 2,
    this.expandedColumns = 3,
    this.spacing = 16,
    this.runSpacing,
  });

  final List<Widget> children;
  final int compactColumns;
  final int mediumColumns;
  final int expandedColumns;
  final double spacing;
  final double? runSpacing;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.getGridColumns(
      context,
      compact: compactColumns,
      medium: mediumColumns,
      expanded: expandedColumns,
    );

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing ?? spacing,
      children: children,
    );
  }
}
