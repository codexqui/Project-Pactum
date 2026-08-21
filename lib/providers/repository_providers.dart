import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/daily_review_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/pillar_repository.dart';
import '../repositories/routine_repository.dart';
import '../repositories/weekly_progress_repository.dart';
import '../services/local_storage_service.dart';
import '../services/pillar_calculation_service.dart';
import '../services/score_calculation_service.dart';
import '../services/shared_preferences_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return SharedPreferencesStorageService();
});

final scoreCalculationServiceProvider = Provider<ScoreCalculationService>((
  ref,
) {
  return const ScoreCalculationService();
});

final pillarCalculationServiceProvider = Provider<PillarCalculationService>((
  ref,
) {
  return const PillarCalculationService();
});

final dailyReviewRepositoryProvider = Provider<DailyReviewRepository>((ref) {
  return DailyReviewRepository(ref.watch(localStorageServiceProvider));
});

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository(ref.watch(localStorageServiceProvider));
});

final pillarRepositoryProvider = Provider<PillarRepository>((ref) {
  return PillarRepository(ref.watch(pillarCalculationServiceProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(
    dailyReviewRepository: ref.watch(dailyReviewRepositoryProvider),
    routineRepository: ref.watch(routineRepositoryProvider),
    pillarRepository: ref.watch(pillarRepositoryProvider),
    scoreCalculationService: ref.watch(scoreCalculationServiceProvider),
  );
});

final weeklyProgressRepositoryProvider = Provider<WeeklyProgressRepository>((
  ref,
) {
  return WeeklyProgressRepository(
    dailyReviewRepository: ref.watch(dailyReviewRepositoryProvider),
    routineRepository: ref.watch(routineRepositoryProvider),
    pillarRepository: ref.watch(pillarRepositoryProvider),
    scoreCalculationService: ref.watch(scoreCalculationServiceProvider),
  );
});
