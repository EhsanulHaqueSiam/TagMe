import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagme/features/fares/data/services/fare_calculator.dart';
import 'package:tagme/features/profile/data/repositories/profile_repository.dart';
import 'package:tagme/features/rides/data/models/recurring_schedule.dart';
import 'package:tagme/features/rides/data/models/ride.dart';
import 'package:tagme/features/rides/data/repositories/ride_repository.dart';
import 'package:tagme/features/rides/data/repositories/schedule_repository.dart';
import 'package:tagme/features/rides/data/services/route_service.dart';

part 'schedule_providers.g.dart';

/// Streams active schedules for the current user.
@riverpod
Stream<List<RecurringSchedule>> mySchedules(Ref ref) async* {
  final prefs = await SharedPreferences.getInstance();
  final studentId = prefs.getString('local_profile_id');
  if (studentId == null) {
    yield [];
    return;
  }
  final repo = ref.watch(scheduleRepositoryProvider);
  yield* repo.getSchedules(studentId);
}

/// Creates a new recurring schedule from form parameters.
@riverpod
Future<String> createSchedule(
  Ref ref, {
  required double originLat,
  required double originLng,
  required String originAddress,
  required double destinationLat,
  required double destinationLng,
  required String destinationAddress,
  required String transportType,
  String? rideHailingTag,
  required int totalSeats,
  required String departureTime,
  required List<int> daysOfWeek,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final studentId = prefs.getString('local_profile_id');
  if (studentId == null) throw Exception('No profile found');

  final originGeopoint = GeoPoint(originLat, originLng);
  final destinationGeopoint = GeoPoint(destinationLat, destinationLng);
  final originGeohash = GeoFirePoint(originGeopoint).geohash;
  final destinationGeohash = GeoFirePoint(destinationGeopoint).geohash;

  final schedule = RecurringSchedule(
    studentId: studentId,
    originGeopoint: originGeopoint,
    originGeohash: originGeohash,
    originAddress: originAddress,
    destinationGeopoint: destinationGeopoint,
    destinationGeohash: destinationGeohash,
    destinationAddress: destinationAddress,
    transportType: transportType,
    rideHailingTag: rideHailingTag,
    totalSeats: totalSeats,
    departureTime: departureTime,
    daysOfWeek: daysOfWeek,
  );

  final repo = ref.read(scheduleRepositoryProvider);
  return repo.createSchedule(schedule);
}

/// Processes recurring schedules on app open.
///
/// For each active schedule whose day matches today and hasn't been posted
/// yet today, auto-creates a ride and marks the schedule as posted.
/// This is non-fatal -- the app continues even if auto-posting fails.
Future<void> processRecurringSchedules(String studentId) async {
  // Create direct instances since we're called from main() without Ref.
  final firestore = FirebaseFirestore.instance;
  final scheduleRepo = ScheduleRepository(firestore: firestore);
  final rideRepo = RideRepository(firestore: firestore);
  final routeService = RouteService(apiKey: '');
  final fareCalc = FareCalculator();

  final now = DateTime.now();
  final todayStr = DateFormat('yyyy-MM-dd').format(now);

  final schedules = await scheduleRepo.getActiveSchedulesForToday(studentId);

  for (final schedule in schedules) {
    // Skip if already posted today.
    if (schedule.lastPostedDate == todayStr) continue;

    // Parse departure time and skip if already past.
    final timeParts = schedule.departureTime.split(':');
    if (timeParts.length != 2) continue;
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final departureToday = DateTime(now.year, now.month, now.day, hour, minute);
    if (departureToday.isBefore(now)) continue;

    try {
      // Get route data for distance and polyline.
      final originGeo = schedule.originGeopoint;
      final destGeo = schedule.destinationGeopoint;

      double distanceKm;
      List<List<double>> polyline;

      if (originGeo != null && destGeo != null) {
        final routeData = await routeService.getRoute(
          LatLng(originGeo.latitude, originGeo.longitude),
          LatLng(destGeo.latitude, destGeo.longitude),
        );
        distanceKm = routeData.distanceKm;
        polyline = routeData.polylinePoints
            .map((p) => [p.latitude, p.longitude])
            .toList();
      } else {
        distanceKm = 5.0; // Fallback estimate
        polyline = [];
      }

      // Calculate fare.
      final totalFare =
          fareCalc.calculateTotalFare(schedule.transportType, distanceKm);

      // Get poster profile info.
      final profileRepo = ProfileRepository(firestore: firestore);
      final profile = await profileRepo.getProfile(studentId);

      final ride = Ride(
        posterId: studentId,
        posterName: profile?.name ?? 'Unknown',
        posterUniversity: profile?.university ?? 'Unknown',
        posterGender: profile?.gender ?? 'other',
        posterPhotoUrl: profile?.photoUrl,
        originGeopoint: originGeo,
        originGeohash: schedule.originGeohash,
        originAddress: schedule.originAddress,
        destinationGeopoint: destGeo,
        destinationGeohash: schedule.destinationGeohash,
        destinationAddress: schedule.destinationAddress,
        transportType: schedule.transportType,
        rideHailingTag: schedule.rideHailingTag,
        departureTime: departureToday,
        totalSeats: schedule.totalSeats,
        routeDistanceKm: distanceKm,
        estimatedFare: totalFare,
        routePolyline: polyline,
      );

      await rideRepo.createRide(ride);
      await scheduleRepo.markPosted(schedule.id!, todayStr);
    } on Exception catch (_) {
      // Non-fatal: skip this schedule and continue.
    }
  }
}
