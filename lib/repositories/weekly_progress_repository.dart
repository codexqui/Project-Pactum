import '../core/utils/date_key.dart';
import '../models/weekly_progress.dart';
import '../services/score_calculation_service.dart';
import 'daily_review_repository.dart';
import 'pillar_repository.dart';
import 'routine_repository.dart';

class WeeklyProgressRepository {
  const WeeklyProgressRepository({
    required this.dailyReviewRepository,
    required this.routineRepository,
    required this.pillarRepository,
    required this.scoreCalculationService,
  });

  final DailyReviewRepository dailyReviewRepository;
  final RoutineRepository routineRepository;
  final PillarRepository pillarRepository;
  final ScoreCalculationService scoreCalculationService;

  Future<WeeklyProgress> loadCurrentWeek() async {
    final days = DateKey.lastSevenDays();
    final labels = <String>[];
    final scores = <double>[];
    final routinePercentages = <double>[];
    final completedTasks = <int>[];
    final totalTasks = <int>[];
    var pillarTotal = 0.0;
    var pillarDays = 0;
    var completedDays = 0;

    for (final day in days) {
      final review = await dailyReviewRepository.loadForDate(day);
      final tasks = await routineRepository.loadForDate(day);
      final pillars = await pillarRepository.loadPillars(
        review: review,
        tasks: tasks,
      );
      final score = scoreCalculationService.dayScore(review, tasks);
      final routinePercentage = scoreCalculationService.routineCompletion(
        tasks,
      );
      final completedTaskCount = scoreCalculationService.completedRoutineTasks(
        tasks,
      );
      final hasActivity =
          review.hasBeenSaved ||
          scoreCalculationService.hasRoutineActivity(tasks);

      labels.add('${DateKey.shortWeekdayEs(day)}\n${day.day}/${day.month}');
      scores.add(score);
      routinePercentages.add(routinePercentage);
      completedTasks.add(completedTaskCount);
      totalTasks.add(tasks.length);

      if (hasActivity) {
        pillarTotal +=
            pillars.map((pillar) => pillar.percentage).reduce((a, b) => a + b) /
            pillars.length;
        pillarDays += 1;
      }

      if (tasks.isNotEmpty && completedTaskCount == tasks.length) {
        completedDays += 1;
      }
    }

    final weeklyAverage = scores.isEmpty
        ? 0.0
        : scores.reduce((total, score) => total + score) / scores.length;
    final routineAverage = routinePercentages.isEmpty
        ? 0.0
        : routinePercentages.reduce((total, score) => total + score) /
              routinePercentages.length;
    final pillarAverage = pillarDays == 0 ? 0.0 : pillarTotal / pillarDays;

    return WeeklyProgress(
      dateKey: DateKey.today(),
      dayLabels: labels,
      dailyScores: scores,
      dailyRoutinePercentages: routinePercentages,
      dailyCompletedTasks: completedTasks,
      dailyTotalTasks: totalTasks,
      weeklyAverage: weeklyAverage,
      routineAverage: routineAverage,
      pillarAverage: pillarAverage,
      completedDays: completedDays,
      observation: scoreCalculationService.weeklyObservation(
        weeklyAverage,
        completedDays,
      ),
      updatedAt: DateTime.now(),
    );
  }
}
