import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';
part 'student.g.dart';

/// Student profile model matching the Firestore document schema.
@freezed
abstract class Student with _$Student {
  const factory Student({
    required String name,
    required String university,
    required String gender, // 'male', 'female', 'other'
    String? id,
    String? photoUrl,
    String? transportType, // 'rickshaw','bike','bus','car','CNG'
    String? routeOrigin,
    String? routeDestination,
    @JsonKey(includeFromJson: false, includeToJson: false) GeoPoint? geopoint,
    @JsonKey(includeFromJson: false, includeToJson: false)
    double? distanceKm, // calculated client-side, not stored
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
}
