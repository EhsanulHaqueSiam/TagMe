import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/core/utils/location_utils.dart';

part 'route_service.g.dart';

// TODO: Set your ORS API key from https://openrouteservice.org/dev/#/signup
const orsApiKey = '';

/// Route data returned by [RouteService.getRoute].
class RouteData {
  RouteData({required this.distanceKm, required this.polylinePoints});

  /// Road distance in kilometers.
  final double distanceKm;

  /// Decoded polyline as list of lat/lng points.
  final List<LatLng> polylinePoints;
}

/// Wraps OpenRouteService API for directions and reverse geocoding.
@riverpod
RouteService routeService(Ref ref) {
  return RouteService(apiKey: orsApiKey);
}

class RouteService {
  RouteService({required String apiKey})
      : _client = OpenRouteService(apiKey: apiKey);

  final OpenRouteService _client;

  /// Fetches driving directions between [origin] and [destination].
  ///
  /// Returns [RouteData] with road distance and polyline points.
  /// Falls back to straight-line Haversine * 1.3 on failure.
  Future<RouteData> getRoute(LatLng origin, LatLng destination) async {
    try {
      final coords = await _client.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(
          latitude: origin.latitude,
          longitude: origin.longitude,
        ),
        endCoordinate: ORSCoordinate(
          latitude: destination.latitude,
          longitude: destination.longitude,
        ),
        profileOverride: ORSProfile.drivingCar,
      );

      // Convert ORS coordinates to LatLng points.
      final points =
          coords.map((c) => LatLng(c.latitude, c.longitude)).toList();

      // Sum Haversine distances between consecutive polyline points
      // for road distance.
      var totalDistanceKm = 0.0;
      for (var i = 0; i < points.length - 1; i++) {
        totalDistanceKm += calculateDistanceKm(
          points[i].latitude,
          points[i].longitude,
          points[i + 1].latitude,
          points[i + 1].longitude,
        );
      }

      return RouteData(distanceKm: totalDistanceKm, polylinePoints: points);
    } catch (_) {
      // Fallback: straight-line distance * 1.3 road factor, no polyline.
      final straightLine = calculateDistanceKm(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude,
      );
      return RouteData(
        distanceKm: straightLine * 1.3,
        polylinePoints: [],
      );
    }
  }

  /// Reverse geocodes a [point] to a human-readable address.
  ///
  /// Returns 'Unknown location' on failure.
  Future<String> reverseGeocode(LatLng point) async {
    try {
      final result = await _client.geocodeReverseGet(
        point: ORSCoordinate(
          latitude: point.latitude,
          longitude: point.longitude,
        ),
        size: 1,
      );
      if (result.features.isNotEmpty) {
        final properties = result.features.first.properties;
        return (properties['label'] as String?) ?? 'Unknown location';
      }
      return 'Unknown location';
    } catch (_) {
      return 'Unknown location';
    }
  }
}
