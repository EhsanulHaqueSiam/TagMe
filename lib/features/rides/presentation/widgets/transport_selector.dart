import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/core/constants/transport_types.dart';

/// Horizontal row of 5 BD transport type chips with radio-style selection.
///
/// Each chip shows an icon and label. Only one can be selected at a time.
/// Tapping the already-selected chip does nothing (radio behavior).
class TransportSelector extends StatelessWidget {
  const TransportSelector({
    required this.onSelected,
    super.key,
    this.selected,
  });

  /// Currently selected transport type (null = none selected).
  final TransportType? selected;

  /// Callback when a transport type is tapped.
  final ValueChanged<TransportType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: TransportType.values.map((type) {
        final isSelected = type == selected;
        return _TransportChip(
          type: type,
          isSelected: isSelected,
          onTap: () {
            if (!isSelected) onSelected(type);
          },
        );
      }).toList(),
    );
  }
}

class _TransportChip extends StatelessWidget {
  const _TransportChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final TransportType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${type.label} ${isSelected ? "selected" : "not selected"}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type.icon,
                size: 24,
                color: isSelected ? Colors.white : AppColors.onSurfaceDim,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                type.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
