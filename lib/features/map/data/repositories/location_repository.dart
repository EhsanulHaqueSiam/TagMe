import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_repository.g.dart';

/// Wraps Geolocator for GPS and Firestore for location persistence.
@riverpod
LocationRepository locationRepository(Ref ref) => LocationRepository();

class LocationRepository {
  /// Returns the device's current GPS position.
  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Streams GPS position updates in foreground only.
  ///
  /// Uses a 50-meter distance filter to prevent excessive updates (MAP-04).
  /// No background service -- stream pauses when app is backgrounded.
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    );
  }

  /// Writes the student's current location to Firestore as a GeoFirePoint.
  ///
  /// The `location` field contains both the GeoPoint and geohash data
  /// needed for radius-based geo queries via geoflutterfire_plus.
  Future<void> updateLocationInFirestore(
    String studentId,
    double lat,
    double lng,
  ) async {
    final geoFirePoint = GeoFirePoint(GeoPoint(lat, lng));
    await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .update({'location': geoFirePoint.data});
  }
}
