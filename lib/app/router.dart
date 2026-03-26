import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// GoRouter configuration with 4 routes and redirect guard stubs.
///
/// Redirect guards use placeholder booleans for now -- actual providers
/// will be wired in Plan 02/03.
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/map',
    redirect: (context, state) {
      // TODO(plan-02): Wire hasLocationPermission provider
      // TODO(plan-03): Wire hasProfile provider
      return null;
    },
    routes: [
      GoRoute(
        path: '/permission',
        builder: (context, state) => const _PlaceholderScreen(
          name: 'Location Permission',
        ),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const _PlaceholderScreen(
          name: 'Profile Setup',
        ),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const _PlaceholderScreen(
          name: 'Map',
        ),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const _PlaceholderScreen(
          name: 'Profile Edit',
        ),
      ),
    ],
  );
}

/// Temporary placeholder screen used until actual screens are built.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text(
          name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
