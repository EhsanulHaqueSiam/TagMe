import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/core/constants/transport_types.dart';
import 'package:tagme/features/fares/data/services/fare_calculator.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';
import 'package:tagme/features/rides/data/models/ride.dart';
import 'package:tagme/features/rides/data/repositories/ride_repository.dart';
import 'package:tagme/features/rides/presentation/widgets/route_visualization.dart';
import 'package:tagme/features/rides/providers/ride_providers.dart';

/// Full ride detail view with poster info, route card, fare estimate,
/// and context-aware action button (join/pending/accepted/full/own).
class RideDetailScreen extends ConsumerStatefulWidget {
  const RideDetailScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends ConsumerState<RideDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _isSendingRequest = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideDetailProvider(widget.rideId));
    final theme = Theme.of(context);

    final profileAsync = ref.watch(profileProvider);
    final currentUserId = profileAsync.value?.id ?? '';

    // Determine if own ride for trailing menu
    final ride = rideAsync.value;
    final isOwnRide = ride != null && ride.posterId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isOwnRide)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'cancel') {
                  _showCancelConfirmation(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  enabled: false,
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'cancel',
                  child: Text(
                    'Cancel Ride',
                    style: TextStyle(color: AppColors.destructive),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: rideAsync.when(
        loading: () => _buildShimmer(theme),
        error: (error, _) => Center(
          child: Text(
            'Could not load ride details.',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        data: (rideData) {
          if (rideData == null) {
            return Center(
              child: Text(
                'Ride not found.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }
          return _buildContent(context, rideData, theme);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Ride ride, ThemeData theme) {
    final currentUserId = ref.watch(profileProvider).value?.id ?? '';
    final isOwnRide = ride.posterId == currentUserId;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Poster header
                _buildPosterHeader(ride, theme),
                const SizedBox(height: AppSpacing.md),

                // Section 2: Route card
                _buildRouteCard(ride, theme),
                const SizedBox(height: AppSpacing.md),

                // Section 3: Ride info row
                _buildInfoRow(ride, theme),
                const SizedBox(height: AppSpacing.md),

                // Section 4: Fare estimate card
                _buildFareCard(ride, theme),
              ],
            ),
          ),
        ),

        // Section 5: Action area
        _buildActionArea(
          context,
          ride,
          theme,
          isOwnRide: isOwnRide,
          currentUserId: currentUserId,
        ),
      ],
    );
  }

  Widget _buildPosterHeader(Ride ride, ThemeData theme) {
    final universityColor = AppColors.getUniversityColor(ride.posterUniversity);
    final genderIcon = ride.posterGender == 'female'
        ? Icons.female
        : ride.posterGender == 'male'
            ? Icons.male
            : Icons.person;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: universityColor, width: 3),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: ride.posterPhotoUrl != null
                  ? NetworkImage(ride.posterPhotoUrl!)
                  : null,
              child: ride.posterPhotoUrl == null
                  ? Text(
                      ride.posterName.isNotEmpty
                          ? ride.posterName[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.titleLarge,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ride.posterName, style: theme.textTheme.titleLarge),
                Text(
                  ride.posterUniversity,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceDim,
                  ),
                ),
                Row(
                  children: [
                    Icon(genderIcon, size: 14, color: AppColors.onSurfaceDim),
                    const SizedBox(width: 4),
                    Text(
                      ride.posterGender,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceDim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(Ride ride, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RouteVisualization(
              originAddress: ride.originAddress,
              destinationAddress: ride.destinationAddress,
            ),
          ),
          const SizedBox(width: 12),
          // Mini map preview
          _buildMiniMap(ride),
        ],
      ),
    );
  }

  Widget _buildMiniMap(Ride ride) {
    // Build polyline points from route
    final polylinePoints = ride.routePolyline
        .where((p) => p.length >= 2)
        .map((p) => LatLng(p[0], p[1]))
        .toList();

    // Determine origin/destination coordinates
    LatLng? originLatLng;
    LatLng? destLatLng;

    if (ride.originGeopoint != null) {
      originLatLng = LatLng(
        ride.originGeopoint!.latitude,
        ride.originGeopoint!.longitude,
      );
    } else if (polylinePoints.isNotEmpty) {
      originLatLng = polylinePoints.first;
    }

    if (ride.destinationGeopoint != null) {
      destLatLng = LatLng(
        ride.destinationGeopoint!.latitude,
        ride.destinationGeopoint!.longitude,
      );
    } else if (polylinePoints.length >= 2) {
      destLatLng = polylinePoints.last;
    }

    // Compute center and bounds
    final center = originLatLng != null && destLatLng != null
        ? LatLng(
            (originLatLng.latitude + destLatLng.latitude) / 2,
            (originLatLng.longitude + destLatLng.longitude) / 2,
          )
        : originLatLng ?? const LatLng(23.8103, 90.4125); // Dhaka fallback

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 120,
        height: 80,
        child: IgnorePointer(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tagme.app',
              ),
              if (polylinePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      color: AppColors.accent,
                      strokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (originLatLng != null)
                    Marker(
                      point: originLatLng,
                      width: 16,
                      height: 16,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (destLatLng != null)
                    Marker(
                      point: destLatLng,
                      width: 16,
                      height: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent,
                            width: 2,
                          ),
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(Ride ride, ThemeData theme) {
    // Resolve transport type
    TransportType? transport;
    final idx = TransportType.values.indexWhere((t) => t.name == ride.transportType);
    if (idx >= 0) {
      transport = TransportType.values[idx];
    }

    final departureStr = _formatDepartureTime(ride.departureTime);

    final chips = <Widget>[
      _infoChip(
        icon: transport?.icon ?? Icons.directions,
        label: transport?.label ?? ride.transportType,
        theme: theme,
      ),
      _infoChip(
        icon: Icons.access_time,
        label: departureStr,
        theme: theme,
      ),
      _infoChip(
        icon: Icons.person,
        label: '${ride.filledSeats}/${ride.totalSeats} seats',
        theme: theme,
      ),
      if (ride.rideHailingTag != null && ride.rideHailingTag!.isNotEmpty)
        _infoChip(
          icon: Icons.local_taxi,
          label: ride.rideHailingTag!,
          theme: theme,
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .expand((chip) => [chip, const SizedBox(width: AppSpacing.sm)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceDim),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceDim,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareCard(Ride ride, ThemeData theme) {
    final fareCalc = ref.read(fareCalculatorProvider);
    final riderCount = ride.filledSeats + 1;
    final perPerson = fareCalc.calculatePerPersonFare(
      ride.estimatedFare,
      riderCount,
    );

    // Find fare rate per km from transport type
    int farePerKm = 10;
    final idx = TransportType.values.indexWhere((t) => t.name == ride.transportType);
    if (idx >= 0) {
      farePerKm = TransportType.values[idx].farePerKm;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estimated Fare', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${ride.estimatedFare}',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(width: 4),
              Text('BDT', style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '(~$perPerson BDT per person)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceDim,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Based on ${ride.routeDistanceKm.toStringAsFixed(1)}km at $farePerKm BDT/km',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceDim,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(
    BuildContext context,
    Ride ride,
    ThemeData theme, {
    required bool isOwnRide,
    required String currentUserId,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: isOwnRide
          ? _buildOwnRideAction(context, ride, theme)
          : _buildOtherRideAction(context, ride, theme, currentUserId),
    );
  }

  Widget _buildOwnRideAction(
    BuildContext context,
    Ride ride,
    ThemeData theme,
  ) {
    final requestsAsync = ref.watch(
      joinRequestsForRideProvider(widget.rideId),
    );
    final pendingCount = requestsAsync.value
            ?.where((r) => r.status == 'pending')
            .length ??
        0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => context.push('/rides/${widget.rideId}/requests'),
            child: Text('View Requests ($pendingCount)'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherRideAction(
    BuildContext context,
    Ride ride,
    ThemeData theme,
    String currentUserId,
  ) {
    // Check for existing request
    final existingAsync = ref.watch(
      existingJoinRequestProvider(
        rideId: widget.rideId,
        requesterId: currentUserId,
      ),
    );

    final isFull = ride.filledSeats >= ride.totalSeats;

    return existingAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (existingRequest) {
        // Ride is full
        if (isFull && existingRequest?.status != 'accepted') {
          return Center(
            child: Text(
              'Ride Full',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
          );
        }

        // Already accepted
        if (existingRequest?.status == 'accepted') {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () async {
                    // Find conversation for this ride + current user
                    final snapshot = await ref
                        .read(rideRepositoryProvider)
                        .firestore
                        .collection('conversations')
                        .where('rideId', isEqualTo: widget.rideId)
                        .where('participantIds',
                            arrayContains: currentUserId)
                        .limit(1)
                        .get();
                    if (snapshot.docs.isNotEmpty && context.mounted) {
                      context.push('/chats/${snapshot.docs.first.id}');
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Open Chat'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You're In",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  TextButton(
                    onPressed: () => _showLeaveConfirmation(context),
                    child: Text(
                      'Leave Ride',
                      style: TextStyle(color: AppColors.destructive),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Pending request
        if (existingRequest?.status == 'pending') {
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF9AB00), // amber-600
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: null,
              child: const Text(
                'Request Pending',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        // No existing request, not full -> Join button
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSendingRequest ? null : () => _handleJoin(context),
            child: _isSendingRequest
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Join This Ride'),
          ),
        );
      },
    );
  }

  Future<void> _handleJoin(BuildContext context) async {
    setState(() => _isSendingRequest = true);
    try {
      await ref.read(
        sendJoinRequestProvider(rideId: widget.rideId).future,
      );
      // Invalidate existing request to refresh action state
      ref.invalidate(
        existingJoinRequestProvider(
          rideId: widget.rideId,
          requesterId: ref.read(profileProvider).value?.id ?? '',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Join request sent!'),
            backgroundColor: Color(0xFF323232),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not send join request. Tap to retry.'),
            backgroundColor: Color(0xFF323232),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingRequest = false);
    }
  }

  void _showLeaveConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Ride'),
        content: const Text(
          "You'll be removed from this ride. Leave this ride?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement leave ride functionality
            },
            child: Text(
              'Leave',
              style: TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text(
          'This will remove your ride post. Riders who joined will be notified. Cancel this ride?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Ride'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final rideRepo = ref.read(rideRepositoryProvider);
              await rideRepo.cancelRide(widget.rideId);
              if (mounted) context.pop();
            },
            child: Text(
              'Cancel Ride',
              style: TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDepartureTime(DateTime departureTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final depDay = DateTime(
      departureTime.year,
      departureTime.month,
      departureTime.day,
    );

    final hour = departureTime.hour;
    final minute = departureTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    final timeStr = '$displayHour:$minute $period';

    if (depDay == today) return 'Today, $timeStr';
    if (depDay == tomorrow) return 'Tomorrow, $timeStr';
    return '${departureTime.day}/${departureTime.month}, $timeStr';
  }

  Widget _buildShimmer(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: FadeTransition(
        opacity: _shimmerController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster shimmer
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceVariant,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Route card shimmer
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Fare card shimmer
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
