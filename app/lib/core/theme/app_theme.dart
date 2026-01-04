import 'package:flutter/material.dart';

/// App-weite Theme-Definitionen
///
/// Enthält Light und Dark Theme basierend auf Material 3 (Material You).
class AppTheme {
  const AppTheme._();

  /// Basis-Seed-Farbe für das Farbschema
  static const Color _seedColor = Colors.blue;

  /// Light Theme
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        // Card-Design
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.all(8),
        ),
        // App Bar Design
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        // FAB Design
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
        // Input Fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      );

  /// Dark Theme
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        // Card-Design
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.all(8),
        ),
        // App Bar Design
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        // FAB Design
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
        // Input Fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      );
}
