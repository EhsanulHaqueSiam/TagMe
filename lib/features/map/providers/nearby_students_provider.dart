import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagme/core/utils/location_utils.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/profile/data/models/student.dart';

part 'nearby_students_provider.g.dart';

/// Streams nearby students from Firestore within the configured search radius.
///
/// Uses geoflutterfire_plus geo queries to subscribe to documents within a
/// geographic radius around the user's current location. Results are sorted
/// by distance (ascending) on the client side since geoflutterfire_plus does
/// not support server-side orderBy.
@riverpod
Stream<List<Student>> nearbyStudents(Ref ref) {
  final location = ref.watch(currentLocationProvider).value;
  if (location == null) return Stream.value([]);

  final radiusKm = ref.watch(searchRadiusProvider);
  final center = GeoFirePoint(
    GeoPoint(location.latitude, location.longitude),
  );

  return GeoCollectionReference<Map<String, dynamic>>(
    FirebaseFirestore.instance.collection('students'),
  )
      .subscribeWithin(
        center: center,
        radiusInKm: radiusKm,
        field: 'location',
        geopointFrom: (data) =>
            (data['location'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
      )
      .asyncMap((snapshots) async {
    // Read local profile ID to filter out the user's own profile.
    final prefs = await SharedPreferences.getInstance();
    final localProfileId = prefs.getString('local_profile_id');

    final students = <Student>[];
    for (final doc in snapshots) {
      final data = doc.data();
      if (data == null) continue;

      // Skip the user's own profile.
      if (localProfileId != null && doc.id == localProfileId) continue;

      // Build student from JSON, injecting the document ID.
      data['id'] = doc.id;
      var student = Student.fromJson(data);

      // Extract geopoint from the location field.
      final locationData = data['location'] as Map<String, dynamic>?;
      if (locationData != null) {
        final geopoint = locationData['geopoint'] as GeoPoint?;
        if (geopoint != null) {
          final distance = calculateDistanceKm(
            location.latitude,
            location.longitude,
            geopoint.latitude,
            geopoint.longitude,
          );
          student = student.copyWith(
            geopoint: geopoint,
            distanceKm: distance,
          );
        }
      }

      students.add(student);
    }

    // Sort by distance ascending (client-side, geoflutterfire_plus limitation).
    students.sort((a, b) {
      final da = a.distanceKm ?? double.infinity;
      final db = b.distanceKm ?? double.infinity;
      return da.compareTo(db);
    });

    return students;
  });
}
