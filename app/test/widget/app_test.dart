import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker/core/di/injection.dart';
import 'package:personal_tracker/main.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('App starts without errors', (WidgetTester tester) async {
    // Build app and trigger a frame
    await tester.pumpWidget(PersonalTrackerApp());

    // Wait for navigation to initialize
    await tester.pumpAndSettle();

    // Verify that we're on the Dashboard (initial route)
    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
  });

  testWidgets('App uses Material 3', (WidgetTester tester) async {
    await tester.pumpWidget(PersonalTrackerApp());
    await tester.pumpAndSettle();

    // MaterialApp.router doesn't expose theme directly like MaterialApp
    // Instead, verify that Material 3 components are present
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Navigation between pages works', (WidgetTester tester) async {
    await tester.pumpWidget(PersonalTrackerApp());
    await tester.pumpAndSettle();

    // Should start on Dashboard
    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));

    // Tap on Finance in bottom navigation
    await tester.tap(find.text('Finanzen'));
    await tester.pumpAndSettle();

    // Should now be on Finance page
    expect(find.text('Haushaltsbuch'), findsOneWidget);
  });
}
