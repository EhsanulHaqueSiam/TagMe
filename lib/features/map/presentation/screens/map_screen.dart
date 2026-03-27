import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/tile_config.dart';
import 'package:tagme/features/map/presentation/widgets/map_top_bar.dart';
import 'package:tagme/features/map/presentation/widgets/my_location_fab.dart';
import 'package:tagme/features/map/presentation/widgets/student_bottom_sheet.dart';
import 'package:tagme/features/map/presentation/widgets/student_marker.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/map/providers/nearby_students_provider.dart';
import 'package:tagme/features/profile/data/models/student.dart';

/// Fallback center when GPS is not yet available (Dhaka, Bangladesh).
const _dhakaCenter = LatLng(23.8103, 90.4125);

/// Full-screen map with Stadia Maps tiles, user location blue dot, nearby student
/// markers with clustering, top bar, and FAB.
///
/// Centers on the user's GPS location at zoom 13. Nearby student markers
/// appear as clustered circular avatars with university-colored borders.
/// Tapping a marker shows a profile bottom sheet.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  /// Tracks latest user location for the FAB recenter.
  LatLng? _userLocation;

  /// Whether nearby students have loaded at least once (for fade-in animation).
  bool _studentsLoaded = false;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);
    final hasPermission = ref.watch(hasLocationPermissionProvider);
    final nearbyStudentsAsync = ref.watch(nearbyStudentsProvider);

    // Derive user's position or fall back to Dhaka center.
    final userLatLng = locationAsync.whenOrNull(
      data: (position) => LatLng(position.latitude, position.longitude),
    );

    // Update tracked location when GPS data arrives.
    if (userLatLng != null) {
      _userLocation = userLatLng;
    }

    final mapCenter = userLatLng ?? _dhakaCenter;

    // Build student markers from nearby students data.
    final nearbyStudents = nearbyStudentsAsync.value ?? <Student>[];
    if (nearbyStudents.isNotEmpty && !_studentsLoaded) {
      _studentsLoaded = true;
    }

    final studentMarkers = nearbyStudents
        .where((s) => s.geopoint != null)
        .map(
          (student) => Marker(
            point: LatLng(
              student.geopoint!.latitude,
              student.geopoint!.longitude,
            ),
            width: 48,
            height: 48,
            child: StudentMarker(
              student: student,
              onTap: () => _showStudentBottomSheet(context, student),
            ),
          ),
        )
        .toList();

    // Show error snackbar when location fails.
    ref.listen(currentLocationProvider, (previous, next) {
      if (next is AsyncError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Map layer (fills entire screen)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              // Explicit zoom 13 per CONTEXT.md: city-level default.
              // ignore: avoid_redundant_argument_values, prefer_int_literals
              initialZoom: 13.0,
            ),
            children: [
              // Stadia Maps tile layer
              TileLayer(
                urlTemplate: TileConfig.stadiaMapsTemplate,
                userAgentPackageName: TileConfig.userAgentPackageName,
                maxZoom: TileConfig.maxZoom,
              ),

              // User location blue dot marker (separate from cluster layer)
              if (userLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLatLng,
                      width: 16,
                      height: 16,
                      child: const _PulsingBlueDot(),
                    ),
                  ],
                ),

              // Nearby student markers with clustering
              if (studentMarkers.isNotEmpty)
                AnimatedOpacity(
                  opacity: _studentsLoaded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      markers: studentMarkers,
                      // Plan specifies explicit 80px cluster radius.
                      // ignore: avoid_redundant_argument_values
                      maxClusterRadius: 80,
                      size: const Size(48, 48),
                      markerChildBehavior: true,
                      builder: (context, markers) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                AppColors.accent.withValues(alpha: 0.8),
                          ),
                          child: Center(
                            child: Text(
                              '${markers.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),

          // Top bar overlay
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MapTopBar(),
          ),

          // My Location FAB (bottom-right)
          Positioned(
            bottom: 16,
            right: 16,
            child: MyLocationFab(
              onPressed: _recenterMap,
            ),
          ),

          // Location-denied banner
          if (!hasPermission)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin:
                      const EdgeInsets.only(top: 56, left: 16, right: 16),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Location access needed to find nearby students',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.onSurfaceDim),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            label: const Text('Enable Location'),
                            backgroundColor: AppColors.accent,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            onPressed: () => context.go('/permission'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Shows the student profile bottom sheet with a slide-up animation.
  void _showStudentBottomSheet(BuildContext context, Student student) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentBottomSheet(student: student),
    );
  }

  /// Animates the map back to the user's current location at zoom 15.
  void _recenterMap() {
    final target = _userLocation ?? _dhakaCenter;
    _mapController.move(target, 15);
  }
}

/// 16px pulsing blue dot marking the user's location on the map.
///
/// Outer ring at 30% opacity, solid accent center.
class _PulsingBlueDot extends StatelessWidget {
  const _PulsingBlueDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
