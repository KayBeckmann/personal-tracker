import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';

/// Dashboard - Zentrale Übersicht
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboard)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.dashboard,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.implementedInMilestone('6')),
          ],
        ),
      ),
    );
  }
}
