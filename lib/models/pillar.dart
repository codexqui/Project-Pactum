class Pillar {
  const Pillar({
    required this.id,
    required this.title,
    required this.status,
    required this.percentage,
    required this.suggestedAction,
  });

  final String id;
  final String title;
  final String status;
  final double percentage;
  final String suggestedAction;

  factory Pillar.fromJson(Map<String, dynamic> json) {
    return Pillar(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'Sin evaluar',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      suggestedAction: json['suggestedAction'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'percentage': percentage,
      'suggestedAction': suggestedAction,
    };
  }

  Pillar copyWith({
    String? id,
    String? title,
    String? status,
    double? percentage,
    String? suggestedAction,
  }) {
    return Pillar(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      percentage: percentage ?? this.percentage,
      suggestedAction: suggestedAction ?? this.suggestedAction,
    );
  }
}
