import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/core/utils/location_utils.dart';
import 'package:tagme/features/rides/data/models/ride.dart';

part 'matching_service.g.dart';

/// Pure-Dart service for filtering and ranking ride matches.
@riverpod
MatchingService matchingService(Ref ref) {
  return MatchingService();
}

class MatchingService {
  /// Maximum destination distance in km for a ride to be considered a match.
  static const _maxDestinationDistanceKm = 1.0;

  /// Maximum departure time difference for matching (in minutes).
  static const _maxTimeDifferenceMinutes = 30;

  /// Filters and ranks rides based on destination proximity, time window,
  /// transport type, and gender preference.
  ///
  /// Matching rules (per CONTEXT.md):
  /// - Destination within 1.0 km of [userDestination]
  /// - Departure time within +/- 30 minutes of [userDepartureTime]
  /// - Transport type match (if [transportType] is provided)
  /// - Status is 'active' or 'full'
  ///
  /// Ranking (soft filters):
  /// - Same-gender poster ranked higher
  /// - Then by departure time (soonest first)
  List<Ride> filterAndRankRides({
    required List<Ride> rides,
    required GeoPoint userDestination,
    required DateTime userDepartureTime,
    required String userGender,
    String? transportType,
  }) {
    final filtered = rides.where((ride) {
      // Status filter.
      if (ride.status != 'active' && ride.status != 'full') return false;

      // Transport type filter (if specified).
      if (transportType != null && ride.transportType != transportType) {
        return false;
      }

      // Time window filter (+/- 30 minutes).
      final timeDiff =
          ride.departureTime.difference(userDepartureTime).inMinutes.abs();
      if (timeDiff > _maxTimeDifferenceMinutes) return false;

      // Destination proximity filter (1.0 km).
      if (ride.destinationGeopoint == null) return false;
      final distance = calculateDistanceKm(
        userDestination.latitude,
        userDestination.longitude,
        ride.destinationGeopoint!.latitude,
        ride.destinationGeopoint!.longitude,
      );
      if (distance > _maxDestinationDistanceKm) return false;

      return true;
    }).toList();

    // Sort: same gender first, then by departure time (soonest first).
    filtered.sort((a, b) {
      final aGenderMatch = a.posterGender == userGender ? 0 : 1;
      final bGenderMatch = b.posterGender == userGender ? 0 : 1;
      if (aGenderMatch != bGenderMatch) return aGenderMatch - bGenderMatch;
      return a.departureTime.compareTo(b.departureTime);
    });

    return filtered;
  }
}
