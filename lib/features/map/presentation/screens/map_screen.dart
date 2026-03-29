import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/tile_config.dart';
import 'package:tagme/features/location_sharing/data/services/isochrone_service.dart';
import 'package:tagme/features/location_sharing/data/services/poi_service.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/isochrone_legend.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/isochrone_overlay.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/poi_chip_bar.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/poi_info_sheet.dart';
import 'package:tagme/features/map/presentation/widgets/map_top_bar.dart';
import 'package:tagme/features/map/presentation/widgets/my_location_fab.dart';
import 'package:tagme/features/map/presentation/widgets/student_bottom_sheet.dart';
import 'package:tagme/features/map/presentation/widgets/student_marker.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/map/providers/nearby_students_provider.dart';
import 'package:tagme/features/location_sharing/data/services/maps_share_service.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/map_context_sheet.dart';
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

  // POI state
  int? _selectedPOICategoryId;
  List<POIResult> _poiResults = [];
  bool _isLoadingPOIs = false;

  // Isochrone state
  List<List<LatLng>>? _isochronePolygons;
  String _isochroneProfile = 'driving-car';
  LatLng? _isochroneCenter;
  bool _isLoadingIsochrone = false;

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
              onLongPress: (tapPosition, latLng) {
                _showMapContextSheet(context, latLng);
              },
            ),
            children: [
              // Stadia Maps tile layer
              TileLayer(
                urlTemplate: TileConfig.tileUrl(context),
                userAgentPackageName: TileConfig.userAgentPackageName,
                maxZoom: TileConfig.maxZoom,
              ),

              // Isochrone polygon overlay (rendered below markers)
              if (_isochronePolygons != null &&
                  _isochronePolygons!.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    if (_isochronePolygons!.isNotEmpty)
                      Polygon(
                        points: _isochronePolygons![0],
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderColor:
                            AppColors.accent.withValues(alpha: 0.6),
                        borderStrokeWidth: 2.0,
                      ),
                    if (_isochronePolygons!.length > 1)
                      Polygon(
                        points: _isochronePolygons![1],
                        color: AppColors.accent.withValues(alpha: 0.06),
                        borderColor:
                            AppColors.accent.withValues(alpha: 0.6),
                        borderStrokeWidth: 1.0,
                      ),
                  ],
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

              // POI markers (green circles with category icons)
              if (_poiResults.isNotEmpty)
                MarkerLayer(
                  markers: _poiResults
                      .map(
                        (poi) => Marker(
                          point: LatLng(poi.latitude, poi.longitude),
                          width: 32,
                          height: 32,
                          child: GestureDetector(
                            onTap: () => _showPOIInfoSheet(context, poi),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _poiIcon(poi.categoryId),
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
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

          // POI category chip bar (below map top bar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 0,
            right: 0,
            child: POIChipBar(
              selectedCategoryId: _selectedPOICategoryId,
              onCategorySelected: _handlePOICategorySelected,
            ),
          ),

          // Loading indicator for POIs
          if (_isLoadingPOIs)
            Positioned(
              top: MediaQuery.of(context).padding.top + 104,
              left: 0,
              right: 0,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),

          // Isochrone legend and controls
          if (_isochronePolygons != null) ...[
            // Legend (bottom-left, above attribution)
            const Positioned(
              bottom: 80,
              left: 16,
              child: IsochroneLegend(),
            ),
            // Transport mode selector (bottom center)
            Positioned(
              bottom: 16,
              left: 16,
              right: 80,
              child: IsochroneOverlay(
                selectedProfile: _isochroneProfile,
                onProfileChanged: _regenerateIsochrone,
                onDismiss: () => setState(() {
                  _isochronePolygons = null;
                  _isochroneCenter = null;
                }),
              ),
            ),
          ],

          // Loading indicator for isochrone
          if (_isLoadingIsochrone)
            const Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),

          // Search FAB (above my-location FAB)
          Positioned(
            bottom: 80,
            right: 16,
            child: Semantics(
              label: 'Search for places',
              child: FloatingActionButton(
                heroTag: 'searchFab',
                onPressed: () async {
                  final result = await context
                      .push<Map<String, dynamic>>('/places/search');
                  if (result != null && mounted) {
                    final lat = result['lat'] as double;
                    final lng = result['lng'] as double;
                    _mapController.move(LatLng(lat, lng), 15);
                  }
                },
                backgroundColor: AppColors.accent,
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ),
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
                                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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

  /// Shows a context sheet with location actions on map long-press.
  void _showMapContextSheet(BuildContext context, LatLng point) {
    final mapsService = MapsShareService();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MapContextSheet(
        onOpenInMaps: () {
          Navigator.of(context).pop();
          mapsService.openInGoogleMaps(
            latitude: point.latitude,
            longitude: point.longitude,
          );
        },
        onShare: () {
          Navigator.of(context).pop();
          mapsService.shareLocation(
            latitude: point.latitude,
            longitude: point.longitude,
          );
        },
        onShowReachability: () {
          Navigator.of(context).pop();
          _generateIsochrone(point);
        },
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

  /// Handles POI category chip selection.
  Future<void> _handlePOICategorySelected(int? categoryId) async {
    setState(() {
      _selectedPOICategoryId = categoryId;
      if (categoryId == null) {
        _poiResults = [];
        return;
      }
      _isLoadingPOIs = true;
    });
    if (categoryId == null) return;

    final center = _userLocation ?? _dhakaCenter;
    final service = POIService();
    final results = await service.searchPOIs(
      lat: center.latitude,
      lng: center.longitude,
      categoryId: categoryId,
      radiusMeters: 2000,
    );
    if (mounted) {
      setState(() {
        _poiResults = results;
        _isLoadingPOIs = false;
      });
    }
  }

  /// Shows a bottom sheet with POI details and action buttons.
  void _showPOIInfoSheet(BuildContext context, POIResult poi) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => POIInfoSheet(poi: poi),
    );
  }

  /// Generates isochrone polygons for the given map point.
  Future<void> _generateIsochrone(LatLng point) async {
    setState(() {
      _isLoadingIsochrone = true;
      _isochroneCenter = point;
    });
    final service = IsochroneService();
    final result = await service.getIsochrones(
      lat: point.latitude,
      lng: point.longitude,
      profile: _isochroneProfile,
    );
    if (mounted) {
      setState(() {
        _isochronePolygons = result?.polygons;
        _isLoadingIsochrone = false;
      });
    }
  }

  /// Regenerates isochrone with a different transport profile.
  Future<void> _regenerateIsochrone(String profile) async {
    setState(() {
      _isochroneProfile = profile;
    });
    if (_isochroneCenter != null) {
      await _generateIsochrone(_isochroneCenter!);
    }
  }

  /// Returns the appropriate Material icon for a POI category.
  IconData _poiIcon(int categoryId) {
    switch (categoryId) {
      case POICategories.universities:
        return Icons.school;
      case POICategories.busStops:
        return Icons.directions_bus;
      case POICategories.restaurants:
        return Icons.restaurant;
      case POICategories.hospitals:
        return Icons.local_hospital;
      default:
        return Icons.place;
    }
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
