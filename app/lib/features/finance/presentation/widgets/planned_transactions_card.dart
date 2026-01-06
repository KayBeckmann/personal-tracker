import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_planned_transactions.dart';

/// Widget zur Anzeige geplanter Buchungen
class PlannedTransactionsCard extends StatelessWidget {
  const PlannedTransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final getPlanned = getIt<GetPlannedTransactions>();
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Geplante Buchungen',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: getPlanned.watch(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final planned = snapshot.data ?? [];

                if (planned.isEmpty) {
                  return Text(
                    'Keine geplanten Buchungen',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  );
                }

                // Zeige nur die nächsten 5
                final limited = planned.take(5).toList();

                return Column(
                  children: limited.map((t) {
                    final isIncome = t.type.name == 'income';
                    final amount = isIncome ? t.amount : -t.amount;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.error,
                      ),
                      title: Text(t.payee ?? t.description ?? 'Buchung'),
                      subtitle: Text(dateFormat.format(t.date)),
                      trailing: Text(
                        currencyFormat.format(amount),
                        style: TextStyle(
                          color: isIncome
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
