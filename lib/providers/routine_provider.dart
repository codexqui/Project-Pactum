import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/routine_task.dart';
import 'dashboard_provider.dart';
import 'pillars_provider.dart';
import 'repository_providers.dart';
import 'weekly_progress_provider.dart';

final routineProvider = AsyncNotifierProvider<RoutineController, RoutineState>(
  RoutineController.new,
);

final routineCompletionProvider = Provider<double>((ref) {
  return ref.watch(routineProvider).asData?.value.progressPercentage ?? 0;
});

final completedRoutineTasksProvider = Provider<int>((ref) {
  return ref.watch(routineProvider).asData?.value.completedCount ?? 0;
});

final totalRoutineTasksProvider = Provider<int>((ref) {
  return ref.watch(routineProvider).asData?.value.totalCount ?? 0;
});

class RoutineState {
  const RoutineState({required this.tasks});

  final List<RoutineTask> tasks;

  bool get isEmpty => tasks.isEmpty;

  int get totalCount => tasks.length;

  int get completedCount => tasks.where((task) => task.isCompleted).length;

  double get progressPercentage {
    if (tasks.isEmpty) {
      return 0;
    }
    return (completedCount / totalCount * 100).clamp(0, 100);
  }

  Map<RoutineCategory, List<RoutineTask>> get tasksByCategory {
    return {
      for (final category in RoutineCategory.values)
        category: tasks
            .where((task) => task.category == category)
            .toList(growable: false),
    };
  }

  RoutineState copyWith({List<RoutineTask>? tasks}) {
    return RoutineState(tasks: tasks ?? this.tasks);
  }
}

class RoutineController extends AsyncNotifier<RoutineState> {
  @override
  Future<RoutineState> build() async {
    final tasks = await ref.read(routineRepositoryProvider).getTasks();
    return RoutineState(tasks: tasks);
  }

  Future<void> addTask({
    required String title,
    required RoutineCategory category,
  }) async {
    final normalizedTitle = _normalizeTitle(title);
    final now = DateTime.now();
    final task = RoutineTask(
      id: _generateTaskId(now),
      title: normalizedTitle,
      category: category,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _persistOptimistically(
      (tasks) => [...tasks, task],
      () => ref.read(routineRepositoryProvider).addTask(task),
    );
  }

  Future<void> editTask({
    required String taskId,
    required String title,
    required RoutineCategory category,
  }) async {
    final normalizedTitle = _normalizeTitle(title);
    final currentTasks = await _currentTasks();
    final current = currentTasks.firstWhere(
      (task) => task.id == taskId,
      orElse: () => throw StateError('La tarea ya no existe.'),
    );
    final updatedTask = current.copyWith(
      title: normalizedTitle,
      category: category,
      updatedAt: DateTime.now(),
    );

    await _persistOptimistically(
      (tasks) => tasks
          .map((task) => task.id == taskId ? updatedTask : task)
          .toList(growable: false),
      () => ref.read(routineRepositoryProvider).updateTask(updatedTask),
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _persistOptimistically(
      (tasks) =>
          tasks.where((task) => task.id != taskId).toList(growable: false),
      () => ref.read(routineRepositoryProvider).deleteTask(taskId),
    );
  }

  Future<void> toggleTask(String taskId) async {
    await _persistOptimistically(
      (tasks) => tasks
          .map(
            (task) => task.id == taskId
                ? task.copyWith(
                    isCompleted: !task.isCompleted,
                    updatedAt: DateTime.now(),
                  )
                : task,
          )
          .toList(growable: false),
      () => ref.read(routineRepositoryProvider).toggleTaskCompletion(taskId),
    );
  }

  double getProgress() {
    return state.asData?.value.progressPercentage ?? 0;
  }

  int getCompletedCount() {
    return state.asData?.value.completedCount ?? 0;
  }

  int getTotalCount() {
    return state.asData?.value.totalCount ?? 0;
  }

  Future<void> _persistOptimistically(
    List<RoutineTask> Function(List<RoutineTask> tasks) updateLocalTasks,
    Future<List<RoutineTask>> Function() persist,
  ) async {
    final previous = state.asData?.value ?? RoutineState(tasks: await _load());
    final optimistic = RoutineState(tasks: updateLocalTasks(previous.tasks));
    state = AsyncData(optimistic);

    try {
      final persisted = await persist();
      state = AsyncData(RoutineState(tasks: persisted));
      _refreshDerivedProviders();
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<List<RoutineTask>> _currentTasks() async {
    return state.asData?.value.tasks ?? _load();
  }

  Future<List<RoutineTask>> _load() {
    return ref.read(routineRepositoryProvider).getTasks();
  }

  String _normalizeTitle(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('El nombre de la tarea no puede estar vacío.');
    }
    if (normalized.length > RoutineTask.maxTitleLength) {
      throw ArgumentError(
        'El nombre de la tarea no puede superar '
        '${RoutineTask.maxTitleLength} caracteres.',
      );
    }
    return normalized;
  }

  String _generateTaskId(DateTime now) {
    final random = Random().nextInt(1 << 32);
    return 'task_${now.microsecondsSinceEpoch}_$random';
  }

  void _refreshDerivedProviders() {
    ref.invalidate(dashboardProvider);
    ref.invalidate(pillarsProvider);
    ref.invalidate(weeklyProgressProvider);
  }
}
