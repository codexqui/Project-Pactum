import 'package:flutter_test/flutter_test.dart';
import 'package:project_pactum/models/daily_review.dart';
import 'package:project_pactum/models/daily_review_metric.dart';
import 'package:project_pactum/models/routine_task.dart';
import 'package:project_pactum/services/pillar_calculation_service.dart';

void main() {
  const service = PillarCalculationService();

  test('calcula los tres pilares desde revisión y checklist', () {
    final now = DateTime(2026, 6, 29);
    final review = DailyReview.fromMetrics(
      date: now,
      metrics: [
        _metric('recovery', 'Recuperación', 8, now, pillarId: 'sleep'),
        _metric('energy', 'Energía', 7, now, pillarId: 'nutrition'),
        _metric('discipline', 'Disciplina', 6, now, pillarId: 'movement'),
      ],
      updatedAt: now,
    );
    final tasks = [
      RoutineTask(
        id: 'night_prepare_sleep',
        title: 'Preparar descanso',
        category: RoutineCategory.night,
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
        pillarId: 'sleep',
      ),
      RoutineTask(
        id: 'night_no_screens',
        title: 'Sin pantallas',
        category: RoutineCategory.night,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
        pillarId: 'sleep',
      ),
      RoutineTask(
        id: 'morning_water',
        title: 'Agua',
        category: RoutineCategory.morning,
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
        pillarId: 'nutrition',
      ),
      RoutineTask(
        id: 'afternoon_meal',
        title: 'Comida',
        category: RoutineCategory.afternoon,
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
        pillarId: 'nutrition',
      ),
      RoutineTask(
        id: 'morning_mobility',
        title: 'Movilidad',
        category: RoutineCategory.morning,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
        pillarId: 'movement',
      ),
      RoutineTask(
        id: 'afternoon_walk',
        title: 'Caminata',
        category: RoutineCategory.afternoon,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
        pillarId: 'movement',
      ),
    ];

    final pillars = service.calculate(review: review, tasks: tasks);

    expect(pillars, hasLength(3));
    expect(pillars.firstWhere((pillar) => pillar.id == 'sleep').percentage, 60);
    expect(
      pillars.firstWhere((pillar) => pillar.id == 'nutrition').status,
      'Sólido',
    );
    expect(
      pillars.firstWhere((pillar) => pillar.id == 'movement').percentage,
      20,
    );
  });
}

DailyReviewMetric _metric(
  String id,
  String title,
  int score,
  DateTime now, {
  String? pillarId,
}) {
  return DailyReviewMetric(
    id: id,
    title: title,
    score: score,
    createdAt: now,
    updatedAt: now,
    pillarId: pillarId,
  );
}
