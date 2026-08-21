import 'dart:convert';

import '../core/utils/date_key.dart';
import '../models/routine_task.dart';
import '../services/local_storage_service.dart';

class RoutineRepository {
  const RoutineRepository(this.storageService);

  static const _routinePrefix = 'routine_tasks_';
  static const _templateKey = 'routine_tasks_template_v2';

  final LocalStorageService storageService;

  Future<List<RoutineTask>> getTasks() async {
    final today = DateTime.now();
    final storedToday = await _readSnapshot(today);
    if (storedToday != null) {
      await _ensureTemplateExists(storedToday);
      return storedToday;
    }

    final template = await _readTaskList(_templateKey) ?? const [];
    if (template.isEmpty) {
      return const [];
    }

    final now = DateTime.now();
    final todayTasks = template
        .map((task) => task.copyWith(isCompleted: false, updatedAt: now))
        .toList(growable: false);
    await _saveSnapshot(today, todayTasks);
    return todayTasks;
  }

  Future<List<RoutineTask>> getTasksForDate(DateTime date) async {
    if (DateKey.fromDate(date) == DateKey.today()) {
      return getTasks();
    }
    return await _readSnapshot(date) ?? const [];
  }

  Future<List<RoutineTask>> addTask(RoutineTask task) async {
    _validateTask(task);
    final tasks = await getTasks();
    if (tasks.any((candidate) => candidate.id == task.id)) {
      throw StateError('Ya existe una tarea con el mismo identificador.');
    }

    final updated = [...tasks, task];
    await _saveDefinitionAndToday(updated);
    return updated;
  }

  Future<List<RoutineTask>> updateTask(RoutineTask task) async {
    _validateTask(task);
    final tasks = await getTasks();
    final index = tasks.indexWhere((candidate) => candidate.id == task.id);
    if (index == -1) {
      throw StateError('La tarea que intentas editar ya no existe.');
    }

    final current = tasks[index];
    final updatedTask = task.copyWith(
      title: task.title.trim(),
      isCompleted: current.isCompleted,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    final updated = [...tasks]..[index] = updatedTask;
    await _saveDefinitionAndToday(updated);
    return updated;
  }

  Future<List<RoutineTask>> deleteTask(String taskId) async {
    final normalizedId = taskId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        taskId,
        'taskId',
        'El id no puede estar vacío.',
      );
    }

    final tasks = await getTasks();
    if (!tasks.any((task) => task.id == normalizedId)) {
      throw StateError('La tarea que intentas eliminar ya no existe.');
    }

    final updated = tasks
        .where((task) => task.id != normalizedId)
        .toList(growable: false);
    await _saveDefinitionAndToday(updated);
    return updated;
  }

  Future<List<RoutineTask>> toggleTaskCompletion(String taskId) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      throw StateError('La tarea que intentas actualizar ya no existe.');
    }

    final updated = [...tasks];
    updated[index] = tasks[index].copyWith(
      isCompleted: !tasks[index].isCompleted,
      updatedAt: DateTime.now(),
    );
    await _saveSnapshot(DateTime.now(), updated);
    return updated;
  }

  Future<List<RoutineTask>> loadForDate(DateTime date) {
    return getTasksForDate(date);
  }

  Future<void> saveForDate(DateTime date, List<RoutineTask> tasks) async {
    if (DateKey.fromDate(date) == DateKey.today()) {
      await _saveDefinitionAndToday(tasks);
      return;
    }
    await _saveSnapshot(date, tasks);
  }

  Future<Map<String, List<RoutineTask>>> loadLastSevenDays() async {
    final entries = <String, List<RoutineTask>>{};
    for (final date in DateKey.lastSevenDays()) {
      entries[DateKey.fromDate(date)] = await getTasksForDate(date);
    }
    return entries;
  }

  Future<void> _saveDefinitionAndToday(List<RoutineTask> tasks) async {
    _validateTaskList(tasks);
    await _writeTaskList(
      _templateKey,
      tasks
          .map((task) => task.copyWith(isCompleted: false))
          .toList(growable: false),
    );
    await _saveSnapshot(DateTime.now(), tasks);
  }

  Future<void> _ensureTemplateExists(List<RoutineTask> tasks) async {
    if (await storageService.readString(_templateKey) != null) {
      return;
    }
    await _writeTaskList(
      _templateKey,
      tasks
          .map((task) => task.copyWith(isCompleted: false))
          .toList(growable: false),
    );
  }

  Future<List<RoutineTask>?> _readSnapshot(DateTime date) {
    return _readTaskList(_keyForDate(date));
  }

  Future<void> _saveSnapshot(DateTime date, List<RoutineTask> tasks) {
    _validateTaskList(tasks);
    return _writeTaskList(_keyForDate(date), tasks);
  }

  Future<List<RoutineTask>?> _readTaskList(String key) async {
    final rawJson = await storageService.readString(key);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List<dynamic>) {
        return const [];
      }

      final tasks = <RoutineTask>[];
      final ids = <String>{};
      for (final value in decoded) {
        if (value is! Map) {
          continue;
        }
        final task = RoutineTask.fromJson(Map<String, dynamic>.from(value));
        if (!_isValidTask(task) || !ids.add(task.id)) {
          continue;
        }
        tasks.add(task.copyWith(title: task.title.trim()));
      }
      return tasks;
    } on FormatException {
      return const [];
    }
  }

  Future<void> _writeTaskList(String key, List<RoutineTask> tasks) {
    final encoded = tasks.map((task) => task.toJson()).toList(growable: false);
    return storageService.writeString(key, jsonEncode(encoded));
  }

  void _validateTaskList(List<RoutineTask> tasks) {
    final ids = <String>{};
    for (final task in tasks) {
      _validateTask(task);
      if (!ids.add(task.id)) {
        throw StateError('No se permiten identificadores de tarea duplicados.');
      }
    }
  }

  void _validateTask(RoutineTask task) {
    if (!_isValidTask(task)) {
      throw ArgumentError('La tarea contiene datos inválidos.');
    }
  }

  bool _isValidTask(RoutineTask task) {
    final title = task.title.trim();
    return task.id.trim().isNotEmpty &&
        title.isNotEmpty &&
        title.length <= RoutineTask.maxTitleLength;
  }

  String _keyForDate(DateTime date) {
    return '$_routinePrefix${DateKey.fromDate(date)}';
  }
}
