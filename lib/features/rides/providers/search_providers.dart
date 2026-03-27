import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';
import 'package:tagme/features/rides/data/models/ride.dart';
import 'package:tagme/features/rides/data/repositories/ride_repository.dart';
import 'package:tagme/features/rides/data/services/matching_service.dart';

part 'search_providers.g.dart';

/// Streams nearby active rides sorted by departure time (soonest first).
///
/// Reads the user's current GPS location and queries rides within 1 km
/// of the origin. Returns an empty list when location is unavailable.
@riverpod
Stream<List<Ride>> nearbyRides(Ref ref) {
  final location = ref.watch(currentLocationProvider).value;
  if (location == null) return Stream.value([]);

  final userGeoPoint = GeoPoint(location.latitude, location.longitude);
  final repo = ref.watch(rideRepositoryProvider);

  return repo.ridesNearOrigin(userGeoPoint).map((rides) {
    rides.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    return rides;
  });
}

/// Streams rides posted by the current user.
///
/// Reads the locally persisted profile ID from SharedPreferences.
/// Returns an empty list when no profile ID is found.
@riverpod
Stream<List<Ride>> myRides(Ref ref) async* {
  final prefs = await SharedPreferences.getInstance();
  final profileId = prefs.getString('local_profile_id');
  if (profileId == null) {
    yield [];
    return;
  }

  final repo = ref.watch(rideRepositoryProvider);
  yield* repo.myRides(profileId);
}

/// Streams search results filtered and ranked by the matching service.
///
/// Takes search parameters (destination, departure time, transport type)
/// and pipes results through [MatchingService.filterAndRankRides] for
/// destination proximity (1 km), time window (+/- 30 min), transport filter,
/// and gender-preference ranking.
@riverpod
Stream<List<Ride>> searchRides(
  Ref ref, {
  GeoPoint? destination,
  DateTime? departureTime,
  String? transportType,
}) {
  final location = ref.watch(currentLocationProvider).value;
  if (location == null || destination == null) return Stream.value([]);

  final userGeoPoint = GeoPoint(location.latitude, location.longitude);
  final repo = ref.watch(rideRepositoryProvider);
  final matcher = ref.watch(matchingServiceProvider);

  // Read user gender from profile for gender-preference ranking.
  final profileAsync = ref.watch(profileProvider);
  final userGender = profileAsync.value?.gender ?? 'other';
  final effectiveDepartureTime = departureTime ?? DateTime.now();

  return repo.ridesNearOrigin(userGeoPoint).map((rides) {
    return matcher.filterAndRankRides(
      rides: rides,
      userDestination: destination,
      userDepartureTime: effectiveDepartureTime,
      userGender: userGender,
      transportType: transportType,
    );
  });
}
