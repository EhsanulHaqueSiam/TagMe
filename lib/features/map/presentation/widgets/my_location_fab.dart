import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Floating action button that re-centers the map on the user's location.
///
/// White background with accent-colored crosshair icon. The parent provides
/// the [onPressed] callback that handles the map controller animation.
class MyLocationFab extends ConsumerWidget {
  const MyLocationFab({required this.onPressed, super.key});

  /// Called when the FAB is tapped. Parent should animate the map
  /// to the user's current location.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.white,
        elevation: 4,
        child: Semantics(
          label: 'Center map on my location',
          child: const Icon(
            Icons.my_location,
            size: 24,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
