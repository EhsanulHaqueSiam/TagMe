import 'package:flutter/material.dart';

/// Transport types available for ride-sharing in Bangladesh.
///
/// Each type carries metadata for UI display and fare calculation.
enum TransportType {
  rickshaw(
    label: 'Rickshaw',
    icon: Icons.electric_rickshaw,
    maxCapacity: 2,
    farePerKm: 15,
  ),
  bike(
    label: 'Bike',
    icon: Icons.pedal_bike,
    maxCapacity: 1,
    farePerKm: 10,
  ),
  bus(
    label: 'Bus',
    icon: Icons.directions_bus,
    maxCapacity: 10,
    farePerKm: 5,
  ),
  car(
    label: 'Car',
    icon: Icons.directions_car,
    maxCapacity: 3,
    farePerKm: 18,
  ),
  cng(
    label: 'CNG',
    icon: Icons.local_taxi,
    maxCapacity: 2,
    farePerKm: 12,
  );

  const TransportType({
    required this.label,
    required this.icon,
    required this.maxCapacity,
    required this.farePerKm,
  });

  /// Human-readable display name.
  final String label;

  /// Material icon for UI display.
  final IconData icon;

  /// Maximum number of riders (excluding poster).
  final int maxCapacity;

  /// Fare rate in BDT per kilometer.
  final int farePerKm;

  /// Looks up a [TransportType] by its [name] string.
  ///
  /// Returns matching enum value, or throws [ArgumentError] if not found.
  static TransportType fromString(String value) {
    return TransportType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => throw ArgumentError('Unknown transport type: $value'),
    );
  }
}
