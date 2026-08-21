import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/async_state_views.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pillar_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/score_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/stat_card.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return dashboard.when(
      data: (summary) => AppPage(
        title: 'Project Pactum',
        subtitle: 'Control diario',
        children: [
          ScoreCard(
            score: summary.dayScore,
            label: 'Puntaje del día',
            description: 'Revisión diaria y cumplimiento de rutina.',
          ),
          if (summary.lastUpdated == null) ...[
            const SizedBox(height: AppSpacing.md),
            const EmptyState(
              message:
                  'Completa tu revisión o rutina para iniciar el registro.',
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Abrir revisión diaria',
            icon: Icons.edit_note_outlined,
            onPressed: () => context.go('/review'),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionTitle('Resumen de pilares'),
          const SizedBox(height: AppSpacing.md),
          for (final pillar in summary.pillars) ...[
            PillarCard(pillar: pillar, showSuggestedAction: false),
            const SizedBox(height: AppSpacing.md),
          ],
          StatCard(
            title: 'Revisión diaria',
            value:
                '${summary.reviewAverage.toStringAsFixed(1)}/10 · '
                '${summary.totalReviewMetrics} categorías',
            icon: Icons.rate_review_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          StatCard(
            title: 'Rutina diaria',
            value:
                '${summary.routineProgress.round()}% · '
                '${summary.completedTasks}/${summary.totalTasks}',
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Última actualización: '
            '${DateFormatters.lastUpdated(summary.lastUpdated)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      loading: LoadingView.new,
      error: (error, stackTrace) => ErrorView(
        message: 'No se pudo cargar el inicio.',
        onRetry: () => ref.invalidate(dashboardProvider),
      ),
    );
  }
}
