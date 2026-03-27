import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/features/fares/data/models/fare_entry.dart';
import 'package:tagme/features/fares/presentation/widgets/balance_row.dart';
import 'package:tagme/features/fares/presentation/widgets/fare_history_card.dart';
import 'package:tagme/features/fares/providers/fare_providers.dart';

/// Screen showing fare balances and history in two tabs.
///
/// "Balances" tab displays net amounts owed per co-rider.
/// "History" tab lists fare entries grouped by date.
class FareHistoryScreen extends ConsumerStatefulWidget {
  const FareHistoryScreen({super.key});

  @override
  ConsumerState<FareHistoryScreen> createState() => _FareHistoryScreenState();
}

class _FareHistoryScreenState extends ConsumerState<FareHistoryScreen> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentUserId = prefs.getString('local_profile_id');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fares', style: theme.textTheme.titleLarge),
          leading: const BackButton(),
          bottom: TabBar(
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.onSurfaceDim,
            indicatorColor: AppColors.accent,
            tabs: const [
              Tab(text: 'Balances'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBalancesTab(theme),
            _buildHistoryTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBalancesTab(ThemeData theme) {
    final balancesAsync = ref.watch(fareBalancesProvider);

    return balancesAsync.when(
      data: (balances) {
        if (balances.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No shared rides yet. Your fare splits will appear here.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Sort by absolute balance (highest first).
        final sortedEntries = balances.entries.toList()
          ..sort(
            (a, b) => b.value.abs().compareTo(a.value.abs()),
          );

        return ListView.builder(
          itemCount: sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            final coRiderId = entry.key;
            final balance = entry.value;

            return _BalanceRowWithProfile(
              coRiderId: coRiderId,
              balance: balance,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Could not load balances.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.destructive,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(ThemeData theme) {
    final historyAsync = ref.watch(fareHistoryProvider);

    return historyAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No ride history yet. Complete a shared ride to see '
                'fare details.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Group entries by date.
        final grouped = _groupByDate(entries);
        final dateKeys = grouped.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: dateKeys.length,
          itemBuilder: (context, index) {
            final dateLabel = dateKeys[index];
            final dateEntries = grouped[dateLabel]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0) const SizedBox(height: AppSpacing.md),
                Text(
                  dateLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceDim,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...dateEntries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.sm,
                    ),
                    child: FareHistoryCard(
                      entry: entry,
                      currentUserId: _currentUserId ?? '',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Could not load history.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.destructive,
          ),
        ),
      ),
    );
  }

  /// Groups fare entries by display date label.
  Map<String, List<FareEntry>> _groupByDate(List<FareEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<FareEntry>>{};

    for (final entry in entries) {
      final entryDate = DateTime(
        entry.rideDate.year,
        entry.rideDate.month,
        entry.rideDate.day,
      );

      final String label;
      if (entryDate == today) {
        label = 'Today';
      } else if (entryDate == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('EEE, MMM d').format(entry.rideDate);
      }

      groups.putIfAbsent(label, () => []).add(entry);
    }

    return groups;
  }
}

/// A BalanceRow that auto-fetches the co-rider's profile.
class _BalanceRowWithProfile extends ConsumerWidget {
  const _BalanceRowWithProfile({
    required this.coRiderId,
    required this.balance,
  });

  final String coRiderId;
  final int balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(coRiderProfileProvider(coRiderId));

    return profileAsync.when(
      data: (profile) => BalanceRow(
        name: profile?.name ?? 'Unknown',
        university: profile?.university ?? 'Unknown',
        photoUrl: profile?.photoUrl,
        balance: balance,
      ),
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => BalanceRow(
        name: 'Unknown',
        university: 'Unknown',
        balance: balance,
      ),
    );
  }
}
