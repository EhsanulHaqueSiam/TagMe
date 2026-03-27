import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';

/// Transparent overlay bar at the top of the map screen.
///
/// Shows the user's profile avatar (tap to edit), "TagMe" title in the center,
/// and an empty spacer on the right (settings icon reserved for future phases).
class MapTopBar extends ConsumerWidget {
  const MapTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final student = profileAsync.value;
    final photoUrl = student?.photoUrl;

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: user avatar
            GestureDetector(
              onTap: () => context.push('/profile-edit'),
              child: Semantics(
                label: 'Edit your profile',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: photoUrl != null
                      ? CachedNetworkImageProvider(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 24,
                          color: AppColors.onSurfaceDim,
                        )
                      : null,
                ),
              ),
            ),

            // Center: TagMe title
            Expanded(
              child: Text(
                'TagMe',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
              ),
            ),

            // Right: settings gear icon
            GestureDetector(
              onTap: () => context.push('/settings'),
              child: Semantics(
                label: 'Open settings',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
