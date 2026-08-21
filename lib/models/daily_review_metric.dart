class DailyReviewMetric {
  const DailyReviewMetric({
    required this.id,
    required this.title,
    required this.score,
    required this.createdAt,
    required this.updatedAt,
    this.linkedMetricId,
    this.pillarId,
  });

  static const maxTitleLength = 80;
  static const minScore = 1;
  static const maxScore = 10;
  static const defaultScore = 5;
  static const _unset = Object();

  final String id;
  final String title;
  final int score;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? linkedMetricId;
  final String? pillarId;

  factory DailyReviewMetric.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final updatedAt = _dateTimeFromJson(json['updatedAt']);
    final createdAt = _dateTimeFromJson(json['createdAt']) ?? updatedAt ?? now;
    final id = json['id'] as String? ?? '';

    return DailyReviewMetric(
      id: id,
      title: json['title'] as String? ?? '',
      score: _scoreFromJson(json['score']),
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      linkedMetricId: json['linkedMetricId'] as String?,
      pillarId: json['pillarId'] as String? ?? _legacyPillarId(id),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'score': score,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'linkedMetricId': linkedMetricId,
      'pillarId': pillarId,
    };
  }

  DailyReviewMetric copyWith({
    String? id,
    String? title,
    int? score,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? linkedMetricId = _unset,
    Object? pillarId = _unset,
  }) {
    return DailyReviewMetric(
      id: id ?? this.id,
      title: title ?? this.title,
      score: _normalizeScore(score ?? this.score),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      linkedMetricId: identical(linkedMetricId, _unset)
          ? this.linkedMetricId
          : linkedMetricId as String?,
      pillarId: identical(pillarId, _unset)
          ? this.pillarId
          : pillarId as String?,
    );
  }

  static int _scoreFromJson(Object? value) {
    if (value is num) {
      return _normalizeScore(value.round());
    }
    return defaultScore;
  }

  static int _normalizeScore(int value) {
    return value.clamp(minScore, maxScore);
  }

  static DateTime? _dateTimeFromJson(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static String? _legacyPillarId(String metricId) {
    const mappings = {
      'energy': 'nutrition',
      'discipline': 'movement',
      'recovery': 'sleep',
    };
    return mappings[metricId];
  }
}
