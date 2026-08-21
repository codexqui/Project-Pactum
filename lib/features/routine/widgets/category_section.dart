import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/section_title.dart';
import '../../../models/routine_task.dart';
import 'routine_task_tile.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    required this.category,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final RoutineCategory category;
  final List<RoutineTask> tasks;
  final ValueChanged<RoutineTask> onToggle;
  final ValueChanged<RoutineTask> onEdit;
  final ValueChanged<RoutineTask> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle('${category.label} · ${tasks.length}'),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: tasks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Sin tareas en esta categoría.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var index = 0; index < tasks.length; index++) ...[
                      RoutineTaskTile(
                        task: tasks[index],
                        onToggle: () => onToggle(tasks[index]),
                        onEdit: () => onEdit(tasks[index]),
                        onDelete: () => onDelete(tasks[index]),
                      ),
                      if (index < tasks.length - 1) const Divider(),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
