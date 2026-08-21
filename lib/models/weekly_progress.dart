class WeeklyProgress {
  const WeeklyProgress({
    required this.dateKey,
    required this.dayLabels,
    required this.dailyScores,
    required this.dailyRoutinePercentages,
    required this.dailyCompletedTasks,
    required this.dailyTotalTasks,
    required this.weeklyAverage,
    required this.routineAverage,
    required this.pillarAverage,
    required this.completedDays,
    required this.observation,
    required this.updatedAt,
  });

  final String dateKey;
  final List<String> dayLabels;
  final List<double> dailyScores;
  final List<double> dailyRoutinePercentages;
  final List<int> dailyCompletedTasks;
  final List<int> dailyTotalTasks;
  final double weeklyAverage;
  final double routineAverage;
  final double pillarAverage;
  final int completedDays;
  final String observation;
  final DateTime updatedAt;

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      dateKey: json['dateKey'] as String? ?? '',
      dayLabels: (json['dayLabels'] as List<dynamic>? ?? const [])
          .map((label) => label.toString())
          .toList(),
      dailyScores: (json['dailyScores'] as List<dynamic>? ?? const [])
          .map((score) => (score as num).toDouble())
          .toList(),
      dailyRoutinePercentages:
          (json['dailyRoutinePercentages'] as List<dynamic>? ?? const [])
              .map((score) => (score as num).toDouble())
              .toList(),
      dailyCompletedTasks:
          (json['dailyCompletedTasks'] as List<dynamic>? ?? const [])
              .map((count) => (count as num).toInt())
              .toList(),
      dailyTotalTasks: (json['dailyTotalTasks'] as List<dynamic>? ?? const [])
          .map((count) => (count as num).toInt())
          .toList(),
      weeklyAverage: (json['weeklyAverage'] as num?)?.toDouble() ?? 0,
      routineAverage: (json['routineAverage'] as num?)?.toDouble() ?? 0,
      pillarAverage: (json['pillarAverage'] as num?)?.toDouble() ?? 0,
      completedDays: (json['completedDays'] as num?)?.toInt() ?? 0,
      observation: json['observation'] as String? ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'dayLabels': dayLabels,
      'dailyScores': dailyScores,
      'dailyRoutinePercentages': dailyRoutinePercentages,
      'dailyCompletedTasks': dailyCompletedTasks,
      'dailyTotalTasks': dailyTotalTasks,
      'weeklyAverage': weeklyAverage,
      'routineAverage': routineAverage,
      'pillarAverage': pillarAverage,
      'completedDays': completedDays,
      'observation': observation,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WeeklyProgress copyWith({
    String? dateKey,
    List<String>? dayLabels,
    List<double>? dailyScores,
    List<double>? dailyRoutinePercentages,
    List<int>? dailyCompletedTasks,
    List<int>? dailyTotalTasks,
    double? weeklyAverage,
    double? routineAverage,
    double? pillarAverage,
    int? completedDays,
    String? observation,
    DateTime? updatedAt,
  }) {
    return WeeklyProgress(
      dateKey: dateKey ?? this.dateKey,
      dayLabels: dayLabels ?? this.dayLabels,
      dailyScores: dailyScores ?? this.dailyScores,
      dailyRoutinePercentages:
          dailyRoutinePercentages ?? this.dailyRoutinePercentages,
      dailyCompletedTasks: dailyCompletedTasks ?? this.dailyCompletedTasks,
      dailyTotalTasks: dailyTotalTasks ?? this.dailyTotalTasks,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      routineAverage: routineAverage ?? this.routineAverage,
      pillarAverage: pillarAverage ?? this.pillarAverage,
      completedDays: completedDays ?? this.completedDays,
      observation: observation ?? this.observation,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
