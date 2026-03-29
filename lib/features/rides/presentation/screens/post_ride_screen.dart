import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/core/constants/transport_types.dart';
import 'package:tagme/features/rides/presentation/widgets/seat_stepper.dart';
import 'package:tagme/features/rides/presentation/widgets/transport_selector.dart';
import 'package:tagme/features/rides/providers/ride_providers.dart';

/// Ride posting form with all required fields: origin, destination,
/// transport type, optional ride-hailing tag, departure time, and
/// available seats. Posts to Firestore via the postRide provider.
class PostRideScreen extends ConsumerStatefulWidget {
  const PostRideScreen({super.key});

  @override
  ConsumerState<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends ConsumerState<PostRideScreen> {
  // Origin location state.
  double? _originLat;
  double? _originLng;
  String? _originAddress;

  // Destination location state.
  double? _destLat;
  double? _destLng;
  String? _destAddress;

  // Transport type.
  TransportType? _transport;

  // Ride-hailing tag (optional).
  String? _rideHailingTag;

  // Departure time.
  TimeOfDay? _departureTime;
  bool _isTomorrow = false;

  // Seats.
  int _seats = 1;

  // Posting state.
  bool _isPosting = false;

  bool get _canPost =>
      _originLat != null &&
      _destLat != null &&
      _transport != null &&
      _departureTime != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Ride'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Origin selector.
            _buildSectionLabel(theme, 'Pick-up Point'),
            const SizedBox(height: AppSpacing.sm),
            _buildLocationSelector(
              address: _originAddress,
              placeholder: 'Tap to set on map',
              onTap: () => _pickLocation('origin'),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Section 2: Destination selector.
            _buildSectionLabel(theme, 'Drop-off Point'),
            const SizedBox(height: AppSpacing.sm),
            _buildLocationSelector(
              address: _destAddress,
              placeholder: 'Tap to set on map',
              onTap: () => _pickLocation('destination'),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Section 3: Transport type selector.
            _buildSectionLabel(theme, 'Transport Type'),
            const SizedBox(height: AppSpacing.sm),
            TransportSelector(
              selected: _transport,
              onSelected: _onTransportSelected,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Section 4: Ride-hailing tag (optional).
            _buildSectionLabel(
              theme,
              'Ride-Hailing Service (optional)',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildRideHailingChips(theme),

            const SizedBox(height: AppSpacing.lg),

            // Section 5: Departure time.
            _buildSectionLabel(theme, 'Departure Time'),
            const SizedBox(height: AppSpacing.sm),
            _buildTimePicker(theme),

            const SizedBox(height: AppSpacing.lg),

            // Section 6: Available seats.
            _buildSectionLabel(theme, 'Available Seats'),
            const SizedBox(height: AppSpacing.sm),
            SeatStepper(
              value: _seats,
              max: _transport?.maxCapacity ?? 1,
              onChanged: (v) => setState(() => _seats = v),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Section 7: Post button.
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _canPost && !_isPosting
                    ? _postRide
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.accent.withValues(alpha: 0.38),
                  disabledForegroundColor:
                      Colors.white.withValues(alpha: 0.38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Post Ride'),
              ),
            ),

            // Bottom padding for scrolling comfort.
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section builders
  // ---------------------------------------------------------------------------

  Widget _buildSectionLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildLocationSelector({
    required String? address,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final hasAddress = address != null && address.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          hasAddress ? address : placeholder,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: hasAddress ? null : theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildRideHailingChips(ThemeData theme) {
    const tags = ['Pathao', 'Uber', 'Obhai'];
    return Wrap(
      spacing: AppSpacing.sm,
      children: tags.map((tag) {
        final isSelected = _rideHailingTag == tag;
        return GestureDetector(
          onTap: () {
            setState(() {
              _rideHailingTag = isSelected ? null : tag;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.transparent
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.accent, width: 2)
                  : null,
            ),
            child: Text(
              tag,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? AppColors.accent
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker(ThemeData theme) {
    final hasTime = _departureTime != null;
    String timeText;
    if (hasTime) {
      final now = DateTime.now();
      final selected = DateTime(
        now.year,
        now.month,
        now.day,
        _departureTime!.hour,
        _departureTime!.minute,
      );
      _isTomorrow = selected.isBefore(now);
      final dayLabel = _isTomorrow ? 'Tomorrow' : 'Today';
      final formatted = DateFormat('h:mm a').format(selected);
      timeText = '$dayLabel, $formatted';
    } else {
      timeText = 'Select time';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              timeText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: hasTime ? null : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        if (hasTime && _isTomorrow)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'Tomorrow',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Interactions
  // ---------------------------------------------------------------------------

  Future<void> _pickLocation(String mode) async {
    final result = await context.push<Map<String, dynamic>>(
      '/rides/post/pick-location?mode=$mode',
    );
    if (result == null || !mounted) return;

    setState(() {
      final lat = result['lat'] as double;
      final lng = result['lng'] as double;
      final address = result['address'] as String;

      if (mode == 'origin') {
        _originLat = lat;
        _originLng = lng;
        _originAddress = address;
      } else {
        _destLat = lat;
        _destLng = lng;
        _destAddress = address;
      }
    });
  }

  void _onTransportSelected(TransportType type) {
    setState(() {
      _transport = type;
      // Bike: auto-set to 1 seat, stepper disabled.
      if (type == TransportType.bike) {
        _seats = 1;
      } else {
        // Default: maxCapacity - 1 (poster takes one seat).
        _seats = type.maxCapacity - 1;
        if (_seats < 1) _seats = 1;
      }
    });
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _departureTime = picked);
  }

  Future<void> _postRide() async {
    if (!_canPost) return;
    setState(() => _isPosting = true);

    try {
      final now = DateTime.now();
      var departure = DateTime(
        now.year,
        now.month,
        now.day,
        _departureTime!.hour,
        _departureTime!.minute,
      );
      // Auto-bump to tomorrow if time is in the past.
      if (departure.isBefore(now)) {
        departure = departure.add(const Duration(days: 1));
      }

      await ref.read(
        postRideProvider(
          originLat: _originLat!,
          originLng: _originLng!,
          originAddress: _originAddress!,
          destLat: _destLat!,
          destLng: _destLng!,
          destAddress: _destAddress!,
          transportType: _transport!.name,
          departureTime: departure,
          totalSeats: _seats,
          rideHailingTag: _rideHailingTag,
        ).future,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride posted successfully'),
        ),
      );
      context.pop();
    } on Exception catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not post your ride. Tap to retry.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }
}
