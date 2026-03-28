import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:tagme/features/rides/data/services/route_service.dart';

/// Result containing isochrone polygon rings for display on map.
class IsochroneResult {
  IsochroneResult({required this.polygons});

  /// List of polygon rings as LatLng points.
  /// Index 0: 5-minute zone, Index 1: 10-minute zone.
  final List<List<LatLng>> polygons;
}

/// Wraps ORS isochrone API for reachability zone generation.
class IsochroneService {
  IsochroneService() : _client = OpenRouteService(apiKey: orsApiKey);
  final OpenRouteService _client;

  /// Generates isochrone polygons for 5 and 10 minute ranges.
  ///
  /// [profile] should be one of: 'driving-car', 'cycling-road', 'foot-walking'.
  /// Returns null on failure (graceful degradation).
  Future<IsochroneResult?> getIsochrones({
    required double lat,
    required double lng,
    String profile = 'driving-car',
  }) async {
    try {
      final result = await _client.isochronesPost(
        locations: [ORSCoordinate(latitude: lat, longitude: lng)],
        range: [300, 600], // 5 min (300s) and 10 min (600s)
        profileOverride: _profileFromString(profile),
      );

      final polygons = <List<LatLng>>[];
      for (final feature in result.features) {
        final geometry = feature.geometry;
        // Isochrone geometry is listList type: List<List<ORSCoordinate>>
        // Take first ring from each polygon (outer ring)
        if (geometry.coordinates.isNotEmpty) {
          final ring = geometry.coordinates.first
              .map((c) => LatLng(c.latitude, c.longitude))
              .toList();
          if (ring.isNotEmpty) {
            polygons.add(ring);
          }
        }
      }
      return IsochroneResult(polygons: polygons);
    } catch (_) {
      return null;
    }
  }

  ORSProfile _profileFromString(String profile) {
    switch (profile) {
      case 'cycling-road':
        return ORSProfile.cyclingRoad;
      case 'foot-walking':
        return ORSProfile.footWalking;
      default:
        return ORSProfile.drivingCar;
    }
  }
}
