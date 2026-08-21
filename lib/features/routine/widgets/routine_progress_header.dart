import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/progress_bar.dart';

class RoutineProgressHeader extends StatelessWidget {
  const RoutineProgressHeader({
    required this.completed,
    required this.total,
    required this.percentage,
    super.key,
  });

  final int completed;
  final int total;
  final double percentage;

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
                    'Progreso diario',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('$completed/$total'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              total == 0
                  ? 'Agrega tareas para empezar a medir tu rutina.'
                  : 'Calculado con tus tareas reales de hoy.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ProgressBar(percentage: percentage, showValue: true),
          ],
        ),
      ),
    );
  }
}
