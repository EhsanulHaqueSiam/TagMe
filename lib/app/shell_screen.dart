import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Bottom navigation shell wrapping Map and Rides tabs.
///
/// Uses [StatefulNavigationShell] from GoRouter to preserve tab state
/// across switches (indexedStack pattern).
class ShellScreen extends StatelessWidget {
  const ShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceVariant),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          backgroundColor: AppColors.secondary,
          indicatorColor: AppColors.accent.withValues(alpha: 0.12),
          height: 56,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car),
              label: 'Rides',
            ),
          ],
        ),
      ),
    );
  }
}
