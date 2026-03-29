import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/features/map/providers/location_provider.dart';

/// Explain-then-ask screen shown before the system location permission dialog.
///
/// Presents the value proposition ("See Students Near You") and offers
/// "Enable Location" CTA or "Not Now" skip option. Handles the permanently
/// denied state by showing "Open Settings" instead.
class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends ConsumerState<LocationPermissionScreen> {
  bool _isPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermanentlyDenied();
  }

  Future<void> _checkPermanentlyDenied() async {
    final status = await Permission.locationWhenInUse.status;
    if (mounted) {
      setState(() {
        _isPermanentlyDenied = status.isPermanentlyDenied;
      });
    }
  }

  Future<void> _handleEnableLocation() async {
    if (_isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    final status = await Permission.locationWhenInUse.request();

    if (status.isPermanentlyDenied && mounted) {
      setState(() {
        _isPermanentlyDenied = true;
      });
      return;
    }

    if (status.isGranted) {
      ref.invalidate(locationPermissionProvider);
      if (mounted) context.go('/profile-setup');
    }
  }

  void _handleNotNow() {
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Map pin illustration area (200x200)
                const SizedBox(
                  width: 200,
                  height: 200,
                  child: Icon(
                    Icons.location_on,
                    size: 120,
                    color: AppColors.accent,
                  ),
                ),

                const SizedBox(height: 32),

                // Heading
                Text(
                  'See Students Near You',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Body text
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    'TagMe shows nearby students heading the same way. '
                    'We need your location to find ride partners around you.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Permanently denied message
                if (_isPermanentlyDenied) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      'Location permission was denied. '
                      'Open Settings to enable it.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.destructive,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // Primary CTA
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleEnableLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isPermanentlyDenied
                          ? 'Open Settings'
                          : 'Enable Location',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Not Now option
                TextButton(
                  onPressed: _handleNotNow,
                  child: Text(
                    'Not Now',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
