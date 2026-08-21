import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import 'progress_bar.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    required this.score,
    required this.label,
    required this.description,
    super.key,
  });

  final double score;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(label, style: textTheme.titleLarge)),
                const SizedBox(width: AppSpacing.md),
                Text(
                  score.round().toString(),
                  style: textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ProgressBar(percentage: score),
          ],
        ),
      ),
    );
  }
}
