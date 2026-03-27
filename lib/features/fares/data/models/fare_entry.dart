import 'package:freezed_annotation/freezed_annotation.dart';

part 'fare_entry.freezed.dart';
part 'fare_entry.g.dart';

/// A fare ledger entry tracking who owes whom for a shared ride.
@freezed
abstract class FareEntry with _$FareEntry {
  const factory FareEntry({
    required String rideId,
    required String fromStudentId, // who owes
    required String toStudentId, // who is owed
    required int amount, // BDT, always positive
    required String routeDescription, // e.g. "Uttara -> AIUB"
    required String transportType,
    required DateTime rideDate,
    String? id,
    @Default(false) bool settled,
    DateTime? createdAt,
  }) = _FareEntry;

  factory FareEntry.fromJson(Map<String, dynamic> json) =>
      _$FareEntryFromJson(json);
}
