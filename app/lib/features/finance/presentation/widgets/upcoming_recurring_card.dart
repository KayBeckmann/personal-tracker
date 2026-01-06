import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_upcoming_recurring_transactions.dart';

/// Widget zur Anzeige anstehender Daueraufträge
class UpcomingRecurringCard extends StatelessWidget {
  const UpcomingRecurringCard({super.key});

  @override
  Widget build(BuildContext context) {
    final getUpcoming = getIt<GetUpcomingRecurringTransactions>();
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
                  Icons.repeat,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Anstehende Daueraufträge',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<RecurringTransactionWithNextDate>>(
              stream: getUpcoming.watch(limit: 5),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final upcoming = snapshot.data ?? [];

                if (upcoming.isEmpty) {
                  return Text(
                    'Keine anstehenden Daueraufträge',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  );
                }

                return Column(
                  children: upcoming.map((item) {
                    final r = item.recurring;
                    final isIncome = r.type.name == 'income';
                    final amount = isIncome ? r.amount : -r.amount;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.error,
                      ),
                      title: Text(r.payee ?? r.description ?? 'Dauerauftrag'),
                      subtitle: Text(dateFormat.format(item.nextDueDate)),
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
