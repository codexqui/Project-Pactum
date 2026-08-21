import '../models/daily_review.dart';
import '../models/pillar.dart';
import '../models/routine_task.dart';
import '../services/pillar_calculation_service.dart';

class PillarRepository {
  const PillarRepository(this.calculationService);

  final PillarCalculationService calculationService;

  Future<List<Pillar>> loadPillars({
    required DailyReview review,
    required List<RoutineTask> tasks,
  }) async {
    return calculationService.calculate(review: review, tasks: tasks);
  }
}
