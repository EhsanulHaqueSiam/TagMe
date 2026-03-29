import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/core/constants/transport_types.dart';
import 'package:tagme/features/fares/data/models/fare_entry.dart';

/// Displays a single fare entry as a card in the History tab.
///
/// Shows route, transport icon, date, total fare, and the user's share
/// with color-coded direction (paid vs received).
class FareHistoryCard extends StatelessWidget {
  const FareHistoryCard({
    required this.entry,
    required this.currentUserId,
    super.key,
  });

  /// The fare ledger entry to display.
  final FareEntry entry;

  /// The current user's student ID (to determine payment direction).
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y h:mm a');

    // Resolve transport icon.
    IconData transportIcon;
    try {
      transportIcon = TransportType.fromString(entry.transportType).icon;
    } on ArgumentError catch (_) {
      transportIcon = Icons.directions;
    }

    // Determine payment direction.
    final bool isPayer = entry.fromStudentId == currentUserId;
    final String shareText;
    final Color shareColor;

    if (isPayer) {
      shareText = 'You paid ${entry.amount} BDT';
      shareColor = AppColors.destructive;
    } else {
      shareText = 'Received ${entry.amount} BDT';
      shareColor = AppColors.success;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route line.
            Text(
              entry.routeDescription,
              style: theme.textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Details row: transport icon + date + fare.
            Row(
              children: [
                Icon(
                  transportIcon,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  dateFormat.format(entry.rideDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '${entry.amount} BDT',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Split direction.
            Text(
              'Split with co-rider',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Your share.
            Text(
              shareText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: shareColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
