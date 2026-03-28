import 'package:open_route_service/open_route_service.dart';
import 'package:tagme/features/rides/data/services/route_service.dart';

/// Result from ORS Pelias geocoding autocomplete.
class GeocodingResult {
  GeocodingResult({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.secondaryLabel,
  });

  final String label;
  final double latitude;
  final double longitude;
  final String? secondaryLabel;
}

/// Wraps OpenRouteService Pelias geocoding autocomplete for place search.
///
/// Focus point is Dhaka center (23.8103, 90.4125) for Bangladesh-biased
/// results. Requires minimum 3-character query to avoid excessive API calls.
class GeocodingService {
  GeocodingService() : _client = OpenRouteService(apiKey: orsApiKey);

  final OpenRouteService _client;

  /// Queries ORS Pelias geocoding autocomplete.
  /// Returns empty list if query is shorter than 3 characters.
  /// Focus point is Dhaka center (23.8103, 90.4125) for Bangladesh-biased
  /// results.
  Future<List<GeocodingResult>> autocomplete(String query) async {
    if (query.length < 3) return [];

    try {
      final result = await _client.geocodeAutoCompleteGet(
        text: query,
        focusPointCoordinate: const ORSCoordinate(
          latitude: 23.8103,
          longitude: 90.4125,
        ),
      );

      return result.features.map((f) {
        final props = f.properties;
        // Point geometry: coordinates[0][0] is the ORSCoordinate.
        final coords = f.geometry.coordinates[0][0];
        return GeocodingResult(
          label: (props['name'] as String?) ??
              (props['label'] as String?) ??
              'Unknown',
          latitude: coords.latitude,
          longitude: coords.longitude,
          secondaryLabel: props['label'] as String?,
        );
      }).toList();
    } on Exception catch (_) {
      return [];
    }
  }
}
