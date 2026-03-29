import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/features/chat/providers/chat_providers.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';

/// Bottom navigation shell wrapping Map, Rides, and Chat tabs.
///
/// Uses [StatefulNavigationShell] from GoRouter to preserve tab state
/// across switches (indexedStack pattern). Chat tab shows unread badge.
class ShellScreen extends ConsumerWidget {
  const ShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final currentUserId = profileAsync.value?.id ?? '';
    final unreadCount = currentUserId.isNotEmpty
        ? ref.watch(totalUnreadCountProvider(currentUserId))
        : 0;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: cs.surfaceContainerHighest),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          backgroundColor: cs.surface,
          indicatorColor: AppColors.accent.withValues(alpha: 0.12),
          height: 56,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Map',
            ),
            const NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car),
              label: 'Rides',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount'),
                backgroundColor: AppColors.destructive,
                child: const Icon(Icons.chat_bubble_outline),
              ),
              selectedIcon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount'),
                backgroundColor: AppColors.destructive,
                child: const Icon(Icons.chat_bubble),
              ),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}
