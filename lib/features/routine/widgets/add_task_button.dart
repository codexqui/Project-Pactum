import 'package:flutter/material.dart';

import '../../../core/widgets/primary_button.dart';

class AddTaskButton extends StatelessWidget {
  const AddTaskButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Agregar tarea',
      icon: Icons.add,
      onPressed: onPressed,
    );
  }
}
