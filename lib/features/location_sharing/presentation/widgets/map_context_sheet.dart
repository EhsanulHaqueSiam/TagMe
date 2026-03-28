import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Bottom sheet shown when user long-presses on the map.
///
/// Provides three actions: Open in Google Maps, Share This Location,
/// and Show Reachability (isochrone overlay, implemented in Plan 06).
class MapContextSheet extends StatelessWidget {
  const MapContextSheet({
    super.key,
    required this.onOpenInMaps,
    required this.onShare,
    required this.onShowReachability,
  });

  final VoidCallback onOpenInMaps;
  final VoidCallback onShare;
  final VoidCallback onShowReachability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Open in Google Maps
          _ActionRow(
            icon: Icons.map,
            label: 'Open in Google Maps',
            onTap: onOpenInMaps,
            theme: theme,
          ),

          // Share This Location
          _ActionRow(
            icon: Icons.share,
            label: 'Share This Location',
            onTap: onShare,
            theme: theme,
          ),

          // Show Reachability
          _ActionRow(
            icon: Icons.radar,
            label: 'Show Reachability',
            onTap: onShowReachability,
            theme: theme,
          ),

          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: AppColors.accent),
              const SizedBox(width: 16),
              Text(label, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
