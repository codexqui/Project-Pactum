import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final action = isLoading ? null : onPressed;
    final loadingIndicator = SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );

    if (icon == null) {
      return FilledButton(
        onPressed: action,
        child: isLoading ? loadingIndicator : Text(label),
      );
    }

    return FilledButton.icon(
      onPressed: action,
      icon: isLoading ? loadingIndicator : Icon(icon),
      label: Text(label),
    );
  }
}
