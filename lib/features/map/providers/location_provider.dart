import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/map/data/repositories/location_repository.dart';

part 'location_provider.g.dart';

/// Streams the device's GPS position with 50m distance filter.
///
/// Auto-disposes when no listeners remain (default @riverpod behavior).
/// Only fires in foreground -- no background location service.
@riverpod
Stream<Position> currentLocation(Ref ref) {
  return ref.watch(locationRepositoryProvider).getPositionStream();
}

/// Checks the current location permission status.
@riverpod
Future<PermissionStatus> locationPermission(Ref ref) {
  return Permission.locationWhenInUse.status;
}

/// Derived boolean: true when location permission is granted.
@riverpod
bool hasLocationPermission(Ref ref) {
  final status = ref.watch(locationPermissionProvider).value;
  return status?.isGranted ?? false;
}

/// Search radius in kilometers. Defaults to 5km per CONTEXT.md.
///
/// Adjustable by user (future UI control in Phase 2+).
@riverpod
class SearchRadius extends _$SearchRadius {
  @override
  // Plan requires 5.0 (double literal) for explicit typing.
  // ignore: prefer_int_literals
  double build() => 5.0;

  // Method form preferred for Riverpod notifier API consistency.
  // ignore: use_setters_to_change_properties
  void update(double radius) {
    state = radius;
  }
}
