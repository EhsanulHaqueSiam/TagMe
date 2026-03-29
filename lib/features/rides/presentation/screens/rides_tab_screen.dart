import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/features/rides/data/models/ride.dart';
import 'package:tagme/features/rides/presentation/widgets/ride_card.dart';
import 'package:tagme/features/rides/providers/search_providers.dart';

/// Main rides view with Nearby and My Rides tabs.
///
/// Displays a tab bar with two tabs, a search action in the app bar,
/// and an extended "Post Ride" FAB. Accessible from bottom navigation.
class RidesTabScreen extends ConsumerStatefulWidget {
  const RidesTabScreen({super.key});

  @override
  ConsumerState<RidesTabScreen> createState() => _RidesTabScreenState();
}

class _RidesTabScreenState extends ConsumerState<RidesTabScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Rides',
          style: theme.textTheme.titleLarge,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/rides/search'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: cs.onSurfaceVariant,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Nearby'),
            Tab(text: 'My Rides'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NearbyTab(),
          _MyRidesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/rides/post'),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Post Ride',
          style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}

/// Nearby rides tab content with pull-to-refresh.
class _NearbyTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(nearbyRidesProvider);

    return ridesAsync.when(
      loading: () => const _ShimmerList(),
      error: (error, _) => _ErrorBanner(
        message: 'Could not load rides. Pull down to refresh.',
        onRetry: () => ref.invalidate(nearbyRidesProvider),
      ),
      data: (rides) {
        if (rides.isEmpty) {
          return const _EmptyState(
            heading: 'No Rides Nearby',
            body: 'No one is heading your way right now. '
                'Post a ride and let others find you.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(nearbyRidesProvider);
            // Wait a brief moment for the stream to re-emit.
            await Future<void>.delayed(
              const Duration(milliseconds: 500),
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.md,
                ),
                child: RideCard(
                  ride: ride,
                  onTap: () => context.push(
                    '/rides/${ride.id}',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// My Rides tab content with date-grouped sections.
class _MyRidesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ridesAsync = ref.watch(myRidesProvider);

    return ridesAsync.when(
      loading: () => const _ShimmerList(),
      error: (error, _) => _ErrorBanner(
        message: 'Could not load rides. Pull down to refresh.',
        onRetry: () => ref.invalidate(myRidesProvider),
      ),
      data: (rides) {
        if (rides.isEmpty) {
          return const _EmptyState(
            heading: 'No Rides Yet',
            body: 'Post your first ride or join someone '
                "else's. Tap the + button to get started.",
          );
        }

        final grouped = _groupByDate(rides);
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myRidesProvider);
            await Future<void>.delayed(
              const Duration(milliseconds: 500),
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final entry = grouped[index];
              if (entry is String) {
                return Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    entry,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                );
              }
              final ride = entry as Ride;
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.md,
                ),
                child: RideCard(
                  ride: ride,
                  isOwnRide: true,
                  onTap: () => context.push(
                    '/rides/${ride.id}',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Groups rides by date, inserting string section headers.
  ///
  /// Returns a mixed list of [String] headers and [Ride] items.
  List<Object> _groupByDate(List<Ride> rides) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final items = <Object>[];
    String? lastHeader;

    for (final ride in rides) {
      final rideDay = DateTime(
        ride.departureTime.year,
        ride.departureTime.month,
        ride.departureTime.day,
      );

      String header;
      if (rideDay == today) {
        header = 'Today';
      } else if (rideDay == tomorrow) {
        header = 'Tomorrow';
      } else {
        header = DateFormat('EEE, MMM d').format(
          ride.departureTime,
        );
      }

      if (header != lastHeader) {
        items.add(header);
        lastHeader = header;
      }
      items.add(ride);
    }

    return items;
  }
}

/// 3 shimmer skeleton cards for loading state.
class _ShimmerList extends StatefulWidget {
  const _ShimmerList();

  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.md,
            ),
            child: FadeTransition(
              opacity: _animation,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Centered empty state with heading and body text.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              heading,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline error banner with retry action.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
