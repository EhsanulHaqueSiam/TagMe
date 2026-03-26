import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/map/presentation/screens/map_screen.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/permission/presentation/screens/location_permission_screen.dart';
import 'package:tagme/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:tagme/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';

part 'router.g.dart';

/// GoRouter configuration with redirect guards for permission and profile.
@riverpod
GoRouter router(Ref ref) {
  final hasPermission = ref.watch(hasLocationPermissionProvider);
  final hasProfileAsync = ref.watch(hasProfileProvider);
  final profileExists = hasProfileAsync.value ?? false;

  return GoRouter(
    initialLocation: '/map',
    redirect: (context, state) {
      final currentPath = state.uri.path;

      // Redirect to permission screen if location not granted
      if (!hasPermission && currentPath != '/permission') {
        return '/permission';
      }

      // If permission granted but on permission screen, move on
      if (hasPermission && currentPath == '/permission') {
        return profileExists ? '/map' : '/profile-setup';
      }

      // If no profile and not on profile-setup, redirect
      if (!profileExists &&
          hasPermission &&
          currentPath != '/profile-setup') {
        return '/profile-setup';
      }

      // If profile exists and on profile-setup, go to map
      if (profileExists && currentPath == '/profile-setup') {
        return '/map';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/permission',
        builder: (context, state) =>
            const LocationPermissionScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
    ],
  );
}
