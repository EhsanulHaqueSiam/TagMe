import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/utils/location_utils.dart';
import 'package:tagme/features/profile/data/models/student.dart';

/// Circular avatar marker rendered on the map for a nearby student.
///
/// Displays a 48px circle with a 3px university-colored border, 2px white
/// outer ring for contrast, and a drop shadow. Shows the student's photo
/// via cached network image, or a person icon placeholder.
class StudentMarker extends StatelessWidget {
  const StudentMarker({
    required this.student,
    required this.onTap,
    super.key,
  });

  final Student student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final universityColor = AppColors.getUniversityColor(student.university);

    return Semantics(
      label: 'Student ${student.name} from ${student.university}, '
          '${formatDistance(student.distanceKm ?? 0)}',
      child: Tooltip(
        message: student.name,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: universityColor, width: 3),
              ),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: student.photoUrl != null
                    ? CachedNetworkImageProvider(student.photoUrl!)
                    : null,
                child: student.photoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 24,
                        color: AppColors.onSurfaceDim,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
