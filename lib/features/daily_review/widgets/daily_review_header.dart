import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/progress_bar.dart';

class DailyReviewHeader extends StatelessWidget {
  const DailyReviewHeader({
    required this.average,
    required this.totalMetrics,
    required this.totalScore,
    super.key,
  });

  final double average;
  final int totalMetrics;
  final int totalScore;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Promedio diario',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${average.toStringAsFixed(1)}/10',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              totalMetrics == 0
                  ? 'Agrega categorías para construir tu revisión.'
                  : '$totalScore puntos en $totalMetrics categorías.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ProgressBar(percentage: average * 10, showValue: true),
          ],
        ),
      ),
    );
  }
}
