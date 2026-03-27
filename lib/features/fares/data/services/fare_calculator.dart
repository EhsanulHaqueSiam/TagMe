import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/core/constants/transport_types.dart';

part 'fare_calculator.g.dart';

/// Computes ride fares based on transport type and distance.
@riverpod
FareCalculator fareCalculator(Ref ref) {
  return FareCalculator();
}

class FareCalculator {
  /// Default fare rate (BDT/km) when transport type is unknown.
  static const _defaultFarePerKm = 10;

  /// Calculates total fare in BDT for a given transport type and distance.
  int calculateTotalFare(String transportType, double distanceKm) {
    int farePerKm;
    try {
      farePerKm = TransportType.fromString(transportType).farePerKm;
    } catch (_) {
      farePerKm = _defaultFarePerKm;
    }
    return (farePerKm * distanceKm).round();
  }

  /// Calculates per-person fare split (rounds up).
  ///
  /// Returns [totalFare] if [riderCount] is <= 0.
  int calculatePerPersonFare(int totalFare, int riderCount) {
    if (riderCount <= 0) return totalFare;
    return (totalFare / riderCount).ceil();
  }
}
