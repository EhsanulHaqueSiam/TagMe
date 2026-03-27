import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/fares/data/services/fare_calculator.dart';
import 'package:tagme/features/profile/data/models/student.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';
import 'package:tagme/features/rides/data/models/ride.dart';
import 'package:tagme/features/rides/data/repositories/ride_repository.dart';
import 'package:tagme/features/rides/data/services/route_service.dart';

part 'ride_providers.g.dart';

/// Posts a new ride by assembling all data from the form, fetching
/// route distance from ORS, computing fare, and saving to Firestore.
///
/// Returns the Firestore document ID of the created ride.
@riverpod
Future<String> postRide(
  Ref ref, {
  required double originLat,
  required double originLng,
  required String originAddress,
  required double destLat,
  required double destLng,
  required String destAddress,
  required String transportType,
  required DateTime departureTime,
  required int totalSeats,
  String? rideHailingTag,
}) async {
  // Get current user profile.
  final profileState = ref.read<AsyncValue<Student?>>(profileProvider);
  final profile = profileState.value;
  if (profile == null) {
    throw StateError('No profile found. Please set up your profile first.');
  }

  // Get route data (distance + polyline) from ORS.
  final routeService = ref.read(routeServiceProvider);
  final routeData = await routeService.getRoute(
    LatLng(originLat, originLng),
    LatLng(destLat, destLng),
  );

  // Compute fare estimate.
  final fareCalc = ref.read(fareCalculatorProvider);
  final estimatedFare = fareCalc.calculateTotalFare(
    transportType,
    routeData.distanceKm,
  );

  // Compute geohashes for origin and destination.
  final originGeoPoint = GeoPoint(originLat, originLng);
  final destGeoPoint = GeoPoint(destLat, destLng);
  final originGeohash = GeoFirePoint(originGeoPoint).geohash;
  final destGeohash = GeoFirePoint(destGeoPoint).geohash;

  // Encode polyline as List<List<double>> for Firestore storage.
  final polyline = routeData.polylinePoints
      .map((p) => [p.latitude, p.longitude])
      .toList();

  // Assemble the Ride object.
  final ride = Ride(
    posterId: profile.id ?? '',
    posterName: profile.name,
    posterUniversity: profile.university,
    posterGender: profile.gender,
    posterPhotoUrl: profile.photoUrl,
    originGeopoint: originGeoPoint,
    originGeohash: originGeohash,
    originAddress: originAddress,
    destinationGeopoint: destGeoPoint,
    destinationGeohash: destGeohash,
    destinationAddress: destAddress,
    transportType: transportType,
    rideHailingTag: rideHailingTag,
    departureTime: departureTime,
    totalSeats: totalSeats,
    routeDistanceKm: routeData.distanceKm,
    routePolyline: polyline,
    estimatedFare: estimatedFare,
  );

  // Save to Firestore and return document ID.
  final rideRepo = ref.read(rideRepositoryProvider);
  return rideRepo.createRide(ride);
}
