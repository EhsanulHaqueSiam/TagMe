import 'package:freezed_annotation/freezed_annotation.dart';

part 'join_request.freezed.dart';
part 'join_request.g.dart';

/// A request from a student to join an existing ride.
@freezed
abstract class JoinRequest with _$JoinRequest {
  const factory JoinRequest({
    required String rideId,
    required String requesterId,
    required String requesterName,
    required String requesterUniversity,
    required String requesterGender,
    String? id,
    String? requesterPhotoUrl,
    @Default('pending') String status, // pending, accepted, declined
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _JoinRequest;

  factory JoinRequest.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestFromJson(json);
}
