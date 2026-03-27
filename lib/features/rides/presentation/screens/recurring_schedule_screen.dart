import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/core/constants/transport_types.dart';
import 'package:tagme/features/rides/data/models/recurring_schedule.dart';
import 'package:tagme/features/rides/data/repositories/schedule_repository.dart';
import 'package:tagme/features/rides/presentation/widgets/day_selector.dart';
import 'package:tagme/features/rides/presentation/widgets/transport_selector.dart';
import 'package:tagme/features/rides/providers/schedule_providers.dart';

/// Screen for creating recurring ride schedules and viewing active ones.
///
/// Provides a form with route, day-of-week selection, time, and transport
/// type. Active schedules are listed below with swipe-to-delete.
class RecurringScheduleScreen extends ConsumerStatefulWidget {
  const RecurringScheduleScreen({super.key});

  @override
  ConsumerState<RecurringScheduleScreen> createState() =>
      _RecurringScheduleScreenState();
}

class _RecurringScheduleScreenState
    extends ConsumerState<RecurringScheduleScreen> {
  // Form state
  String? _originAddress;
  double? _originLat;
  double? _originLng;
  String? _destinationAddress;
  double? _destinationLat;
  double? _destinationLng;
  List<int> _selectedDays = [];
  TimeOfDay? _departureTime;
  TransportType? _selectedTransport;
  bool _isSaving = false;

  bool get _canSave =>
      _originAddress != null &&
      _destinationAddress != null &&
      _selectedDays.isNotEmpty &&
      _departureTime != null &&
      _selectedTransport != null &&
      !_isSaving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedules = ref.watch(mySchedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Schedule', style: theme.textTheme.titleLarge),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Route summary
            _buildRouteSection(theme),
            const SizedBox(height: AppSpacing.lg),

            // Section 2: Day selector
            Text(
              'Repeat on',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DaySelector(
              selectedDays: _selectedDays,
              onChanged: (days) => setState(() => _selectedDays = days),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Section 3: Time picker
            Text(
              'Departure Time',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildTimePicker(theme),
            const SizedBox(height: AppSpacing.lg),

            // Section 4: Transport selector
            Text(
              'Transport Type',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TransportSelector(
              selected: _selectedTransport,
              onSelected: (type) =>
                  setState(() => _selectedTransport = type),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Section 5: Schedule preview
            if (_selectedDays.isNotEmpty && _departureTime != null)
              _buildPreviewSection(theme),

            // Section 6: Save button
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _canSave ? _saveSchedule : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.38),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Schedule'),
              ),
            ),

            // Active Schedules section
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Text('Active Schedules', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.md),
            _buildActiveSchedules(schedules, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSection(ThemeData theme) {
    return GestureDetector(
      onTap: _pickOrigin,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Origin row
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickOrigin,
                    child: Text(
                      _originAddress ?? 'Tap to set pick-up point',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _originAddress != null
                            ? null
                            : AppColors.onSurfaceDim,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            // Connecting line
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                width: 2,
                height: AppSpacing.md,
                color: AppColors.surfaceVariant,
              ),
            ),
            // Destination row
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDestination,
                    child: Text(
                      _destinationAddress ?? 'Tap to set drop-off point',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _destinationAddress != null
                            ? null
                            : AppColors.onSurfaceDim,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap to change route',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(ThemeData theme) {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          _departureTime != null
              ? _departureTime!.format(context)
              : 'Select time',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: _departureTime != null ? null : AppColors.onSurfaceDim,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.onSurfaceDim,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._getNextRideDates().map(
          (date) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '${DateFormat('EEE MMM d').format(date)}, '
              '${_departureTime!.format(context)} -- '
              '${_originAddress ?? "Origin"} to '
              '${_destinationAddress ?? "Destination"} via '
              '${_selectedTransport?.label ?? "Transport"}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Computes the next 5 upcoming ride dates based on selected days.
  List<DateTime> _getNextRideDates() {
    if (_selectedDays.isEmpty) return [];

    final dates = <DateTime>[];
    var current = DateTime.now();

    // Look ahead up to 30 days to find 5 matches.
    for (var i = 0; i < 30 && dates.length < 5; i++) {
      final checkDate = current.add(Duration(days: i));
      if (_selectedDays.contains(checkDate.weekday)) {
        dates.add(checkDate);
      }
    }
    return dates;
  }

  Widget _buildActiveSchedules(
    AsyncValue<List<RecurringSchedule>> schedules,
    ThemeData theme,
  ) {
    return schedules.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No active schedules yet.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
            ),
          );
        }
        return Column(
          children: list.map((schedule) => _buildScheduleCard(schedule, theme)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Could not load schedules.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.destructive,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(RecurringSchedule schedule, ThemeData theme) {
    // Resolve transport icon.
    IconData transportIcon;
    try {
      final type = TransportType.fromString(schedule.transportType);
      transportIcon = type.icon;
    } on ArgumentError catch (_) {
      transportIcon = Icons.directions;
    }

    return Dismissible(
      key: ValueKey(schedule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: AppColors.destructive,
        child: const Text(
          'Delete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      onDismissed: (_) => _deleteSchedule(schedule),
      child: GestureDetector(
        onTap: () => _editSchedule(schedule),
        child: Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        schedule.originAddress,
                        style: theme.textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        schedule.destinationAddress,
                        style: theme.textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Day chips (read-only) + time + transport
                Row(
                  children: [
                    // Mini day chips
                    ...['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .asMap()
                        .entries
                        .map((entry) {
                      final dayValue = [7, 1, 2, 3, 4, 5, 6][entry.key];
                      final isActive =
                          schedule.daysOfWeek.contains(dayValue);
                      return Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? AppColors.accent
                              : AppColors.surfaceVariant,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: isActive ? Colors.white : null,
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    Icon(transportIcon, size: 20, color: AppColors.onSurfaceDim),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      schedule.departureTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceDim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickOrigin() async {
    final result = await context.push<Map<String, dynamic>>(
      '/rides/post/pick-location?mode=origin',
    );
    if (result != null && mounted) {
      setState(() {
        _originLat = result['lat'] as double?;
        _originLng = result['lng'] as double?;
        _originAddress = result['address'] as String?;
      });
    }
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() => _departureTime = picked);
    }
  }

  Future<void> _saveSchedule() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);

    try {
      final timeStr =
          '${_departureTime!.hour.toString().padLeft(2, '0')}:'
          '${_departureTime!.minute.toString().padLeft(2, '0')}';

      // Default seats based on transport type.
      final seats = (_selectedTransport?.maxCapacity ?? 2) - 1;

      await ref.read(
        createScheduleProvider(
          originLat: _originLat!,
          originLng: _originLng!,
          originAddress: _originAddress!,
          destinationLat: _destinationLat!,
          destinationLng: _destinationLng!,
          destinationAddress: _destinationAddress!,
          transportType: _selectedTransport!.name,
          totalSeats: seats > 0 ? seats : 1,
          departureTime: timeStr,
          daysOfWeek: _selectedDays,
        ).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule saved')),
        );
        // Reset form.
        setState(() {
          _selectedDays = [];
          _departureTime = null;
          _selectedTransport = null;
        });
        // Invalidate to refresh the list.
        ref.invalidate(mySchedulesProvider);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save schedule: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _deleteSchedule(RecurringSchedule schedule) {
    final repo = ref.read(scheduleRepositoryProvider);
    repo.deleteSchedule(schedule.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Schedule deleted'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Re-create the schedule.
            repo.createSchedule(schedule);
            ref.invalidate(mySchedulesProvider);
          },
        ),
      ),
    );

    ref.invalidate(mySchedulesProvider);
  }

  void _editSchedule(RecurringSchedule schedule) {
    // Pre-populate form with schedule data.
    setState(() {
      _originAddress = schedule.originAddress;
      _originLat = schedule.originGeopoint?.latitude;
      _originLng = schedule.originGeopoint?.longitude;
      _destinationAddress = schedule.destinationAddress;
      _destinationLat = schedule.destinationGeopoint?.latitude;
      _destinationLng = schedule.destinationGeopoint?.longitude;
      _selectedDays = List<int>.from(schedule.daysOfWeek);

      // Parse departure time.
      final parts = schedule.departureTime.split(':');
      if (parts.length == 2) {
        _departureTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }

      // Parse transport type.
      try {
        _selectedTransport = TransportType.fromString(schedule.transportType);
      } catch (_) {
        _selectedTransport = null;
      }
    });
  }
}
