import 'package:open_route_service/open_route_service.dart';
import 'package:tagme/features/rides/data/services/route_service.dart';

/// Result from an ORS POI search.
class POIResult {
  POIResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    this.distance,
  });

  final String name;
  final double latitude;
  final double longitude;
  final int categoryId;
  final double? distance; // meters from search center

  String get categoryLabel {
    switch (categoryId) {
      case 150:
        return 'University';
      case 260:
        return 'Bus Stop';
      case 570:
        return 'Restaurant';
      case 210:
        return 'Hospital';
      default:
        return 'Place';
    }
  }
}

/// ORS POI category IDs for TagMe-relevant categories.
class POICategories {
  static const int universities = 150; // education.university
  static const int busStops = 260; // transport.bus_stop
  static const int restaurants = 570; // sustenance.restaurant
  static const int hospitals = 210; // healthcare.hospital

  static const List<({int id, String label, String icon})> all = [
    (id: universities, label: 'Universities', icon: 'school'),
    (id: busStops, label: 'Bus Stops', icon: 'directions_bus'),
    (id: restaurants, label: 'Restaurants', icon: 'restaurant'),
    (id: hospitals, label: 'Hospitals', icon: 'local_hospital'),
  ];
}

/// Wraps ORS POI search API for nearby place discovery.
class POIService {
  POIService() : _client = OpenRouteService(apiKey: orsApiKey);
  final OpenRouteService _client;

  /// Searches for POIs of a given category within a radius of the center point.
  ///
  /// Uses ORS poisDataPost with a Point geometry and buffer radius.
  /// Returns empty list on failure (graceful degradation).
  Future<List<POIResult>> searchPOIs({
    required double lat,
    required double lng,
    required int categoryId,
    double radiusMeters = 500,
  }) async {
    try {
      final result = await _client.poisDataPost(
        request: 'pois',
        geometry: {
          'geojson': {
            'type': 'Point',
            'coordinates': [lng, lat],
          },
          'buffer': radiusMeters.toInt(),
        },
        filters: {
          'category_ids': [categoryId],
        },
        limit: 20,
        sortBy: 'distance',
      );

      return result.features.map((f) {
        final coords = f.geometry.coordinates;
        final props = f.properties;
        // Point geometry: single coordinate wrapped in list
        final coord = coords.isNotEmpty && coords.first.isNotEmpty
            ? coords.first.first
            : null;
        if (coord == null) return null;

        final osmTags = props['osm_tags'] as Map<String, dynamic>?;
        final name = (osmTags?['name'] as String?) ?? 'Unnamed';
        final distance = (props['distance'] as num?)?.toDouble();

        return POIResult(
          name: name,
          latitude: coord.latitude,
          longitude: coord.longitude,
          categoryId: categoryId,
          distance: distance,
        );
      }).whereType<POIResult>().toList();
    } catch (_) {
      return [];
    }
  }
}
