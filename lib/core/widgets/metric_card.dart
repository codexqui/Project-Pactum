import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final int value;
  final IconData icon;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  value.toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: value.toString(),
              onChanged: enabled
                  ? (nextValue) => onChanged(nextValue.round())
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
