import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';

/// Settings screen with profile edit, legal links, and app info.
///
/// Accessible from the map top bar gear icon. Navigates to profile edit
/// and legal document screens. Displays app version and map tile attribution.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // --- Profile section ---
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: AppColors.accent,
            ),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your name, photo, and university'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile-edit'),
          ),

          const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),

          // --- Rides section ---
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              'Rides',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.receipt_long_outlined,
              color: AppColors.accent,
            ),
            title: const Text('Fare History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/fares'),
          ),

          ListTile(
            leading: Icon(
              Icons.schedule_outlined,
              color: AppColors.accent,
            ),
            title: const Text('Recurring Schedule'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/rides/schedule'),
          ),

          const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),

          // --- Legal section ---
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              'Legal',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.accent,
            ),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/legal/privacy'),
          ),

          ListTile(
            leading: Icon(
              Icons.description_outlined,
              color: AppColors.accent,
            ),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/legal/terms'),
          ),

          const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),

          // --- About section ---
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              'About',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: AppColors.accent,
            ),
            title: const Text('About TagMe'),
            subtitle: const Text('Version 1.0.0'),
          ),

          ListTile(
            leading: Icon(
              Icons.map_outlined,
              color: AppColors.accent,
            ),
            title: const Text('Map Tiles'),
            subtitle: const Text('Powered by Stadia Maps & OpenStreetMap'),
          ),
        ],
      ),
    );
  }
}
