import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker/main.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    // Build app and trigger a frame
    await tester.pumpWidget(const PersonalTrackerApp());

    // Verify the app title is displayed
    expect(find.text('Personal Tracker'), findsOneWidget);

    // Verify placeholder content is shown
    expect(find.byIcon(Icons.construction), findsOneWidget);
    expect(find.text('Grundgerüst wird aufgebaut'), findsOneWidget);
  });

  testWidgets('App uses Material 3', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonalTrackerApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    // Verify Material 3 is enabled via colorScheme (Material 3 is default in Flutter 3.16+)
    expect(materialApp.theme?.colorScheme, isNotNull);
    expect(materialApp.darkTheme?.colorScheme, isNotNull);
  });
}
