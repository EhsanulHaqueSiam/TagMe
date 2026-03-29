import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/core/constants/transport_types.dart';
import 'package:tagme/features/rides/data/models/ride.dart';

/// Reusable ride card component used in ride lists and search results.
///
/// Shows transport icon, poster info, route, time, fare, and seats badge.
/// When [isMatch] is true, a left accent border highlights the card.
/// When [isOwnRide] is true, a three-dot menu replaces the seats badge.
class RideCard extends StatelessWidget {
  const RideCard({
    required this.ride,
    this.isMatch = false,
    this.isOwnRide = false,
    this.onTap,
    super.key,
  });

  final Ride ride;
  final bool isMatch;
  final bool isOwnRide;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableSeats = ride.totalSeats - ride.filledSeats;
    final isFull = availableSeats <= 0;

    // Resolve transport type safely.
    final transportIndex = TransportType.values.indexWhere(
      (t) => t.name == ride.transportType,
    );
    final transport =
        transportIndex >= 0 ? TransportType.values[transportIndex] : null;

    final semantics = '${ride.posterName} ride '
        'from ${ride.originAddress} '
        'to ${ride.destinationAddress} '
        'at ${_formatTime(ride.departureTime)}, '
        '${ride.filledSeats}/${ride.totalSeats} seats, '
        '${transport?.label ?? ride.transportType}, '
        '${ride.estimatedFare} BDT';

    return Semantics(
      label: semantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 120),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left accent border for matches.
              if (isMatch)
                Container(
                  width: 3,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),

              // Card content with padding.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: transport icon + seats.
                      _buildLeftColumn(theme, transport),

                      const SizedBox(width: 12),

                      // Center column: poster info, route, time/fare.
                      Expanded(
                        child: _buildCenterColumn(theme, transport),
                      ),

                      // Right column: hailing tag, seats badge or menu.
                      _buildRightColumn(theme, isFull, availableSeats),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(ThemeData theme, TransportType? transport) {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          Icon(
            transport?.icon ?? Icons.directions,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${ride.filledSeats}/${ride.totalSeats}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterColumn(ThemeData theme, TransportType? transport) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: poster name + university chip.
        Row(
          children: [
            Flexible(
              child: Text(
                ride.posterName,
                style: theme.textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              height: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.getUniversityColor(ride.posterUniversity),
                ),
              ),
              child: Center(
                child: Text(
                  ride.posterUniversity,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.getUniversityColor(ride.posterUniversity),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Row 2: Route visualization (origin -> destination).
        _buildRouteRow(theme),

        const SizedBox(height: AppSpacing.sm),

        // Row 3: time + fare.
        Row(
          children: [
            Text(
              _formatTime(ride.departureTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '~${ride.estimatedFare} BDT',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteRow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Origin row.
        Row(
          children: [
            _Dot(color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                ride.originAddress,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Connector line.
        Padding(
          padding: const EdgeInsets.only(left: 3.5),
          child: Container(
            width: 1,
            height: 4,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        // Destination row.
        Row(
          children: [
            const _Dot(color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                ride.destinationAddress,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightColumn(ThemeData theme, bool isFull, int availableSeats) {
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ride-hailing tag badge.
          if (ride.rideHailingTag != null) ...[
            Container(
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  ride.rideHailingTag!,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Seats badge / own ride menu / full badge.
          if (isOwnRide)
            Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant)
          else if (isFull)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Full',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$availableSeats left',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Formats departure time as "Today, 8:30 AM", "Tomorrow, 8:30 AM",
  /// or "Mon, Mar 30, 8:30 AM".
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final rideDay = DateTime(time.year, time.month, time.day);
    final timeStr = DateFormat('h:mm a').format(time);

    if (rideDay == today) return 'Today, $timeStr';
    if (rideDay == tomorrow) return 'Tomorrow, $timeStr';
    return '${DateFormat('EEE, MMM d').format(time)}, $timeStr';
  }
}

/// 8px colored circle used in route visualization.
class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
