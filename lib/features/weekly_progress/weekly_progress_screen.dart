import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/async_state_views.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/score_card.dart';
import '../../core/widgets/section_title.dart';
import '../../models/weekly_progress.dart';
import '../../providers/weekly_progress_provider.dart';
import 'weekly_chart.dart';
import 'weekly_stats.dart';

class WeeklyProgressScreen extends ConsumerWidget {
  const WeeklyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(weeklyProgressProvider);

    return progress.when(
      data: _buildContent,
      loading: LoadingView.new,
      error: (error, stackTrace) => ErrorView(
        message: 'No se pudo cargar el progreso semanal.',
        onRetry: () => ref.invalidate(weeklyProgressProvider),
      ),
    );
  }

  Widget _buildContent(WeeklyProgress progress) {
    final hasData =
        progress.dailyScores.any((score) => score > 0) ||
        progress.dailyTotalTasks.any((total) => total > 0);

    return AppPage(
      title: 'Progreso semanal',
      subtitle: 'Resumen de los últimos 7 días',
      children: [
        ScoreCard(
          score: progress.weeklyAverage,
          label: 'Promedio semanal',
          description:
              'Revisión diaria y rutina real de los últimos siete días.',
        ),
        if (!hasData) ...[
          const SizedBox(height: AppSpacing.md),
          const EmptyState(
            message: 'Aún no hay actividad suficiente para evaluar la semana.',
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('Progreso de 7 días'),
        const SizedBox(height: AppSpacing.md),
        WeeklyChart(progress: progress),
        const SizedBox(height: AppSpacing.xl),
        WeeklyStats(progress: progress),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes_outlined),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(progress.observation)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
