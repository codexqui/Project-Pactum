import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    required this.percentage,
    this.color,
    this.showValue = false,
    super.key,
  });

  final double percentage;
  final Color? color;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final normalized = (percentage / 100).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: normalized,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
        if (showValue) ...[
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 42,
            child: Text(
              '${percentage.round()}%',
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    );
  }
}
