import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/features/location_sharing/data/services/geocoding_service.dart';
import 'package:tagme/features/location_sharing/providers/geocoding_providers.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/place_result_tile.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/place_search_bar.dart';

/// Full-screen place search with ORS Pelias autocomplete.
///
/// Shows a search bar in the app bar, debounced autocomplete results,
/// and pops with `{'lat': ..., 'lng': ..., 'label': ...}` on result tap.
/// Maximum 10 results displayed.
class PlaceSearchScreen extends ConsumerStatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  ConsumerState<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends ConsumerState<PlaceSearchScreen> {
  List<GeocodingResult>? _results;
  bool _isLoading = false;
  String? _error;
  String _lastQuery = '';

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lastQuery = query;
    });
    try {
      final service = ref.read(geocodingServiceProvider);
      final results = await service.autocomplete(query);
      if (mounted) {
        setState(() {
          _results = results.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Search failed. Check your connection and try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _clearResults() {
    setState(() {
      _results = null;
      _error = null;
      _lastQuery = '';
    });
  }

  void _onResultTap(GeocodingResult result) {
    context.pop<Map<String, dynamic>>({
      'lat': result.latitude,
      'lng': result.longitude,
      'label': result.label,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: PlaceSearchBar(
          onQuery: _performSearch,
          onClear: _clearResults,
        ),
        titleSpacing: 0,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Error state
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.onSurfaceDim,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Idle state (no search performed yet)
    if (_results == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: AppColors.onSurfaceDim,
            ),
            const SizedBox(height: 16),
            Text(
              'Type to search for places',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
          ],
        ),
      );
    }

    // No results state
    if (_results!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: AppColors.onSurfaceDim,
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$_lastQuery"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Results list
    return ListView.separated(
      itemCount: _results!.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = _results![index];
        return PlaceResultTile(
          label: result.label,
          secondaryLabel: result.secondaryLabel,
          onTap: () => _onResultTap(result),
        );
      },
    );
  }
}
