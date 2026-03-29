import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/core/constants/transport_types.dart';
import 'package:tagme/core/utils/location_utils.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/rides/presentation/widgets/ride_card.dart';
import 'package:tagme/features/rides/providers/search_providers.dart';

/// Ride search screen with destination-based search, transport and
/// time filters, and matching results with gender-preference ranking.
class RideSearchScreen extends ConsumerStatefulWidget {
  const RideSearchScreen({super.key});

  @override
  ConsumerState<RideSearchScreen> createState() =>
      _RideSearchScreenState();
}

class _RideSearchScreenState extends ConsumerState<RideSearchScreen> {
  double? _destinationLat;
  double? _destinationLng;
  String? _destinationAddress;
  String? _selectedTransport;
  DateTime? _timeStart;
  DateTime? _timeEnd;

  GeoPoint? get _destinationGeoPoint {
    if (_destinationLat == null || _destinationLng == null) {
      return null;
    }
    return GeoPoint(_destinationLat!, _destinationLng!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Search Rides',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          // Search bar.
          _buildSearchBar(theme),

          // Filter row.
          _buildFilterRow(theme),

          // Results area.
          Expanded(child: _buildResults(theme)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: GestureDetector(
        onTap: _pickDestination,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _destinationAddress ?? 'Where are you going?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _destinationAddress != null
                        ? null
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_destinationAddress != null)
                GestureDetector(
                  onTap: _clearDestination,
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(ThemeData theme) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
        ),
        children: [
          // "All" transport filter.
          _buildFilterChip(
            theme: theme,
            label: 'All',
            isSelected: _selectedTransport == null,
            onTap: () => setState(() {
              _selectedTransport = null;
            }),
          ),

          // Individual transport type filters.
          for (final type in TransportType.values)
            _buildFilterChip(
              theme: theme,
              label: type.label,
              isSelected: _selectedTransport == type.name,
              onTap: () => setState(() {
                _selectedTransport = type.name;
              }),
            ),

          // Time filter.
          _buildFilterChip(
            theme: theme,
            label: _timeStart != null ? 'Time Set' : 'Anytime',
            isSelected: _timeStart != null,
            onTap: _showTimePicker,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? AppColors.accent
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          backgroundColor: isSelected
              ? Colors.transparent
              : theme.colorScheme.surfaceContainerHighest,
          side: isSelected
              ? const BorderSide(color: AppColors.accent)
              : BorderSide.none,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
          ),
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_destinationGeoPoint == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Set your destination to find rides',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final ridesAsync = ref.watch(
      searchRidesProvider(
        destination: _destinationGeoPoint,
        departureTime: _timeStart,
        transportType: _selectedTransport,
      ),
    );

    return ridesAsync.when(
      loading: () => const _SearchShimmerList(),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Could not load rides. Pull down to refresh.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (rides) {
        if (rides.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No rides found for this route. '
                    'Try a different time or post your own.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.push('/rides/post'),
                    child: const Text('Post a Ride'),
                  ),
                ],
              ),
            ),
          );
        }

        // Get user location for isMatch proximity check.
        final location =
            ref.watch(currentLocationProvider).value;

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            final ride = rides[index];

            // isMatch: origin within 500m of user.
            var isMatch = false;
            if (location != null &&
                ride.originGeopoint != null) {
              final dist = calculateDistanceKm(
                location.latitude,
                location.longitude,
                ride.originGeopoint!.latitude,
                ride.originGeopoint!.longitude,
              );
              isMatch = dist <= 0.5;
            }

            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.md,
              ),
              child: RideCard(
                ride: ride,
                isMatch: isMatch,
                onTap: () => context.push(
                  '/rides/${ride.id}',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickDestination() async {
    final result = await context.push<Map<String, dynamic>>(
      '/rides/post/pick-location?mode=destination',
    );

    if (result != null && mounted) {
      setState(() {
        _destinationLat = result['lat'] as double?;
        _destinationLng = result['lng'] as double?;
        _destinationAddress = result['address'] as String?;
      });
    }
  }

  void _clearDestination() {
    setState(() {
      _destinationLat = null;
      _destinationLng = null;
      _destinationAddress = null;
    });
  }

  Future<void> _showTimePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _TimeFilterSheet(
        initialStart: _timeStart,
        initialEnd: _timeEnd,
        onApply: (start, end) {
          setState(() {
            _timeStart = start;
            _timeEnd = end;
          });
          Navigator.of(ctx).pop();
        },
        onClear: () {
          setState(() {
            _timeStart = null;
            _timeEnd = null;
          });
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

/// Bottom sheet for selecting a time range filter.
class _TimeFilterSheet extends StatefulWidget {
  const _TimeFilterSheet({
    required this.onApply,
    required this.onClear,
    this.initialStart,
    this.initialEnd,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;
  final void Function(DateTime start, DateTime end) onApply;
  final VoidCallback onClear;

  @override
  State<_TimeFilterSheet> createState() => _TimeFilterSheetState();
}

class _TimeFilterSheetState extends State<_TimeFilterSheet> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStart != null
        ? TimeOfDay.fromDateTime(widget.initialStart!)
        : TimeOfDay.now();
    _endTime = widget.initialEnd != null
        ? TimeOfDay.fromDateTime(widget.initialEnd!)
        : TimeOfDay(
            hour: (TimeOfDay.now().hour + 2) % 24,
            minute: TimeOfDay.now().minute,
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Time',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _timeButton(
                  context,
                  label: 'From',
                  time: _startTime,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (picked != null) {
                      setState(() => _startTime = picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _timeButton(
                  context,
                  label: 'To',
                  time: _endTime,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (picked != null) {
                      setState(() => _endTime = picked);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              TextButton(
                onPressed: widget.onClear,
                child: const Text('Clear'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  final now = DateTime.now();
                  final start = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    _startTime.hour,
                    _startTime.minute,
                  );
                  final end = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    _endTime.hour,
                    _endTime.minute,
                  );
                  widget.onApply(start, end);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _timeButton(
    BuildContext context, {
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              time.format(context),
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// 3 shimmer skeleton cards for search loading state.
class _SearchShimmerList extends StatefulWidget {
  const _SearchShimmerList();

  @override
  State<_SearchShimmerList> createState() =>
      _SearchShimmerListState();
}

class _SearchShimmerListState extends State<_SearchShimmerList>
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
