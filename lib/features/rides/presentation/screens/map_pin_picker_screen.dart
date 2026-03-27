import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/tile_config.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/rides/data/services/route_service.dart';

/// Full-screen map for picking a location by panning and confirming.
///
/// Used for origin ("Pick-up Point") and destination ("Drop-off Point")
/// selection in the Post Ride flow. The pin is fixed at center; the user
/// pans the map underneath. Reverse geocoding updates the address in
/// real time (debounced 500ms). Confirms by popping with a result map
/// containing lat, lng, and address.
class MapPinPickerScreen extends ConsumerStatefulWidget {
  const MapPinPickerScreen({required this.mode, this.initialCenter, super.key});

  /// 'origin' or 'destination'.
  final String mode;

  /// Optional initial center (e.g. previously picked origin for
  /// destination mode).
  final LatLng? initialCenter;

  @override
  ConsumerState<MapPinPickerScreen> createState() =>
      _MapPinPickerScreenState();
}

class _MapPinPickerScreenState extends ConsumerState<MapPinPickerScreen> {
  final MapController _mapController = MapController();

  /// Debounce timer for reverse geocoding.
  Timer? _debounce;

  /// Current address resolved by reverse geocoding.
  String _address = '';

  /// Whether a geocode request is in flight.
  bool _isGeocoding = false;

  /// The current center of the map (updated on every move).
  LatLng? _currentCenter;

  /// Fallback Dhaka center when no location is available.
  static const _dhakaCenter = LatLng(23.8103, 90.4125);

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _initialCenter {
    if (widget.initialCenter != null) return widget.initialCenter!;
    final locationAsync = ref.read(currentLocationProvider);
    final userLatLng = locationAsync.whenOrNull(
      data: (position) => LatLng(position.latitude, position.longitude),
    );
    return userLatLng ?? _dhakaCenter;
  }

  void _onMapEvent(MapCamera camera, bool hasGesture) {
    _currentCenter = camera.center;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _reverseGeocode(_currentCenter!);
    });
  }

  Future<void> _reverseGeocode(LatLng point) async {
    if (!mounted) return;
    setState(() => _isGeocoding = true);

    final routeService = ref.read(routeServiceProvider);
    final address = await routeService.reverseGeocode(point);

    if (!mounted) return;
    setState(() {
      _address = address;
      _isGeocoding = false;
    });
  }

  void _confirmLocation() {
    final center = _currentCenter ?? _initialCenter;
    final result = <String, dynamic>{
      'lat': center.latitude,
      'lng': center.longitude,
      'address': _address.isNotEmpty ? _address : 'Selected location',
    };
    context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOrigin = widget.mode == 'origin';
    final modeLabel =
        isOrigin ? 'Set Pick-up Point' : 'Set Drop-off Point';
    final initialCenter = _initialCenter;

    return Scaffold(
      body: Stack(
        children: [
          // Map layer (fills entire screen).
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15,
              onPositionChanged: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: TileConfig.stadiaMapsTemplate,
                userAgentPackageName: TileConfig.userAgentPackageName,
                maxZoom: TileConfig.maxZoom,
              ),
            ],
          ),

          // Center pin overlay -- pin tip touches center point.
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_pin,
                    size: 48,
                    color: AppColors.accent,
                  ),
                  // Subtle drop shadow below pin.
                  Container(
                    width: 12,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top overlay -- mode label.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Center(
                  child: Text(
                    modeLabel,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          blurRadius: 8,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating back arrow.
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black38,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),

          // Bottom overlay -- address card + confirm button.
          Positioned(
            bottom: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Address text or shimmer placeholder.
                  SizedBox(
                    height: 24,
                    child: _isGeocoding
                        ? _buildShimmer()
                        : Text(
                            _address.isNotEmpty
                                ? _address
                                : 'Move the map to select a location',
                            style: theme.textTheme.bodyLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Confirm Location button.
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirm Location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a shimmer placeholder for the address text while geocoding.
  Widget _buildShimmer() {
    return Container(
      height: 16,
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
