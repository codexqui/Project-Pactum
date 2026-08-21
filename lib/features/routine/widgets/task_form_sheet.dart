import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/routine_task.dart';

class TaskFormResult {
  const TaskFormResult({required this.title, required this.category});

  final String title;
  final RoutineCategory category;
}

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({this.initialTask, super.key});

  final RoutineTask? initialTask;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late RoutineCategory _category;

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTask?.title ?? '',
    );
    _category = widget.initialTask?.category ?? RoutineCategory.morning;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Editar tarea' : 'Nueva tarea',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLength: RoutineTask.maxTitleLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la tarea',
                  hintText: 'Ej. Caminar 15 minutos',
                ),
                validator: (value) {
                  final normalized = value?.trim() ?? '';
                  if (normalized.isEmpty) {
                    return 'Escribe un nombre para la tarea.';
                  }
                  if (normalized.length > RoutineTask.maxTitleLength) {
                    return 'Máximo ${RoutineTask.maxTitleLength} caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<RoutineCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: [
                  for (final category in RoutineCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _category = value);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _isEditing ? 'Guardar cambios' : 'Crear tarea',
                icon: _isEditing
                    ? Icons.save_outlined
                    : Icons.add_circle_outline,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      TaskFormResult(title: _titleController.text.trim(), category: _category),
    );
  }
}
