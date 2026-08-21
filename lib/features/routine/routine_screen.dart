import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/async_state_views.dart';
import '../../models/routine_task.dart';
import '../../providers/routine_provider.dart';
import 'widgets/add_task_button.dart';
import 'widgets/category_section.dart';
import 'widgets/empty_routine_state.dart';
import 'widgets/routine_progress_header.dart';
import 'widgets/task_form_sheet.dart';

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routine = ref.watch(routineProvider);

    return routine.when(
      data: (state) => AppPage(
        title: 'Rutina',
        subtitle: 'Checklist diario editable',
        children: [
          RoutineProgressHeader(
            completed: state.completedCount,
            total: state.totalCount,
            percentage: state.progressPercentage,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (state.isEmpty)
            EmptyRoutineState(onCreateTask: () => _openTaskForm(context, ref))
          else ...[
            AddTaskButton(onPressed: () => _openTaskForm(context, ref)),
            const SizedBox(height: AppSpacing.xl),
            for (final category in RoutineCategory.values) ...[
              CategorySection(
                category: category,
                tasks: state.tasksByCategory[category] ?? const [],
                onToggle: (task) => _toggleTask(context, ref, task),
                onEdit: (task) => _openTaskForm(context, ref, task: task),
                onDelete: (task) => _confirmDelete(context, ref, task),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
        ],
      ),
      loading: LoadingView.new,
      error: (error, stackTrace) => ErrorView(
        message: 'No se pudo cargar la rutina.',
        onRetry: () => ref.invalidate(routineProvider),
      ),
    );
  }

  Future<void> _openTaskForm(
    BuildContext context,
    WidgetRef ref, {
    RoutineTask? task,
  }) async {
    final result = await showModalBottomSheet<TaskFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TaskFormSheet(initialTask: task),
    );

    if (result == null || !context.mounted) {
      return;
    }

    try {
      if (task == null) {
        await ref
            .read(routineProvider.notifier)
            .addTask(title: result.title, category: result.category);
        if (context.mounted) {
          _showSnackBar(context, 'Tarea creada.');
        }
      } else {
        await ref
            .read(routineProvider.notifier)
            .editTask(
              taskId: task.id,
              title: result.title,
              category: result.category,
            );
        if (context.mounted) {
          _showSnackBar(context, 'Tarea actualizada.');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'No se pudo guardar la tarea.');
      }
    }
  }

  Future<void> _toggleTask(
    BuildContext context,
    WidgetRef ref,
    RoutineTask task,
  ) async {
    try {
      await ref.read(routineProvider.notifier).toggleTask(task.id);
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'No se pudo actualizar la tarea.');
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RoutineTask task,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${task.title}" de tu rutina?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(routineProvider.notifier).deleteTask(task.id);
      if (context.mounted) {
        _showSnackBar(context, 'Tarea eliminada.');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'No se pudo eliminar la tarea.');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
