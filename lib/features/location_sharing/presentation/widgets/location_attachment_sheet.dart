import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Bottom sheet content for choosing location sharing mode.
///
/// Presents two options: "Share My Location" (static current GPS)
/// and "Share Live Location" (real-time tracking). Each option
/// triggers a callback; the caller shows this via [showModalBottomSheet].
class LocationAttachmentSheet extends StatelessWidget {
  const LocationAttachmentSheet({
    super.key,
    required this.onShareStatic,
    required this.onShareLive,
  });

  final VoidCallback onShareStatic;
  final VoidCallback onShareLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Share My Location option
          SizedBox(
            height: 56,
            child: InkWell(
              onTap: onShareStatic,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location,
                      size: 24,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Share My Location',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Share Live Location option
          SizedBox(
            height: 56,
            child: InkWell(
              onTap: onShareLive,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.share_location,
                      size: 24,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Share Live Location',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
