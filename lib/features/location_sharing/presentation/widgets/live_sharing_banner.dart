import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Blue banner showing active live location sharing status.
///
/// Displays a pulsing green dot, "Sharing live location" text,
/// countdown timer (MM:SS), and a "Stop" button with confirmation dialog.
/// Placed below the app bar / ride context header in ChatScreen.
class LiveSharingBanner extends StatefulWidget {
  const LiveSharingBanner({
    super.key,
    required this.remainingDuration,
    required this.onStop,
  });

  /// Time remaining before auto-expiry (max 30 minutes).
  final Duration remainingDuration;

  /// Callback to stop live sharing. Called after user confirms.
  final VoidCallback onStop;

  @override
  State<LiveSharingBanner> createState() => _LiveSharingBannerState();
}

class _LiveSharingBannerState extends State<LiveSharingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = widget.remainingDuration;
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFFE8F0FE),
      child: Row(
        children: [
          // Pulsing green dot
          FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sharing live location',
                  style: theme.textTheme.labelLarge,
                ),
                Text(
                  'Stops in $minutes:$seconds',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceDim,
                  ),
                ),
              ],
            ),
          ),

          // Stop button
          TextButton(
            onPressed: () => _showStopConfirmation(context),
            child: Text(
              'Stop',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.destructive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStopConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Stop sharing your live location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep Sharing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onStop();
            },
            child: Text(
              'Stop Sharing',
              style: TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }
}
