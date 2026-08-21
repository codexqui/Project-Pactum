import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../models/routine_task.dart';

class RoutineTaskTile extends StatelessWidget {
  const RoutineTaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final RoutineTask task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
      color: task.isCompleted
          ? Theme.of(context).colorScheme.onSurfaceVariant
          : Theme.of(context).colorScheme.onSurface,
    );

    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
      ),
      leading: Checkbox(value: task.isCompleted, onChanged: (_) => onToggle()),
      title: Text(task.title, style: textStyle),
      trailing: PopupMenuButton<_TaskAction>(
        tooltip: 'Opciones de tarea',
        onSelected: (action) {
          switch (action) {
            case _TaskAction.edit:
              onEdit();
            case _TaskAction.delete:
              onDelete();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _TaskAction.edit,
            child: Row(
              children: [
                Icon(Icons.edit_outlined),
                SizedBox(width: AppSpacing.sm),
                Text('Editar'),
              ],
            ),
          ),
          PopupMenuItem(
            value: _TaskAction.delete,
            child: Row(
              children: [
                Icon(Icons.delete_outline),
                SizedBox(width: AppSpacing.sm),
                Text('Eliminar'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _TaskAction { edit, delete }
