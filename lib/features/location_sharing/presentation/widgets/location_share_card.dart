import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/features/chat/data/models/message.dart';
import 'package:tagme/features/location_sharing/data/services/maps_share_service.dart';

/// Special message card for location_shared message type.
///
/// Displays a blue-50 card with location icon, "Location shared" label,
/// location label text, and "Open in Maps" / "Share" action buttons.
/// Follows the same visual pattern as [PhoneShareCard].
class LocationShareCard extends StatelessWidget {
  const LocationShareCard({
    super.key,
    required this.message,
    required this.isSent,
  });

  final Message message;
  final bool isSent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth = MediaQuery.of(context).size.width * 0.8;

    return Semantics(
      label: 'Location shared by ${message.senderName}: '
          '${message.locationLabel ?? ''}. Actions: open in maps, share.',
      child: Center(
        child: SizedBox(
          width: cardWidth,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender name if received
                if (!isSent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceDim,
                      ),
                    ),
                  ),

                // Icon + label row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 20,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Location shared',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location label
                if (message.locationLabel != null)
                  Text(
                    message.locationLabel!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),

                // Action buttons row
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _openInMaps,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Open in Maps'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _shareLocation,
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openInMaps() {
    MapsShareService().openInGoogleMaps(
      latitude: message.latitude!,
      longitude: message.longitude!,
      label: message.locationLabel,
    );
  }

  void _shareLocation() {
    MapsShareService().shareLocation(
      latitude: message.latitude!,
      longitude: message.longitude!,
      label: message.locationLabel,
    );
  }
}
