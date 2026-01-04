import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';

/// Notizen
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notes)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.notes,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.implementedInMilestone('3')),
          ],
        ),
      ),
    );
  }
}
