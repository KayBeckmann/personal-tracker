import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../domain/usecases/get_projected_end_of_month_capital.dart';
import '../../domain/usecases/get_total_capital.dart';

/// Widget zur Anzeige des voraussichtlichen Kapitals am Monatsende
class ProjectedCapitalCard extends StatelessWidget {
  const ProjectedCapitalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final getProjected = getIt<GetProjectedEndOfMonthCapital>();
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
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prognose Monatsende',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<double>(
              future: getProjected(),
              builder: (context, projectedSnapshot) {
                if (projectedSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final projected = projectedSnapshot.data ?? 0.0;

                return StreamBuilder<double>(
                  stream: getTotalCapital.watch(),
                  builder: (context, currentSnapshot) {
                    final current = currentSnapshot.data ?? 0.0;
                    final difference = projected - current;
                    final isPositive = difference >= 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currencyFormat.format(projected),
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 16,
                              color: isPositive
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currencyFormat.format(difference.abs()),
                              style: TextStyle(
                                color: isPositive
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'bis Monatsende',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
