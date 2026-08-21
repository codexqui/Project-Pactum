import '../models/daily_review.dart';
import '../models/pillar.dart';
import '../models/routine_task.dart';

class PillarCalculationService {
  const PillarCalculationService();

  List<Pillar> calculate({
    required DailyReview review,
    required List<RoutineTask> tasks,
  }) {
    final sleep = _percentageFor(
      reviewScores: _reviewScoresFor(review, 'sleep'),
      tasks: tasks,
      pillarId: 'sleep',
    );
    final nutrition = _percentageFor(
      reviewScores: _reviewScoresFor(review, 'nutrition'),
      tasks: tasks,
      pillarId: 'nutrition',
    );
    final movement = _percentageFor(
      reviewScores: _reviewScoresFor(review, 'movement'),
      tasks: tasks,
      pillarId: 'movement',
    );

    return [
      Pillar(
        id: 'sleep',
        title: 'Sueño y descanso',
        status: _statusFor(sleep),
        percentage: sleep,
        suggestedAction: _actionFor(
          sleep,
          strong: 'Mantén el horario de descanso.',
          weak: 'Define hora de cierre y reduce pantallas.',
        ),
      ),
      Pillar(
        id: 'nutrition',
        title: 'Nutrición e hidratación',
        status: _statusFor(nutrition),
        percentage: nutrition,
        suggestedAction: _actionFor(
          nutrition,
          strong: 'Sostén hidratación y comidas completas.',
          weak: 'Asegura agua temprano y una comida completa.',
        ),
      ),
      Pillar(
        id: 'movement',
        title: 'Movimiento y movilidad',
        status: _statusFor(movement),
        percentage: movement,
        suggestedAction: _actionFor(
          movement,
          strong: 'Mantén movilidad y caminata diaria.',
          weak: 'Haz 10 minutos de movilidad o caminata.',
        ),
      ),
    ];
  }

  double _percentageFor({
    required List<double> reviewScores,
    required List<RoutineTask> tasks,
    required String pillarId,
  }) {
    final linkedTasks = tasks.where((task) => task.pillarId == pillarId);
    final taskScores = linkedTasks.map(
      (task) => task.isCompleted ? 100.0 : 0.0,
    );
    final values = [...reviewScores, ...taskScores];
    if (values.isEmpty) {
      return 0;
    }
    return (values.reduce((total, value) => total + value) / values.length)
        .clamp(0, 100);
  }

  List<double> _reviewScoresFor(DailyReview review, String pillarId) {
    if (!review.hasBeenSaved) {
      return const [];
    }

    return review.metrics
        .where((metric) => metric.pillarId == pillarId)
        .map((metric) => metric.score * 10.0)
        .toList(growable: false);
  }

  String _statusFor(double percentage) {
    if (percentage >= 80) {
      return 'Sólido';
    }
    if (percentage >= 55) {
      return 'En progreso';
    }
    return 'Requiere atención';
  }

  String _actionFor(
    double percentage, {
    required String strong,
    required String weak,
  }) {
    return percentage >= 80 ? strong : weak;
  }
}
