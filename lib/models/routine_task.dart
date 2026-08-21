enum RoutineCategory {
  morning('morning', 'Mañana'),
  afternoon('afternoon', 'Tarde'),
  night('night', 'Noche');

  const RoutineCategory(this.value, this.label);

  final String value;
  final String label;

  static RoutineCategory fromJson(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    if (normalized == 'mañana' ||
        normalized == 'manana' ||
        normalized == 'maã±ana') {
      return RoutineCategory.morning;
    }
    if (normalized == 'tarde') {
      return RoutineCategory.afternoon;
    }
    if (normalized == 'noche') {
      return RoutineCategory.night;
    }
    return RoutineCategory.values.firstWhere(
      (category) =>
          category.value == normalized ||
          category.label.toLowerCase() == normalized,
      orElse: () => RoutineCategory.morning,
    );
  }
}

class RoutineTask {
  const RoutineTask({
    required this.id,
    required this.title,
    required this.category,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.pillarId,
    this.linkedMetricId,
  });

  static const maxTitleLength = 80;
  static const _unset = Object();

  final String id;
  final String title;
  final RoutineCategory category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pillarId;
  final String? linkedMetricId;

  factory RoutineTask.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final updatedAt = _dateTimeFromJson(json['updatedAt']);
    final createdAt = _dateTimeFromJson(json['createdAt']) ?? updatedAt ?? now;
    final id = json['id'] as String? ?? '';

    return RoutineTask(
      id: id,
      title: json['title'] as String? ?? '',
      category: RoutineCategory.fromJson(json['category'] ?? json['section']),
      isCompleted:
          json['isCompleted'] as bool? ?? json['completed'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      pillarId: json['pillarId'] as String? ?? _legacyPillarId(id),
      linkedMetricId: json['linkedMetricId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.value,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pillarId': pillarId,
      'linkedMetricId': linkedMetricId,
    };
  }

  RoutineTask copyWith({
    String? id,
    String? title,
    RoutineCategory? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? pillarId = _unset,
    Object? linkedMetricId = _unset,
  }) {
    return RoutineTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pillarId: identical(pillarId, _unset)
          ? this.pillarId
          : pillarId as String?,
      linkedMetricId: identical(linkedMetricId, _unset)
          ? this.linkedMetricId
          : linkedMetricId as String?,
    );
  }

  static DateTime? _dateTimeFromJson(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static String? _legacyPillarId(String taskId) {
    const mappings = {
      'night_prepare_sleep': 'sleep',
      'night_no_screens': 'sleep',
      'morning_water': 'nutrition',
      'afternoon_meal': 'nutrition',
      'morning_mobility': 'movement',
      'afternoon_walk': 'movement',
    };
    return mappings[taskId];
  }
}
