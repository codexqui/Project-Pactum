import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/daily_review_metric.dart';

class MetricFormResult {
  const MetricFormResult({required this.title});

  final String title;
}

class MetricFormSheet extends StatefulWidget {
  const MetricFormSheet({this.initialMetric, super.key});

  final DailyReviewMetric? initialMetric;

  @override
  State<MetricFormSheet> createState() => _MetricFormSheetState();
}

class _MetricFormSheetState extends State<MetricFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  bool get _isEditing => widget.initialMetric != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialMetric?.title ?? '',
    );
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
                _isEditing ? 'Editar categoría' : 'Nueva categoría',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLength: DailyReviewMetric.maxTitleLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Estado de ánimo',
                ),
                validator: (value) {
                  final normalized = value?.trim() ?? '';
                  if (normalized.isEmpty) {
                    return 'Escribe un nombre para la categoría.';
                  }
                  if (normalized.length > DailyReviewMetric.maxTitleLength) {
                    return 'Máximo ${DailyReviewMetric.maxTitleLength} caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _isEditing ? 'Guardar cambios' : 'Crear categoría',
                icon: _isEditing ? Icons.save_outlined : Icons.add_outlined,
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

    Navigator.of(
      context,
    ).pop(MetricFormResult(title: _titleController.text.trim()));
  }
}
