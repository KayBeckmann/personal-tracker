import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_total_capital.dart';

/// Widget zur Anzeige der Gesamtkapitalsumme
class CapitalSummaryCard extends StatelessWidget {
  const CapitalSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final getTotalCapital = getIt<GetTotalCapital>();
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Gesamtkapital',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<double>(
              stream: getTotalCapital.watch(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final capital = snapshot.data ?? 0.0;
                final isNegative = capital < 0;

                return Text(
                  currencyFormat.format(capital),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isNegative
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
