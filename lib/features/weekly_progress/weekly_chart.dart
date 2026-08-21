import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/progress_bar.dart';
import '../../models/weekly_progress.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({required this.progress, super.key});

  final WeeklyProgress progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            for (
              var index = 0;
              index < progress.dailyRoutinePercentages.length;
              index++
            )
              Padding(
                padding: EdgeInsets.only(
                  bottom: index == progress.dailyRoutinePercentages.length - 1
                      ? 0
                      : AppSpacing.md,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 46,
                      child: Text(
                        progress.dayLabels[index],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProgressBar(
                            percentage: progress.dailyRoutinePercentages[index],
                            showValue: true,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${progress.dailyCompletedTasks[index]}/'
                            '${progress.dailyTotalTasks[index]} tareas',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
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
