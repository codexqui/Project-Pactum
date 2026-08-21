import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_key.dart';
import '../models/daily_review.dart';
import '../models/daily_review_metric.dart';
import 'dashboard_provider.dart';
import 'pillars_provider.dart';
import 'repository_providers.dart';
import 'weekly_progress_provider.dart';

final dailyReviewProvider =
    AsyncNotifierProvider<DailyReviewController, DailyReviewState>(
      DailyReviewController.new,
    );

class DailyReviewState {
  const DailyReviewState({required this.review});

  final DailyReview review;

  List<DailyReviewMetric> get metrics => review.metrics;

  bool get isEmpty => metrics.isEmpty;

  int get totalMetrics => metrics.length;

  int get totalScore => review.totalScore;

  double get average => DailyReview.calculateAverage(metrics);

  DailyReviewState copyWith({DailyReview? review}) {
    return DailyReviewState(review: review ?? this.review);
  }
}

class DailyReviewController extends AsyncNotifier<DailyReviewState> {
  @override
  Future<DailyReviewState> build() async {
    final review = await ref
        .read(dailyReviewRepositoryProvider)
        .loadForDate(DateTime.now());
    return DailyReviewState(review: review);
  }

  Future<void> addMetric(String title) async {
    final normalizedTitle = _normalizeTitle(title);
    final now = DateTime.now();
    final metric = DailyReviewMetric(
      id: _generateMetricId(now),
      title: normalizedTitle,
      score: DailyReviewMetric.defaultScore,
      createdAt: now,
      updatedAt: now,
    );

    await _persistMetricsOptimistically(
      (metrics) => [...metrics, metric],
      () => ref.read(dailyReviewRepositoryProvider).addMetric(metric),
    );
  }

  Future<void> editMetric({
    required String metricId,
    required String title,
  }) async {
    final normalizedTitle = _normalizeTitle(title);
    final currentMetrics = await _currentMetrics();
    final current = currentMetrics.firstWhere(
      (metric) => metric.id == metricId,
      orElse: () => throw StateError('La categoría ya no existe.'),
    );
    final updatedMetric = current.copyWith(
      title: normalizedTitle,
      updatedAt: DateTime.now(),
    );

    await _persistMetricsOptimistically(
      (metrics) => metrics
          .map((metric) => metric.id == metricId ? updatedMetric : metric)
          .toList(growable: false),
      () => ref.read(dailyReviewRepositoryProvider).updateMetric(updatedMetric),
    );
  }

  Future<void> deleteMetric(String metricId) async {
    await _persistMetricsOptimistically(
      (metrics) => metrics
          .where((metric) => metric.id != metricId)
          .toList(growable: false),
      () => ref.read(dailyReviewRepositoryProvider).deleteMetric(metricId),
    );
  }

  Future<void> updateScore(String metricId, int score) async {
    await _persistMetricsOptimistically(
      (metrics) => metrics
          .map(
            (metric) => metric.id == metricId
                ? metric.copyWith(score: score, updatedAt: DateTime.now())
                : metric,
          )
          .toList(growable: false),
      () =>
          ref.read(dailyReviewRepositoryProvider).updateScore(metricId, score),
    );
  }

  Future<void> reorderMetrics(int oldIndex, int newIndex) async {
    await _persistMetricsOptimistically(
      (metrics) {
        final updated = [...metrics];
        final metric = updated.removeAt(oldIndex);
        final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
        updated.insert(
          adjustedIndex,
          metric.copyWith(updatedAt: DateTime.now()),
        );
        return updated;
      },
      () => ref
          .read(dailyReviewRepositoryProvider)
          .reorderMetrics(oldIndex, newIndex),
    );
  }

  Future<void> saveReview() async {
    final repository = ref.read(dailyReviewRepositoryProvider);
    final now = DateTime.now();
    final review = DailyReview.fromMetrics(
      date: now,
      metrics: _current.metrics,
      updatedAt: now,
    ).copyWith(dateKey: DateKey.today());

    try {
      await repository.saveReview(review);
      state = AsyncData(DailyReviewState(review: review));
      _refreshDerivedProviders();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  double getAverage() {
    return state.asData?.value.average ?? 0;
  }

  int getTotalMetrics() {
    return state.asData?.value.totalMetrics ?? 0;
  }

  DailyReviewState get _current {
    return state.asData?.value ??
        DailyReviewState(review: DailyReview.initial());
  }

  Future<List<DailyReviewMetric>> _currentMetrics() async {
    return state.asData?.value.metrics ??
        ref.read(dailyReviewRepositoryProvider).getMetrics();
  }

  Future<void> _persistMetricsOptimistically(
    List<DailyReviewMetric> Function(List<DailyReviewMetric> metrics)
    updateLocalMetrics,
    Future<List<DailyReviewMetric>> Function() persist,
  ) async {
    final previous = _current;
    final optimisticMetrics = updateLocalMetrics(previous.metrics);
    final optimisticReview = previous.review.copyWith(
      metrics: optimisticMetrics,
      averageScore: DailyReview.calculateAverage(optimisticMetrics),
    );
    state = AsyncData(DailyReviewState(review: optimisticReview));

    try {
      final persisted = await persist();
      final nextReview = previous.review.copyWith(
        metrics: persisted,
        averageScore: DailyReview.calculateAverage(persisted),
      );
      state = AsyncData(DailyReviewState(review: nextReview));
      _refreshDerivedProviders();
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  String _normalizeTitle(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('El nombre de la categoría no puede estar vacío.');
    }
    if (normalized.length > DailyReviewMetric.maxTitleLength) {
      throw ArgumentError(
        'El nombre de la categoría no puede superar '
        '${DailyReviewMetric.maxTitleLength} caracteres.',
      );
    }
    return normalized;
  }

  String _generateMetricId(DateTime now) {
    final random = Random().nextInt(1 << 32);
    return 'metric_${now.microsecondsSinceEpoch}_$random';
  }

  void _refreshDerivedProviders() {
    ref.invalidate(dashboardProvider);
    ref.invalidate(pillarsProvider);
    ref.invalidate(weeklyProgressProvider);
  }
}
