import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_schedule.freezed.dart';
part 'recurring_schedule.g.dart';

/// A recurring ride schedule for automatic ride posting.
@freezed
abstract class RecurringSchedule with _$RecurringSchedule {
  const factory RecurringSchedule({
    required String studentId,
    required String originGeohash,
    required String originAddress,
    required String destinationGeohash,
    required String destinationAddress,
    required String transportType,
    required int totalSeats,
    required String departureTime, // "HH:mm" format
    required List<int> daysOfWeek, // 1=Mon..7=Sun (DateTime.weekday)
    String? id,
    @JsonKey(includeFromJson: false, includeToJson: false)
    GeoPoint? originGeopoint,
    @JsonKey(includeFromJson: false, includeToJson: false)
    GeoPoint? destinationGeopoint,
    String? rideHailingTag,
    String? lastPostedDate, // "yyyy-MM-dd" to prevent double-posting
    @Default(true) bool active,
    DateTime? createdAt,
  }) = _RecurringSchedule;

  factory RecurringSchedule.fromJson(Map<String, dynamic> json) =>
      _$RecurringScheduleFromJson(json);
}
