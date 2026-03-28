import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Legend card for isochrone timing displayed on the map.
///
/// Shows two color-coded rows: 5-minute zone (darker accent) and
/// 10-minute zone (lighter accent) to match the polygon overlay colors.
class IsochroneLegend extends StatelessWidget {
  const IsochroneLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendRow(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderColor: AppColors.accent.withValues(alpha: 0.6),
            label: '5 min',
            theme: theme,
          ),
          const SizedBox(height: 4),
          _LegendRow(
            color: AppColors.accent.withValues(alpha: 0.06),
            borderColor: AppColors.accent.withValues(alpha: 0.6),
            label: '10 min',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.borderColor,
    required this.label,
    required this.theme,
  });

  final Color color;
  final Color borderColor;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
