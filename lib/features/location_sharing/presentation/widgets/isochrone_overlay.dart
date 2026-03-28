import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Transport mode options for isochrone generation.
class IsochroneTransportMode {
  const IsochroneTransportMode({
    required this.profile,
    required this.icon,
    required this.label,
  });

  final String profile;
  final IconData icon;
  final String label;

  static const List<IsochroneTransportMode> all = [
    IsochroneTransportMode(
      profile: 'driving-car',
      icon: Icons.directions_car,
      label: 'Car',
    ),
    IsochroneTransportMode(
      profile: 'cycling-road',
      icon: Icons.pedal_bike,
      label: 'Bicycle',
    ),
    IsochroneTransportMode(
      profile: 'foot-walking',
      icon: Icons.directions_walk,
      label: 'Walking',
    ),
  ];
}

/// Overlay control bar for isochrone display.
///
/// Renders transport mode selector icons and a "Done" button to dismiss
/// the isochrone overlay. Does NOT render the PolygonLayer itself --
/// that is handled directly in MapScreen's FlutterMap children.
class IsochroneOverlay extends StatelessWidget {
  const IsochroneOverlay({
    super.key,
    required this.selectedProfile,
    required this.onProfileChanged,
    required this.onDismiss,
  });

  final String selectedProfile;
  final ValueChanged<String> onProfileChanged;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Transport mode icons
          ...IsochroneTransportMode.all.map((mode) {
            final isSelected = selectedProfile == mode.profile;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Tooltip(
                message: mode.label,
                child: InkWell(
                  onTap: () => onProfileChanged(mode.profile),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      mode.icon,
                      size: 20,
                      color: isSelected ? Colors.white : AppColors.onSurfaceDim,
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(width: 8),

          // Done button
          TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
