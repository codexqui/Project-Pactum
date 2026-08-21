import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/async_state_views.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/daily_review_metric.dart';
import '../../providers/daily_review_provider.dart';
import 'widgets/add_metric_button.dart';
import 'widgets/daily_review_header.dart';
import 'widgets/empty_review_state.dart';
import 'widgets/metric_form_sheet.dart';
import 'widgets/review_metric_tile.dart';

class DailyReviewScreen extends ConsumerWidget {
  const DailyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(dailyReviewProvider);

    return review.when(
      data: (state) => AppPage(
        title: 'Revisión diaria',
        subtitle: 'Sistema de evaluación configurable',
        children: [
          DailyReviewHeader(
            average: state.average,
            totalMetrics: state.totalMetrics,
            totalScore: state.totalScore,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (state.isEmpty)
            EmptyReviewState(
              onCreateMetric: () => _openMetricForm(context, ref),
            )
          else ...[
            AddMetricButton(onPressed: () => _openMetricForm(context, ref)),
            const SizedBox(height: AppSpacing.xl),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: state.metrics.length,
              onReorder: (oldIndex, newIndex) {
                _reorderMetrics(context, ref, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final metric = state.metrics[index];
                return Padding(
                  key: ValueKey(metric.id),
                  padding: EdgeInsets.only(
                    bottom: index == state.metrics.length - 1
                        ? 0
                        : AppSpacing.md,
                  ),
                  child: ReviewMetricTile(
                    metric: metric,
                    index: index,
                    onScoreChanged: (score) {
                      _updateScore(context, ref, metric, score);
                    },
                    onEdit: () => _openMetricForm(context, ref, metric: metric),
                    onDelete: () => _confirmDelete(context, ref, metric),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Guardar revisión',
              icon: Icons.save_outlined,
              onPressed: () => _saveReview(context, ref),
            ),
          ],
        ],
      ),
      loading: LoadingView.new,
      error: (error, stackTrace) => ErrorView(
        message: 'No se pudo cargar la revisión diaria.',
        onRetry: () => ref.invalidate(dailyReviewProvider),
      ),
    );
  }

  Future<void> _openMetricForm(
    BuildContext context,
    WidgetRef ref, {
    DailyReviewMetric? metric,
  }) async {
    final result = await showModalBottomSheet<MetricFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => MetricFormSheet(initialMetric: metric),
    );

    if (result == null || !context.mounted) {
      return;
    }

    try {
      if (metric == null) {
        await ref.read(dailyReviewProvider.notifier).addMetric(result.title);
        if (context.mounted) {
          _showSnackBar(context, 'Categoría creada.');
        }
      } else {
        await ref
            .read(dailyReviewProvider.notifier)
            .editMetric(metricId: metric.id, title: result.title);
        if (context.mounted) {
          _showSnackBar(context, 'Categoría actualizada.');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'No se pudo guardar la categoría.');
      }
    }
  }

  Future<void> _updateScore(
    BuildContext context,
    WidgetRef ref,
    DailyReviewMetric metric,
    int score,
  ) async {
    if (metric.score == score) {
      return;
    }

    try {
      await ref
          .read(dailyReviewProvider.notifier)
          .updateScore(metric.id, score);
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'No se pudo actualizar la puntuación.');
      }
    }
  }

  Future<void> _reorderMetrics(
    BuildContext context,
    WidgetRef ref,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      await ref
          .read(dailyReviewProvider.notifier)
          .reorderMetrics(oldIndex, newIndex);
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'No se pudo reordenar la revisión.');
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DailyReviewMetric metric,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Eliminar "${metric.title}" de tu revisión diaria?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(dailyReviewProvider.notifier).deleteMetric(metric.id);
      if (context.mounted) {
        _showSnackBar(context, 'Categoría eliminada.');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'No se pudo eliminar la categoría.');
      }
    }
  }

  Future<void> _saveReview(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(dailyReviewProvider.notifier).saveReview();
      if (context.mounted) {
        _showSnackBar(context, 'Revisión guardada.');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'No se pudo guardar la revisión.');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
