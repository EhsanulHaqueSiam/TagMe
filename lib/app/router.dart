import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/app/shell_screen.dart';
import 'package:tagme/features/map/presentation/screens/map_screen.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/permission/presentation/screens/location_permission_screen.dart';
import 'package:tagme/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:tagme/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';

part 'router.g.dart';

/// GoRouter configuration with redirect guards for permission and profile.
///
/// Phase 2: Uses [StatefulShellRoute.indexedStack] for Map and Rides tabs
/// with bottom navigation. Full-screen routes (post ride, ride detail, etc.)
/// live outside the shell and don't show the bottom nav.
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
      // Pre-auth routes (no bottom nav).
      GoRoute(
        path: '/permission',
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),

      // Bottom navigation shell with Map and Rides tabs.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rides',
                builder: (context, state) => const _RidesPlaceholder(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen Phase 2 routes (no bottom nav).
      GoRoute(
        path: '/rides/post',
        builder: (context, state) => const _PostRidePlaceholder(),
      ),
      GoRoute(
        path: '/rides/post/pick-location',
        builder: (context, state) => const _MapPinPickerPlaceholder(),
      ),
      GoRoute(
        path: '/rides/:rideId',
        builder: (context, state) => _RideDetailPlaceholder(
          rideId: state.pathParameters['rideId']!,
        ),
      ),
      GoRoute(
        path: '/rides/:rideId/requests',
        builder: (context, state) => _JoinRequestsPlaceholder(
          rideId: state.pathParameters['rideId']!,
        ),
      ),
      GoRoute(
        path: '/rides/search',
        builder: (context, state) => const _RideSearchPlaceholder(),
      ),
      GoRoute(
        path: '/rides/schedule',
        builder: (context, state) => const _RecurringSchedulePlaceholder(),
      ),
      GoRoute(
        path: '/fares',
        builder: (context, state) => const _FareHistoryPlaceholder(),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Placeholder screens — replaced by real screens in Plans 02-05.
// ---------------------------------------------------------------------------

class _RidesPlaceholder extends StatelessWidget {
  const _RidesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Rides - Coming Soon')),
    );
  }
}

class _PostRidePlaceholder extends StatelessWidget {
  const _PostRidePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Post Ride - Coming Soon')),
    );
  }
}

class _MapPinPickerPlaceholder extends StatelessWidget {
  const _MapPinPickerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Pick Location - Coming Soon')),
    );
  }
}

class _RideDetailPlaceholder extends StatelessWidget {
  const _RideDetailPlaceholder({required this.rideId});
  final String rideId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Ride Detail $rideId - Coming Soon')),
    );
  }
}

class _JoinRequestsPlaceholder extends StatelessWidget {
  const _JoinRequestsPlaceholder({required this.rideId});
  final String rideId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Join Requests $rideId - Coming Soon')),
    );
  }
}

class _RideSearchPlaceholder extends StatelessWidget {
  const _RideSearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Ride Search - Coming Soon')),
    );
  }
}

class _RecurringSchedulePlaceholder extends StatelessWidget {
  const _RecurringSchedulePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Recurring Schedule - Coming Soon')),
    );
  }
}

class _FareHistoryPlaceholder extends StatelessWidget {
  const _FareHistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Fare History - Coming Soon')),
    );
  }
}
