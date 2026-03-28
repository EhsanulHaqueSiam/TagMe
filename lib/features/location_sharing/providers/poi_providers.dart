import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/location_sharing/data/services/poi_service.dart';

part 'poi_providers.g.dart';

/// Provides a singleton [POIService] for ORS POI search.
@riverpod
POIService poiService(Ref ref) {
  return POIService();
}
