import 'package:flutter/material.dart';

import '../../models/pillar.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';
import 'progress_bar.dart';

class PillarCard extends StatelessWidget {
  const PillarCard({
    required this.pillar,
    this.showSuggestedAction = true,
    super.key,
  });

  final Pillar pillar;
  final bool showSuggestedAction;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(pillar.percentage);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFor(pillar.id), color: statusColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    pillar.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${pillar.percentage.round()}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              pillar.status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ProgressBar(percentage: pillar.percentage, color: statusColor),
            if (showSuggestedAction) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_forward_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(pillar.suggestedAction)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(double percentage) {
    if (percentage >= 80) {
      return AppColors.success;
    }
    if (percentage >= 55) {
      return AppColors.warning;
    }
    return AppColors.error;
  }

  IconData _iconFor(String id) {
    return switch (id) {
      'sleep' => Icons.bedtime_outlined,
      'nutrition' => Icons.water_drop_outlined,
      'movement' => Icons.directions_walk_outlined,
      _ => Icons.circle_outlined,
    };
  }
}
