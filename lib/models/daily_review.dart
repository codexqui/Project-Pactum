import '../core/utils/date_key.dart';
import 'daily_review_metric.dart';

class DailyReview {
  const DailyReview({
    required this.dateKey,
    required this.metrics,
    required this.averageScore,
    this.updatedAt,
  });

  static const _unset = Object();

  final String dateKey;
  final List<DailyReviewMetric> metrics;
  final double averageScore;
  final DateTime? updatedAt;

  factory DailyReview.initial({
    DateTime? date,
    List<DailyReviewMetric> metrics = const [],
  }) {
    return DailyReview(
      dateKey: DateKey.fromDate(date ?? DateTime.now()),
      metrics: metrics,
      averageScore: calculateAverage(metrics),
    );
  }

  factory DailyReview.fromMetrics({
    required DateTime date,
    required List<DailyReviewMetric> metrics,
    DateTime? updatedAt,
  }) {
    return DailyReview(
      dateKey: DateKey.fromDate(date),
      metrics: metrics,
      averageScore: calculateAverage(metrics),
      updatedAt: updatedAt,
    );
  }

  factory DailyReview.fromJson(Map<String, dynamic> json) {
    final metricsJson = json['metrics'];
    final legacyMetrics = _legacyMetricsFromJson(json);
    final metrics = metricsJson is List<dynamic>
        ? metricsJson
              .whereType<Map>()
              .map(
                (value) => DailyReviewMetric.fromJson(
                  Map<String, dynamic>.from(value),
                ),
              )
              .where((metric) => metric.id.trim().isNotEmpty)
              .toList(growable: false)
        : legacyMetrics;

    return DailyReview(
      dateKey: json['dateKey'] as String? ?? DateKey.today(),
      metrics: metrics,
      averageScore:
          (json['averageScore'] as num?)?.toDouble() ??
          calculateAverage(metrics),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
    );
  }

  bool get hasBeenSaved => updatedAt != null;

  int get totalMetrics => metrics.length;

  int get totalScore =>
      metrics.fold(0, (total, metric) => total + metric.score);

  double get averageValue {
    if (metrics.isEmpty) {
      return 0;
    }
    return averageScore.clamp(0, 10);
  }

  double get averagePercentage => (averageValue * 10).clamp(0, 100);

  int get energy => _legacyScore('energy');

  int get discipline => _legacyScore('discipline');

  int get focus => _legacyScore('focus');

  int get recovery => _legacyScore('recovery');

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'metrics': metrics.map((metric) => metric.toJson()).toList(),
      'averageScore': averageValue,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  DailyReview copyWith({
    String? dateKey,
    List<DailyReviewMetric>? metrics,
    double? averageScore,
    Object? updatedAt = _unset,
  }) {
    final nextMetrics = metrics ?? this.metrics;
    return DailyReview(
      dateKey: dateKey ?? this.dateKey,
      metrics: nextMetrics,
      averageScore: averageScore ?? calculateAverage(nextMetrics),
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  int _legacyScore(String metricId) {
    final metric = metrics.where((candidate) => candidate.id == metricId);
    return metric.isEmpty ? 0 : metric.first.score;
  }

  static double calculateAverage(List<DailyReviewMetric> metrics) {
    if (metrics.isEmpty) {
      return 0;
    }
    final total = metrics.fold<int>(0, (sum, metric) => sum + metric.score);
    return (total / metrics.length).clamp(0, 10);
  }

  static List<DailyReviewMetric> _legacyMetricsFromJson(
    Map<String, dynamic> json,
  ) {
    final updatedAt = _dateTimeFromJson(json['updatedAt']);
    final createdAt = updatedAt ?? DateTime.now();
    final legacy = [
      _legacyMetric(
        id: 'energy',
        title: 'Energía',
        score: json['energy'],
        pillarId: 'nutrition',
        createdAt: createdAt,
        updatedAt: updatedAt ?? createdAt,
      ),
      _legacyMetric(
        id: 'discipline',
        title: 'Disciplina',
        score: json['discipline'],
        pillarId: 'movement',
        createdAt: createdAt,
        updatedAt: updatedAt ?? createdAt,
      ),
      _legacyMetric(
        id: 'focus',
        title: 'Enfoque',
        score: json['focus'],
        createdAt: createdAt,
        updatedAt: updatedAt ?? createdAt,
      ),
      _legacyMetric(
        id: 'recovery',
        title: 'Recuperación',
        score: json['recovery'],
        pillarId: 'sleep',
        createdAt: createdAt,
        updatedAt: updatedAt ?? createdAt,
      ),
    ];

    if (legacy.every((metric) => metric.score == 5) &&
        !json.containsKey('energy') &&
        !json.containsKey('discipline') &&
        !json.containsKey('focus') &&
        !json.containsKey('recovery')) {
      return const [];
    }

    return legacy;
  }

  static DailyReviewMetric _legacyMetric({
    required String id,
    required String title,
    required Object? score,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? pillarId,
  }) {
    return DailyReviewMetric(
      id: id,
      title: title,
      score: score is num ? score.round() : DailyReviewMetric.defaultScore,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pillarId: pillarId,
    );
  }

  static DateTime? _dateTimeFromJson(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
