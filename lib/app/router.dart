import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/app/shell_screen.dart';
import 'package:tagme/features/map/presentation/screens/map_screen.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/permission/presentation/screens/location_permission_screen.dart';
import 'package:tagme/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:tagme/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';
import 'package:tagme/features/rides/presentation/screens/map_pin_picker_screen.dart';
import 'package:tagme/features/rides/presentation/screens/post_ride_screen.dart';
import 'package:tagme/features/rides/presentation/screens/ride_search_screen.dart';
import 'package:tagme/features/fares/presentation/screens/fare_history_screen.dart';
import 'package:tagme/features/rides/presentation/screens/join_requests_screen.dart';
import 'package:tagme/features/rides/presentation/screens/recurring_schedule_screen.dart';
import 'package:tagme/features/rides/presentation/screens/ride_detail_screen.dart';
import 'package:tagme/features/rides/presentation/screens/rides_tab_screen.dart';

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
                builder: (context, state) => const RidesTabScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen Phase 2 routes (no bottom nav).
      GoRoute(
        path: '/rides/post',
        builder: (context, state) => const PostRideScreen(),
      ),
      GoRoute(
        path: '/rides/post/pick-location',
        builder: (context, state) => MapPinPickerScreen(
          mode: state.uri.queryParameters['mode'] ?? 'origin',
        ),
      ),
      GoRoute(
        path: '/rides/:rideId',
        builder: (context, state) => RideDetailScreen(
          rideId: state.pathParameters['rideId']!,
        ),
      ),
      GoRoute(
        path: '/rides/:rideId/requests',
        builder: (context, state) => JoinRequestsScreen(
          rideId: state.pathParameters['rideId']!,
        ),
      ),
      GoRoute(
        path: '/rides/search',
        builder: (context, state) => const RideSearchScreen(),
      ),
      GoRoute(
        path: '/rides/schedule',
        builder: (context, state) => const RecurringScheduleScreen(),
      ),
      GoRoute(
        path: '/fares',
        builder: (context, state) => const FareHistoryScreen(),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// All Phase 2 placeholders replaced by real screens:
// - _RidesPlaceholder -> RidesTabScreen (Plan 02-03)
// - _PostRidePlaceholder -> PostRideScreen (Plan 02-02)
// - _MapPinPickerPlaceholder -> MapPinPickerScreen (Plan 02-02)
// - _RideDetailPlaceholder -> RideDetailScreen (Plan 02-04)
// - _JoinRequestsPlaceholder -> JoinRequestsScreen (Plan 02-04)
// - _RideSearchPlaceholder -> RideSearchScreen (Plan 02-03)
// - _RecurringSchedulePlaceholder -> RecurringScheduleScreen (Plan 02-05)
// - _FareHistoryPlaceholder -> FareHistoryScreen (Plan 02-05)
// ---------------------------------------------------------------------------
