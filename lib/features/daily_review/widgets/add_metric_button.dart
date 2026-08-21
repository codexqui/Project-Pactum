import 'package:flutter/material.dart';

import '../../../core/widgets/primary_button.dart';

class AddMetricButton extends StatelessWidget {
  const AddMetricButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Agregar categoría',
      icon: Icons.add,
      onPressed: onPressed,
    );
  }
}
