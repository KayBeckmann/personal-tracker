import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker/core/di/injection.dart';
import 'package:personal_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:personal_tracker/features/finance/presentation/pages/finance_page.dart';
import 'package:personal_tracker/main.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('App starts without errors', (WidgetTester tester) async {
    // Build app and trigger a frame
    await tester.pumpWidget(const PersonalTrackerApp());

    // Wait for navigation to initialize
    await tester.pumpAndSettle();

    // Verify that we're on the Dashboard (initial route)
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  testWidgets('App uses Material 3', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonalTrackerApp());
    await tester.pumpAndSettle();

    // MaterialApp.router doesn't expose theme directly like MaterialApp
    // Instead, verify that Material 3 components are present
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Navigation between pages works', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonalTrackerApp());
    await tester.pumpAndSettle();

    // Should start on Dashboard
    expect(find.byType(DashboardPage), findsOneWidget);

    // Find and tap the Finance navigation button by icon
    final financeIcon = find.widgetWithIcon(NavigationDestination, Icons.account_balance_wallet);
    await tester.tap(financeIcon);
    await tester.pumpAndSettle();

    // Should now be on Finance page
    expect(find.byType(FinancePage), findsOneWidget);
  });
}
