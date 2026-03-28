import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/features/location_sharing/data/services/poi_service.dart';

/// Horizontal scrollable POI category chip bar.
///
/// Displays category chips (Universities, Bus Stops, Restaurants, Hospitals).
/// Selecting a chip triggers a POI query; tapping the already-selected chip
/// deselects it (passes null).
class POIChipBar extends StatelessWidget {
  const POIChipBar({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;

  static const _chipIcons = <int, IconData>{
    POICategories.universities: Icons.school,
    POICategories.busStops: Icons.directions_bus,
    POICategories.restaurants: Icons.restaurant,
    POICategories.hospitals: Icons.local_hospital,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: POICategories.all.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = POICategories.all[index];
            final isSelected = selectedCategoryId == category.id;

            return ChoiceChip(
              label: Text(category.label),
              avatar: Icon(
                _chipIcons[category.id] ?? Icons.place,
                size: 16,
                color: isSelected ? Colors.white : AppColors.onSurfaceDim,
              ),
              selected: isSelected,
              onSelected: (_) {
                onCategorySelected(isSelected ? null : category.id);
              },
              selectedColor: AppColors.accent,
              backgroundColor: AppColors.surfaceVariant,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.onSurfaceDim,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              showCheckmark: false,
            );
          },
        ),
      ),
    );
  }
}
