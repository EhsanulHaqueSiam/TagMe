import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/core/utils/location_utils.dart';
import 'package:tagme/features/profile/data/models/student.dart';

/// Bottom sheet displaying a nearby student's profile information.
///
/// Shown via [showModalBottomSheet] when a student marker is tapped
/// on the map. Displays photo, name, university, distance, transport
/// type, route, and gender.
class StudentBottomSheet extends StatelessWidget {
  const StudentBottomSheet({required this.student, super.key});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Student profile',
      child: DraggableScrollableSheet(
        initialChildSize: 0.35,
        // Explicit per UI spec: 25% minimum sheet height.
        // ignore: avoid_redundant_argument_values
        minChildSize: 0.25,
        maxChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                // Drag handle
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Header row: avatar + name/university/distance
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      // 64px avatar with university-colored border
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.getUniversityColor(
                              student.university,
                            ),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.surfaceVariant,
                          backgroundImage: student.photoUrl != null
                              ? CachedNetworkImageProvider(student.photoUrl!)
                              : null,
                          child: student.photoUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: AppColors.onSurfaceDim,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name, university, distance
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              student.university,
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.onSurfaceDim,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatDistance(student.distanceKm ?? 0),
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Info chips row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Transport type chip
                        _InfoChip(
                          icon: _getTransportIcon(student.transportType),
                          label: student.transportType ?? 'Unknown',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Route chip
                        if (student.routeOrigin != null ||
                            student.routeDestination != null)
                          _InfoChip(
                            icon: Icons.route,
                            label:
                                '${student.routeOrigin ?? '?'} -> '
                                '${student.routeDestination ?? '?'}',
                          ),
                        const SizedBox(width: AppSpacing.sm),
                        // Gender chip
                        _InfoChip(
                          icon: Icons.person,
                          label: student.gender,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Route visualization
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${student.routeOrigin ?? 'Not set'}',
                        style: textTheme.bodyLarge,
                      ),
                      // Vertical connecting line
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent,
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 24,
                                  color: AppColors.accent,
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'To: ${student.routeDestination ?? 'Not set'}',
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Maps transport type strings to Material Icons.
  static IconData _getTransportIcon(String? transportType) {
    return switch (transportType) {
      'rickshaw' => Icons.pedal_bike,
      'bike' => Icons.two_wheeler,
      'bus' => Icons.directions_bus,
      'car' => Icons.directions_car,
      'CNG' => Icons.local_taxi,
      _ => Icons.commute,
    };
  }
}

/// Small chip displaying an icon and label for student info.
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
