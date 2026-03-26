import 'dart:math';

/// Formats a distance in kilometers to a human-readable string.
///
/// Distances under 1 km are shown in meters (e.g., "750 m away").
/// Distances >= 1 km are shown with one decimal (e.g., "1.2 km away").
String formatDistance(double distanceKm) {
  if (distanceKm < 1) {
    return '${(distanceKm * 1000).round()} m away';
  }
  return '${distanceKm.toStringAsFixed(1)} km away';
}

/// Calculates the great-circle distance between two coordinates using the
/// Haversine formula.
///
/// Returns distance in kilometers.
double calculateDistanceKm(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadius = 6371.0; // km
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) *
          cos(_toRad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _toRad(double deg) => deg * pi / 180;
