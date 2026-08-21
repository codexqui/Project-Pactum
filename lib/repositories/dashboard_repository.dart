import '../models/dashboard_summary.dart';
import '../models/daily_review.dart';
import '../models/routine_task.dart';
import '../services/score_calculation_service.dart';
import 'daily_review_repository.dart';
import 'pillar_repository.dart';
import 'routine_repository.dart';

class DashboardRepository {
  const DashboardRepository({
    required this.dailyReviewRepository,
    required this.routineRepository,
    required this.pillarRepository,
    required this.scoreCalculationService,
  });

  final DailyReviewRepository dailyReviewRepository;
  final RoutineRepository routineRepository;
  final PillarRepository pillarRepository;
  final ScoreCalculationService scoreCalculationService;

  Future<DashboardSummary> loadToday() async {
    final today = DateTime.now();
    final review = await dailyReviewRepository.loadForDate(today);
    final tasks = await routineRepository.loadForDate(today);
    final pillars = await pillarRepository.loadPillars(
      review: review,
      tasks: tasks,
    );

    return DashboardSummary(
      dateKey: review.dateKey,
      dayScore: scoreCalculationService.dayScore(review, tasks),
      reviewAverage: review.averageValue,
      totalReviewMetrics: review.totalMetrics,
      routineProgress: scoreCalculationService.routineCompletion(tasks),
      completedTasks: scoreCalculationService.completedRoutineTasks(tasks),
      totalTasks: tasks.length,
      pillars: pillars,
      lastUpdated: _latestUpdate(review, tasks),
    );
  }

  DateTime? _latestUpdate(DailyReview review, List<RoutineTask> tasks) {
    final dates = [
      ?review.updatedAt,
      ...review.metrics.map((metric) => metric.updatedAt),
      ...tasks.map((task) => task.updatedAt).whereType<DateTime>(),
    ];

    if (dates.isEmpty) {
      return null;
    }

    dates.sort();
    return dates.last;
  }
}
