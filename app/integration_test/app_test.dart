import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:personal_tracker/core/di/injection.dart';
import 'package:personal_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:personal_tracker/features/finance/presentation/pages/finance_page.dart';
import 'package:personal_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:personal_tracker/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Initialize DI once for all tests
  setUpAll(() {
    configureDependencies();
  });

  group('End-to-end test', () {
    testWidgets('App startup and basic navigation', (tester) async {
      // Start app
      await tester.pumpWidget(const PersonalTrackerApp());
      await tester.pumpAndSettle();

      // Verify app starts on Dashboard
      expect(find.byType(DashboardPage), findsOneWidget);

      // Verify NavigationBar is present
      expect(find.byType(NavigationBar), findsOneWidget);

      // Navigate to Finance via bottom navigation
      final financeNavButton =
          find.widgetWithIcon(NavigationDestination, Icons.account_balance_wallet);
      await tester.tap(financeNavButton);
      await tester.pumpAndSettle();

      // Verify we're on Finance page
      expect(find.byType(FinancePage), findsOneWidget);

      // Navigate back to Dashboard
      final dashboardNavButton =
          find.widgetWithIcon(NavigationDestination, Icons.dashboard);
      await tester.tap(dashboardNavButton);
      await tester.pumpAndSettle();

      // Verify we're back on Dashboard
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('Multiple navigation actions', (tester) async {
      // Start app
      await tester.pumpWidget(const PersonalTrackerApp());
      await tester.pumpAndSettle();

      // Navigate through all bottom navigation items
      final notesNavButton =
          find.widgetWithIcon(NavigationDestination, Icons.note);
      await tester.tap(notesNavButton);
      await tester.pumpAndSettle();

      final tasksNavButton =
          find.widgetWithIcon(NavigationDestination, Icons.check_box);
      await tester.tap(tasksNavButton);
      await tester.pumpAndSettle();

      // Navigate back to dashboard
      final dashboardNavButton =
          find.widgetWithIcon(NavigationDestination, Icons.dashboard);
      await tester.tap(dashboardNavButton);
      await tester.pumpAndSettle();

      // Verify we're on Dashboard
      expect(find.byType(DashboardPage), findsOneWidget);
    });
  });
}
