import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../models/daily_review_metric.dart';
import 'review_metric_slider.dart';

class ReviewMetricTile extends StatelessWidget {
  const ReviewMetricTile({
    required this.metric,
    required this.index,
    required this.onScoreChanged,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DailyReviewMetric metric;
  final int index;
  final ValueChanged<int> onScoreChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: IconButton(
                tooltip: 'Reordenar',
                icon: const Icon(Icons.drag_handle),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          metric.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Editar categoría',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        tooltip: 'Eliminar categoría',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                  ReviewMetricSlider(
                    value: metric.score,
                    onChanged: onScoreChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
