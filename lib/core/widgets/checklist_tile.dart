import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

class ChecklistTile extends StatelessWidget {
  const ChecklistTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: enabled ? (nextValue) => onChanged(nextValue ?? false) : null,
      title: Text(title),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    );
  }
}
