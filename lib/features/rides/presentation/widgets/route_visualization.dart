import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Vertical origin-to-destination route visualization with dots and connecting line.
///
/// Displays pick-up and drop-off addresses with accent-colored circles
/// connected by a vertical line. Use [compact] for tighter spacing.
class RouteVisualization extends StatelessWidget {
  const RouteVisualization({
    super.key,
    required this.originAddress,
    required this.destinationAddress,
    this.compact = false,
  });

  final String originAddress;
  final String destinationAddress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineHeight = compact ? 16.0 : 32.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Origin row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Origin dot column (filled circle + connecting line)
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: lineHeight,
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Origin text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pick-up',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceDim,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    originAddress,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        // Destination row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination dot (outlined circle)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Destination text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Drop-off',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceDim,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destinationAddress,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
