import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/weekly_progress.dart';

class WeeklyStats extends StatelessWidget {
  const WeeklyStats({required this.progress, super.key});

  final WeeklyProgress progress;

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(
        title: 'Promedio de rutina',
        value: '${progress.routineAverage.round()}%',
        icon: Icons.checklist_outlined,
      ),
      StatCard(
        title: 'Promedio de pilares',
        value: '${progress.pillarAverage.round()}%',
        icon: Icons.account_balance_outlined,
      ),
      StatCard(
        title: 'Días completos',
        value: '${progress.completedDays}/7',
        icon: Icons.event_available_outlined,
      ),
    ];

    if (MediaQuery.sizeOf(context).width < AppLayout.compactWidth) {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: AppSpacing.md),
          cards[1],
          const SizedBox(height: AppSpacing.md),
          cards[2],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: cards[1]),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: cards[2]),
      ],
    );
  }
}
