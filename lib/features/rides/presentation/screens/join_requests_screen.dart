import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/features/rides/data/models/join_request.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';
import 'package:tagme/features/rides/data/repositories/join_request_repository.dart';
import 'package:tagme/features/rides/providers/ride_providers.dart';

/// Screen where ride posters can view and manage pending join requests.
///
/// Displays pending requests with accept/decline icon buttons,
/// card slide-out animations, and full-ride handling.
class JoinRequestsScreen extends ConsumerStatefulWidget {
  const JoinRequestsScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<JoinRequestsScreen> createState() =>
      _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends ConsumerState<JoinRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  /// Track requests being processed to show loading state.
  final Set<String> _processingIds = {};

  /// Track requests being animated out to skip in list.
  final Set<String> _removingIds = {};

  /// Whether ride became full after an accept action.
  bool _rideFull = false;

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
    final theme = Theme.of(context);
    final requestsAsync = ref.watch(
      joinRequestsForRideProvider(widget.rideId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Join Requests', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: requestsAsync.when(
        loading: () => _buildShimmer(theme),
        error: (error, _) => Center(
          child: Text(
            'Could not load requests.',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        data: (requests) {
          final pendingRequests = requests
              .where((r) =>
                  r.status == 'pending' && !_removingIds.contains(r.id))
              .toList();

          if (pendingRequests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No requests yet. Share your ride to get co-riders.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceDim,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: pendingRequests.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              return _RequestCard(
                request: request,
                isProcessing: _processingIds.contains(request.id),
                isRideFull: _rideFull,
                onAccept: () => _handleAccept(context, request),
                onDecline: () => _handleDecline(context, request),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    JoinRequest request,
  ) async {
    if (request.id == null) return;
    setState(() => _processingIds.add(request.id!));

    try {
      final repo = ref.read(joinRequestRepositoryProvider);
      final ride =
          await ref.read(rideDetailProvider(widget.rideId).future);
      final profile = ref.read(profileProvider).value;

      await repo.acceptRequest(
        request.id!,
        widget.rideId,
        posterName: profile?.name ?? '',
        posterUniversity: profile?.university ?? '',
        rideOrigin: ride?.originAddress ?? '',
        rideDestination: ride?.destinationAddress ?? '',
        rideTransportType: ride?.transportType ?? '',
        rideDepartureTime: ride?.departureTime ?? DateTime.now(),
      );

      setState(() {
        _processingIds.remove(request.id!);
        _removingIds.add(request.id!);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accepted ${request.requesterName}'),
            backgroundColor: const Color(0xFF323232),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on Exception catch (e) {
      setState(() => _processingIds.remove(request.id!));

      if (e.toString().contains('Ride is full')) {
        setState(() => _rideFull = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ride is now full'),
              backgroundColor: Color(0xFF323232),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not accept request. Try again.'),
              backgroundColor: Color(0xFF323232),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDecline(
    BuildContext context,
    JoinRequest request,
  ) async {
    if (request.id == null) return;
    setState(() => _processingIds.add(request.id!));

    try {
      final repo = ref.read(joinRequestRepositoryProvider);
      await repo.declineRequest(request.id!);

      setState(() {
        _processingIds.remove(request.id!);
        _removingIds.add(request.id!);
      });
    } on Exception catch (_) {
      setState(() => _processingIds.remove(request.id!));
    }
  }

  Widget _buildShimmer(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: FadeTransition(
        opacity: _shimmerController,
        child: Column(
          children: List.generate(
            2,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual request card with avatar, info, and accept/decline buttons.
class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.isProcessing,
    required this.isRideFull,
    required this.onAccept,
    required this.onDecline,
  });

  final JoinRequest request;
  final bool isProcessing;
  final bool isRideFull;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final universityColor = AppColors.getUniversityColor(
      request.requesterUniversity,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: universityColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: request.requesterPhotoUrl != null
                      ? NetworkImage(request.requesterPhotoUrl!)
                      : null,
                  child: request.requesterPhotoUrl == null
                      ? Text(
                          request.requesterName.isNotEmpty
                              ? request.requesterName[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.labelLarge,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      request.requesterUniversity,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceDim,
                      ),
                    ),
                    if (request.createdAt != null)
                      Text(
                        _formatRelativeTime(request.createdAt!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceDim,
                        ),
                      ),
                  ],
                ),
              ),

              // Action buttons
              if (isProcessing)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Accept button
                    Semantics(
                      label:
                          "Accept ${request.requesterName}'s join request",
                      child: GestureDetector(
                        onTap: isRideFull ? null : onAccept,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isRideFull
                                ? AppColors.onSurfaceDim.withValues(
                                    alpha: 0.3,
                                  )
                                : AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Decline button
                    Semantics(
                      label:
                          "Decline ${request.requesterName}'s join request",
                      child: GestureDetector(
                        onTap: isRideFull ? null : onDecline,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isRideFull
                                ? AppColors.onSurfaceDim.withValues(
                                    alpha: 0.3,
                                  )
                                : AppColors.destructive,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (isRideFull)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Ride is now full',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
