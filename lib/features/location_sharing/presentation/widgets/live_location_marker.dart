import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Animated pulsing marker for live GPS position on an embedded map.
///
/// Shows a 40px container with a pulsing outer ring and 12px solid inner dot.
/// When [isStale] is true (location >60s old), the pulse stops and the marker
/// dims to the theme's `onSurfaceVariant` color. Respects reduced motion preferences.
class LiveLocationMarker extends StatefulWidget {
  const LiveLocationMarker({
    super.key,
    required this.accuracy,
    this.isStale = false,
    this.userName,
  });

  /// GPS accuracy in meters (for potential accuracy circle rendering).
  final double accuracy;

  /// Whether the location data is stale (>60s since last update).
  /// When true, pulse stops and marker dims.
  final bool isStale;

  /// Optional user name for screen reader accessibility label.
  final String? userName;

  @override
  State<LiveLocationMarker> createState() => _LiveLocationMarkerState();
}

class _LiveLocationMarkerState extends State<LiveLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (!widget.isStale) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiveLocationMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStale && !oldWidget.isStale) {
      _controller.stop();
      _controller.reset();
    } else if (!widget.isStale && oldWidget.isStale) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isStale ? Theme.of(context).colorScheme.onSurfaceVariant : AppColors.accent;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final semanticLabel = widget.userName != null
        ? "${widget.userName}'s live location"
        : 'Live location';

    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              if (!widget.isStale && !disableAnimations)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
              // Inner solid dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
