import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weekly_progress.dart';
import 'repository_providers.dart';

final weeklyProgressProvider = FutureProvider<WeeklyProgress>((ref) {
  return ref.watch(weeklyProgressRepositoryProvider).loadCurrentWeek();
});
