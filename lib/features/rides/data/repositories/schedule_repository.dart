import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/rides/data/models/recurring_schedule.dart';

part 'schedule_repository.g.dart';

/// Repository handling Firestore CRUD for recurring ride schedules.
@riverpod
ScheduleRepository scheduleRepository(Ref ref) {
  return ScheduleRepository(firestore: FirebaseFirestore.instance);
}

class ScheduleRepository {
  ScheduleRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _schedulesCollection =>
      _firestore.collection('schedules');

  /// Creates a new schedule document. Returns the auto-generated doc ID.
  Future<String> createSchedule(RecurringSchedule schedule) async {
    final data = schedule.toJson();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();

    // Write origin as nested geo map.
    if (schedule.originGeopoint != null) {
      data['origin'] = {
        ...GeoFirePoint(schedule.originGeopoint!).data,
        'geohash': schedule.originGeohash,
        'address': schedule.originAddress,
      };
    } else {
      data['origin'] = {
        'geohash': schedule.originGeohash,
        'address': schedule.originAddress,
      };
    }

    // Write destination as nested geo map.
    if (schedule.destinationGeopoint != null) {
      data['destination'] = {
        ...GeoFirePoint(schedule.destinationGeopoint!).data,
        'geohash': schedule.destinationGeohash,
        'address': schedule.destinationAddress,
      };
    } else {
      data['destination'] = {
        'geohash': schedule.destinationGeohash,
        'address': schedule.destinationAddress,
      };
    }

    final docRef = await _schedulesCollection.add(data);
    return docRef.id;
  }

  /// Streams active schedules for [studentId].
  Stream<List<RecurringSchedule>> getSchedules(String studentId) {
    return _schedulesCollection
        .where('studentId', isEqualTo: studentId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(_scheduleFromDoc).toList(),
        );
  }

  /// Deletes a schedule document.
  Future<void> deleteSchedule(String id) async {
    await _schedulesCollection.doc(id).delete();
  }

  /// Marks a schedule as posted for the given date to prevent double-posting.
  Future<void> markPosted(String id, String dateStr) async {
    await _schedulesCollection.doc(id).update({'lastPostedDate': dateStr});
  }

  /// Gets active schedules for today's weekday for [studentId].
  Future<List<RecurringSchedule>> getActiveSchedulesForToday(
    String studentId,
  ) async {
    final today = DateTime.now().weekday; // 1=Mon..7=Sun
    final snapshot = await _schedulesCollection
        .where('studentId', isEqualTo: studentId)
        .where('active', isEqualTo: true)
        .where('daysOfWeek', arrayContains: today)
        .get();
    return snapshot.docs.map(_scheduleFromDoc).toList();
  }

  RecurringSchedule _scheduleFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    data['id'] = doc.id;

    // Extract origin GeoPoint from nested map.
    final originData = data['origin'] as Map<String, dynamic>?;
    GeoPoint? originGeopoint;
    if (originData != null) {
      originGeopoint = originData['geopoint'] as GeoPoint?;
      data['originGeohash'] = originData['geohash'] ?? data['originGeohash'];
      data['originAddress'] = originData['address'] ?? data['originAddress'];
    }

    // Extract destination GeoPoint from nested map.
    final destData = data['destination'] as Map<String, dynamic>?;
    GeoPoint? destinationGeopoint;
    if (destData != null) {
      destinationGeopoint = destData['geopoint'] as GeoPoint?;
      data['destinationGeohash'] =
          destData['geohash'] ?? data['destinationGeohash'];
      data['destinationAddress'] =
          destData['address'] ?? data['destinationAddress'];
    }

    // Convert Timestamps.
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }

    // Remove nested maps that Freezed doesn't know about.
    data.remove('origin');
    data.remove('destination');

    var schedule = RecurringSchedule.fromJson(data);
    schedule = schedule.copyWith(
      originGeopoint: originGeopoint,
      destinationGeopoint: destinationGeopoint,
    );
    return schedule;
  }
}
