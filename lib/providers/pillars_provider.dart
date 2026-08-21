import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pillar.dart';
import 'repository_providers.dart';

final pillarsProvider = FutureProvider<List<Pillar>>((ref) async {
  final today = DateTime.now();
  final review = await ref
      .read(dailyReviewRepositoryProvider)
      .loadForDate(today);
  final tasks = await ref.read(routineRepositoryProvider).loadForDate(today);
  return ref
      .watch(pillarRepositoryProvider)
      .loadPillars(review: review, tasks: tasks);
});
