import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

class ReviewMetricSlider extends StatelessWidget {
  const ReviewMetricSlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: value.toString(),
            onChanged: (nextValue) => onChanged(nextValue.round()),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 32,
          child: Text(
            value.toString(),
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
