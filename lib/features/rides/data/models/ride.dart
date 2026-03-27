import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride.freezed.dart';
part 'ride.g.dart';

/// A ride post created by a student looking for ride-sharing partners.
@freezed
abstract class Ride with _$Ride {
  const factory Ride({
    required String posterId,
    required String posterName,
    required String posterUniversity,
    required String posterGender,
    required String originGeohash,
    required String originAddress,
    required String destinationGeohash,
    required String destinationAddress,
    required String transportType,
    required DateTime departureTime,
    required int totalSeats,
    required double routeDistanceKm,
    required int estimatedFare, // total fare in BDT
    String? id,
    String? posterPhotoUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    GeoPoint? originGeopoint,
    @JsonKey(includeFromJson: false, includeToJson: false)
    GeoPoint? destinationGeopoint,
    String? rideHailingTag,
    @Default(0) int filledSeats,
    @Default('active') String status, // active, full, completed, cancelled
    @Default([]) List<List<double>> routePolyline, // [[lat, lng], ...]
    DateTime? createdAt,
  }) = _Ride;

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);
}
