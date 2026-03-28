import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/tile_config.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/live_location_marker.dart';
import 'package:tagme/features/location_sharing/providers/live_location_providers.dart';

/// 200px inline flutter_map that shows live location markers in the chat.
///
/// Renders user's own marker as a solid accent dot and partner's marker
/// as a pulsing [LiveLocationMarker]. Auto-centers to fit all markers.
/// Stale locations (>60s since updatedAt) show dimmed markers without pulse.
class EmbeddedLiveMap extends ConsumerWidget {
  const EmbeddedLiveMap({
    super.key,
    required this.conversationId,
    required this.currentUserId,
  });

  final String conversationId;
  final String currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveLocationsAsync =
        ref.watch(activeLiveLocationsProvider(conversationId));

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: liveLocationsAsync.when(
          loading: () => Container(
            color: AppColors.surfaceVariant,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => Container(
            color: AppColors.surfaceVariant,
            child: const Center(
              child: Icon(Icons.map, color: AppColors.onSurfaceDim),
            ),
          ),
          data: (locations) {
            if (locations.isEmpty) {
              return Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child:
                      Icon(Icons.location_off, color: AppColors.onSurfaceDim),
                ),
              );
            }

            final now = DateTime.now();
            final markers = <Marker>[];
            final points = <LatLng>[];

            for (final loc in locations) {
              final lat = loc['latitude'] as double?;
              final lng = loc['longitude'] as double?;
              final userId = loc['userId'] as String? ?? '';
              final accuracy = (loc['accuracy'] as num?)?.toDouble() ?? 0;

              if (lat == null || lng == null) continue;

              final point = LatLng(lat, lng);
              points.add(point);

              // Stale detection: >60s since updatedAt
              bool isStale = false;
              final updatedAt = loc['updatedAt'];
              if (updatedAt is Timestamp) {
                final diff = now.difference(updatedAt.toDate());
                isStale = diff.inSeconds > 60;
              }

              final isCurrentUser = userId == currentUserId;

              markers.add(
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: isCurrentUser
                      ? _buildSelfMarker()
                      : LiveLocationMarker(
                          accuracy: accuracy,
                          isStale: isStale,
                        ),
                ),
              );
            }

            // Compute map center and bounds
            MapOptions mapOptions;
            if (points.length >= 2) {
              final bounds = LatLngBounds.fromPoints(points);
              mapOptions = MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(48),
                ),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              );
            } else {
              mapOptions = MapOptions(
                initialCenter: points.first,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              );
            }

            return FlutterMap(
              options: mapOptions,
              children: [
                TileLayer(
                  urlTemplate: TileConfig.tileUrl(context),
                  userAgentPackageName: TileConfig.userAgentPackageName,
                  maxZoom: TileConfig.maxZoom,
                ),
                MarkerLayer(markers: markers),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Solid accent dot for the current user's own position.
  Widget _buildSelfMarker() {
    return Center(
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
