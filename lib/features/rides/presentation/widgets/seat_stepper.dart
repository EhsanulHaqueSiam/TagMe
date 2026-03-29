import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_spacing.dart';

/// Stepper widget for selecting the number of available seats.
///
/// Displays a minus button, current value, and plus button. Buttons are
/// disabled (reduced opacity) at their respective min/max bounds.
class SeatStepper extends StatelessWidget {
  const SeatStepper({
    required this.value,
    required this.max,
    required this.onChanged,
    super.key,
    this.min = 1,
  });

  /// Current seat count.
  final int value;

  /// Minimum allowed value (default 1).
  final int min;

  /// Maximum allowed value (from transport capacity).
  final int max;

  /// Callback with new value when incremented/decremented.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atMin = value <= min;
    final atMax = value >= max;

    return Semantics(
      label: 'Available seats: $value. Increase. Decrease.',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button.
          _StepperButton(
            icon: Icons.remove,
            enabled: !atMin,
            onTap: atMin ? null : () => onChanged(value - 1),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Current value.
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Plus button.
          _StepperButton(
            icon: Icons.add,
            enabled: !atMax,
            onTap: atMax ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.38,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
