import 'dart:convert';

import '../core/utils/date_key.dart';
import '../models/daily_review.dart';
import '../models/daily_review_metric.dart';
import '../services/local_storage_service.dart';

class DailyReviewRepository {
  const DailyReviewRepository(this.storageService);

  static const _reviewsKey = 'daily_reviews';
  static const _metricsKey = 'daily_review_metrics_template_v2';
  static const _draftPrefix = 'daily_review_metric_draft_';

  final LocalStorageService storageService;

  Future<List<DailyReviewMetric>> getMetrics() async {
    final template = await _loadTemplate();
    if (template.isEmpty) {
      return const [];
    }

    final today = DateTime.now();
    final draft = await _readMetrics(_draftKey(today));
    if (draft != null) {
      return _mergeTemplateWithScores(template, draft);
    }

    final storedToday = await _loadStoredForDate(today);
    final metrics = storedToday == null
        ? _resetScores(template)
        : _mergeTemplateWithScores(template, storedToday.metrics);
    await _writeMetrics(_draftKey(today), metrics);
    return metrics;
  }

  Future<List<DailyReviewMetric>> addMetric(DailyReviewMetric metric) async {
    _validateMetric(metric);
    final metrics = await getMetrics();
    if (metrics.any((candidate) => candidate.id == metric.id)) {
      throw StateError('Ya existe una categoría con el mismo identificador.');
    }

    final updated = [...metrics, metric.copyWith(title: metric.title.trim())];
    await _saveTemplateAndTodayDraft(updated);
    return updated;
  }

  Future<List<DailyReviewMetric>> updateMetric(DailyReviewMetric metric) async {
    _validateMetric(metric);
    final metrics = await getMetrics();
    final index = metrics.indexWhere((candidate) => candidate.id == metric.id);
    if (index == -1) {
      throw StateError('La categoría que intentas editar ya no existe.');
    }

    final current = metrics[index];
    final updatedMetric = metric.copyWith(
      title: metric.title.trim(),
      score: current.score,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    final updated = [...metrics]..[index] = updatedMetric;
    await _saveTemplateAndTodayDraft(updated);
    return updated;
  }

  Future<List<DailyReviewMetric>> deleteMetric(String metricId) async {
    final normalizedId = metricId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        metricId,
        'metricId',
        'El id no puede estar vacío.',
      );
    }

    final metrics = await getMetrics();
    if (!metrics.any((metric) => metric.id == normalizedId)) {
      throw StateError('La categoría que intentas eliminar ya no existe.');
    }

    final updated = metrics
        .where((metric) => metric.id != normalizedId)
        .toList(growable: false);
    await _saveTemplateAndTodayDraft(updated);
    return updated;
  }

  Future<List<DailyReviewMetric>> updateScore(
    String metricId,
    int score,
  ) async {
    final metrics = await getMetrics();
    final index = metrics.indexWhere((metric) => metric.id == metricId);
    if (index == -1) {
      throw StateError('La categoría que intentas actualizar ya no existe.');
    }

    final updated = [...metrics];
    updated[index] = metrics[index].copyWith(
      score: score,
      updatedAt: DateTime.now(),
    );
    await _writeMetrics(_draftKey(DateTime.now()), updated);
    return updated;
  }

  Future<List<DailyReviewMetric>> reorderMetrics(
    int oldIndex,
    int newIndex,
  ) async {
    final metrics = await getMetrics();
    if (oldIndex < 0 || oldIndex >= metrics.length) {
      throw RangeError.index(oldIndex, metrics, 'oldIndex');
    }
    if (newIndex < 0 || newIndex > metrics.length) {
      throw RangeError.index(newIndex, metrics, 'newIndex');
    }

    final updated = [...metrics];
    final metric = updated.removeAt(oldIndex);
    final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    updated.insert(adjustedIndex, metric.copyWith(updatedAt: DateTime.now()));
    await _saveTemplateAndTodayDraft(updated);
    return updated;
  }

  Future<DailyReview> loadForDate(DateTime date) async {
    if (DateKey.fromDate(date) == DateKey.today()) {
      final stored = await _loadStoredForDate(date);
      final metrics = await getMetrics();
      return DailyReview.fromMetrics(
        date: date,
        metrics: metrics,
        updatedAt: stored?.updatedAt,
      );
    }

    return await _loadStoredForDate(date) ?? DailyReview.initial(date: date);
  }

  Future<Map<String, DailyReview>> loadAll() async {
    return _loadStoredReviews();
  }

  Future<void> saveReview(DailyReview review) async {
    final normalized = review.copyWith(
      averageScore: DailyReview.calculateAverage(review.metrics),
    );
    _validateMetricList(normalized.metrics);

    final reviews = await _loadStoredReviews();
    reviews[normalized.dateKey] = normalized;

    final encoded = reviews.map((key, value) => MapEntry(key, value.toJson()));
    await storageService.writeString(_reviewsKey, jsonEncode(encoded));

    if (normalized.dateKey == DateKey.today()) {
      await _writeMetrics(_draftKey(DateTime.now()), normalized.metrics);
    }
  }

  Future<List<DailyReviewMetric>> _loadTemplate() async {
    final stored = await _readMetrics(_metricsKey);
    if (stored != null) {
      return stored;
    }

    final migrated = await _legacyTemplateFromSavedReviews();
    if (migrated.isNotEmpty) {
      await _writeMetrics(_metricsKey, _templateMetrics(migrated));
    }
    return migrated;
  }

  Future<DailyReview?> _loadStoredForDate(DateTime date) async {
    final reviews = await _loadStoredReviews();
    return reviews[DateKey.fromDate(date)];
  }

  Future<Map<String, DailyReview>> _loadStoredReviews() async {
    final rawJson = await storageService.readString(_reviewsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return {};
      }
      return decoded.map(
        (key, value) => MapEntry(
          key,
          DailyReview.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      );
    } on FormatException {
      return {};
    }
  }

  Future<List<DailyReviewMetric>> _legacyTemplateFromSavedReviews() async {
    final reviews = await _loadStoredReviews();
    if (reviews.isEmpty) {
      return const [];
    }

    final sorted = reviews.values.toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    return _templateMetrics(sorted.last.metrics);
  }

  Future<List<DailyReviewMetric>?> _readMetrics(String key) async {
    final rawJson = await storageService.readString(key);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List<dynamic>) {
        return const [];
      }

      final metrics = <DailyReviewMetric>[];
      final ids = <String>{};
      for (final value in decoded) {
        if (value is! Map) {
          continue;
        }
        final metric = DailyReviewMetric.fromJson(
          Map<String, dynamic>.from(value),
        );
        if (!_isValidMetric(metric) || !ids.add(metric.id)) {
          continue;
        }
        metrics.add(metric.copyWith(title: metric.title.trim()));
      }
      return metrics;
    } on FormatException {
      return const [];
    }
  }

  Future<void> _writeMetrics(String key, List<DailyReviewMetric> metrics) {
    _validateMetricList(metrics);
    final encoded = metrics
        .map((metric) => metric.toJson())
        .toList(growable: false);
    return storageService.writeString(key, jsonEncode(encoded));
  }

  Future<void> _saveTemplateAndTodayDraft(
    List<DailyReviewMetric> metrics,
  ) async {
    _validateMetricList(metrics);
    await _writeMetrics(_metricsKey, _templateMetrics(metrics));
    await _writeMetrics(_draftKey(DateTime.now()), metrics);
  }

  List<DailyReviewMetric> _mergeTemplateWithScores(
    List<DailyReviewMetric> template,
    List<DailyReviewMetric> scoredMetrics,
  ) {
    final scoresById = {for (final metric in scoredMetrics) metric.id: metric};
    return [
      for (final metric in template)
        metric.copyWith(
          score: scoresById[metric.id]?.score ?? metric.score,
          updatedAt: scoresById[metric.id]?.updatedAt ?? metric.updatedAt,
        ),
    ];
  }

  List<DailyReviewMetric> _resetScores(List<DailyReviewMetric> metrics) {
    return [
      for (final metric in metrics)
        metric.copyWith(score: DailyReviewMetric.defaultScore),
    ];
  }

  List<DailyReviewMetric> _templateMetrics(List<DailyReviewMetric> metrics) {
    return [
      for (final metric in metrics)
        metric.copyWith(score: DailyReviewMetric.defaultScore),
    ];
  }

  void _validateMetricList(List<DailyReviewMetric> metrics) {
    final ids = <String>{};
    for (final metric in metrics) {
      _validateMetric(metric);
      if (!ids.add(metric.id)) {
        throw StateError(
          'No se permiten identificadores de categoría duplicados.',
        );
      }
    }
  }

  void _validateMetric(DailyReviewMetric metric) {
    if (!_isValidMetric(metric)) {
      throw ArgumentError('La categoría contiene datos inválidos.');
    }
  }

  bool _isValidMetric(DailyReviewMetric metric) {
    final title = metric.title.trim();
    return metric.id.trim().isNotEmpty &&
        title.isNotEmpty &&
        title.length <= DailyReviewMetric.maxTitleLength &&
        metric.score >= DailyReviewMetric.minScore &&
        metric.score <= DailyReviewMetric.maxScore;
  }

  String _draftKey(DateTime date) {
    return '$_draftPrefix${DateKey.fromDate(date)}';
  }
}
