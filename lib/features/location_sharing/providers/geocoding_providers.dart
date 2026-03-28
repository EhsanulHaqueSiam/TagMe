import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/location_sharing/data/services/geocoding_service.dart';

part 'geocoding_providers.g.dart';

/// Provides a singleton [GeocodingService] for ORS Pelias autocomplete.
@riverpod
GeocodingService geocodingService(Ref ref) {
  return GeocodingService();
}
