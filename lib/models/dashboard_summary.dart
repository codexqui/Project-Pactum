import 'pillar.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.dateKey,
    required this.dayScore,
    required this.reviewAverage,
    required this.totalReviewMetrics,
    required this.routineProgress,
    required this.completedTasks,
    required this.totalTasks,
    required this.pillars,
    this.lastUpdated,
  });

  final String dateKey;
  final double dayScore;
  final double reviewAverage;
  final int totalReviewMetrics;
  final double routineProgress;
  final int completedTasks;
  final int totalTasks;
  final List<Pillar> pillars;
  final DateTime? lastUpdated;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      dateKey: json['dateKey'] as String? ?? '',
      dayScore: (json['dayScore'] as num?)?.toDouble() ?? 0,
      reviewAverage: (json['reviewAverage'] as num?)?.toDouble() ?? 0,
      totalReviewMetrics: (json['totalReviewMetrics'] as num?)?.toInt() ?? 0,
      routineProgress: (json['routineProgress'] as num?)?.toDouble() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      pillars: (json['pillars'] as List<dynamic>? ?? const [])
          .map(
            (value) => Pillar.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'dayScore': dayScore,
      'reviewAverage': reviewAverage,
      'totalReviewMetrics': totalReviewMetrics,
      'routineProgress': routineProgress,
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'pillars': pillars.map((pillar) => pillar.toJson()).toList(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  DashboardSummary copyWith({
    String? dateKey,
    double? dayScore,
    double? reviewAverage,
    int? totalReviewMetrics,
    double? routineProgress,
    int? completedTasks,
    int? totalTasks,
    List<Pillar>? pillars,
    DateTime? lastUpdated,
  }) {
    return DashboardSummary(
      dateKey: dateKey ?? this.dateKey,
      dayScore: dayScore ?? this.dayScore,
      reviewAverage: reviewAverage ?? this.reviewAverage,
      totalReviewMetrics: totalReviewMetrics ?? this.totalReviewMetrics,
      routineProgress: routineProgress ?? this.routineProgress,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      pillars: pillars ?? this.pillars,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
