import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/features/location_sharing/data/services/maps_share_service.dart';
import 'package:tagme/features/location_sharing/data/services/poi_service.dart';

/// Bottom sheet showing POI details with action buttons.
///
/// Displays the POI name, category, distance, and provides three actions:
/// Open in Maps, Share, and Directions (via [MapsShareService]).
class POIInfoSheet extends StatelessWidget {
  const POIInfoSheet({super.key, required this.poi});

  final POIResult poi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mapsService = MapsShareService();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // POI name
            Text(
              poi.name,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),

            // Category and distance
            Row(
              children: [
                Text(
                  poi.categoryLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (poi.distance != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '\u2022',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    _formatDistance(poi.distance!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    mapsService.openInGoogleMaps(
                      latitude: poi.latitude,
                      longitude: poi.longitude,
                      label: poi.name,
                    );
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open in Maps'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    mapsService.shareLocation(
                      latitude: poi.latitude,
                      longitude: poi.longitude,
                      label: poi.name,
                    );
                  },
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    mapsService.openDirections(
                      destLat: poi.latitude,
                      destLng: poi.longitude,
                      label: poi.name,
                    );
                  },
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}
