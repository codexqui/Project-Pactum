import '../models/daily_review.dart';
import '../models/routine_task.dart';

class ScoreCalculationService {
  const ScoreCalculationService();

  double reviewScore(DailyReview review) {
    return review.hasBeenSaved ? review.averagePercentage : 0;
  }

  int completedRoutineTasks(List<RoutineTask> tasks) {
    return tasks.where((task) => task.isCompleted).length;
  }

  double routineCompletion(List<RoutineTask> tasks) {
    if (tasks.isEmpty) {
      return 0;
    }
    final completed = completedRoutineTasks(tasks);
    return (completed / tasks.length * 100).clamp(0, 100);
  }

  bool hasRoutineActivity(List<RoutineTask> tasks) {
    return tasks.isNotEmpty;
  }

  double dayScore(DailyReview review, List<RoutineTask> tasks) {
    final hasReview = review.hasBeenSaved;
    final hasRoutine = hasRoutineActivity(tasks);

    if (!hasReview && !hasRoutine) {
      return 0;
    }

    var weightedScore = 0.0;
    var weight = 0.0;

    if (hasReview) {
      weightedScore += reviewScore(review) * 0.65;
      weight += 0.65;
    }
    if (hasRoutine) {
      weightedScore += routineCompletion(tasks) * 0.35;
      weight += 0.35;
    }

    return (weightedScore / weight).clamp(0, 100);
  }

  String weeklyObservation(double average, int completedDays) {
    if (average >= 80 && completedDays >= 5) {
      return 'Semana sólida. Mantén la estructura actual.';
    }
    if (average >= 55) {
      return 'Buen avance. El foco está en sostener más días completos.';
    }
    return 'Semana en construcción. Prioriza una acción simple por pilar.';
  }
}
