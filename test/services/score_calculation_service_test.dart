import 'package:flutter_test/flutter_test.dart';
import 'package:project_pactum/models/daily_review.dart';
import 'package:project_pactum/models/daily_review_metric.dart';
import 'package:project_pactum/models/routine_task.dart';
import 'package:project_pactum/services/score_calculation_service.dart';

void main() {
  const service = ScoreCalculationService();

  test('calcula el puntaje ponderado con revisión y rutina', () {
    final now = DateTime(2026, 6, 29);
    final review = DailyReview.fromMetrics(
      date: now,
      metrics: [
        _metric('energy', 'Energía', 8, now),
        _metric('discipline', 'Disciplina', 6, now),
        _metric('focus', 'Enfoque', 7, now),
        _metric('recovery', 'Recuperación', 7, now),
      ],
      updatedAt: DateTime(2026, 6, 29),
    );
    final tasks = [
      RoutineTask(
        id: 'one',
        title: 'Uno',
        category: RoutineCategory.morning,
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
      ),
      RoutineTask(
        id: 'two',
        title: 'Dos',
        category: RoutineCategory.morning,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    expect(service.reviewScore(review), 70);
    expect(service.routineCompletion(tasks), 50);
    expect(service.dayScore(review, tasks), 63);
  });

  test('calcula revisión diaria con categorías dinámicas', () {
    final now = DateTime(2026, 6, 29);
    final threeMetricReview = DailyReview.fromMetrics(
      date: now,
      metrics: [
        _metric('one', 'Uno', 10, now),
        _metric('two', 'Dos', 8, now),
        _metric('three', 'Tres', 6, now),
      ],
      updatedAt: now,
    );
    final emptyReview = DailyReview.initial(date: now);

    expect(threeMetricReview.averageValue, 8);
    expect(service.reviewScore(threeMetricReview), 80);
    expect(service.reviewScore(emptyReview), 0);
  });

  test('calcula progreso dinámico con cualquier cantidad de tareas', () {
    final now = DateTime(2026, 6, 29);
    final threeTasks = List.generate(
      3,
      (index) => RoutineTask(
        id: 'three_$index',
        title: 'Tarea $index',
        category: RoutineCategory.morning,
        isCompleted: index == 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final twentyTasks = List.generate(
      20,
      (index) => RoutineTask(
        id: 'twenty_$index',
        title: 'Tarea $index',
        category: RoutineCategory.afternoon,
        isCompleted: index < 10,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final thirtyTasks = List.generate(
      30,
      (index) => RoutineTask(
        id: 'thirty_$index',
        title: 'Tarea $index',
        category: RoutineCategory.night,
        isCompleted: index < 6,
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(service.routineCompletion(threeTasks).round(), 33);
    expect(service.routineCompletion(twentyTasks), 50);
    expect(service.routineCompletion(thirtyTasks), 20);
    expect(service.routineCompletion(const []), 0);
  });

  test('devuelve cero cuando no existe actividad guardada', () {
    final review = DailyReview.initial(date: DateTime(2026, 6, 29));
    const tasks = <RoutineTask>[];

    expect(service.dayScore(review, tasks), 0);
  });
}

DailyReviewMetric _metric(String id, String title, int score, DateTime now) {
  return DailyReviewMetric(
    id: id,
    title: title,
    score: score,
    createdAt: now,
    updatedAt: now,
  );
}
