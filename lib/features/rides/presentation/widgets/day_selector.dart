import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';

/// Day-of-week chip row for recurring schedule creation.
///
/// Displays 7 circular chips (Sun through Sat) with multi-select toggle.
/// Days use [DateTime.weekday] values: 1=Mon, 2=Tue, ..., 7=Sun.
class DaySelector extends StatelessWidget {
  const DaySelector({
    required this.selectedDays,
    required this.onChanged,
    super.key,
  });

  /// Currently selected days (values 1-7 per [DateTime.weekday]).
  final List<int> selectedDays;

  /// Called when the selection changes.
  final ValueChanged<List<int>> onChanged;

  // Display order: Sun(7), Mon(1), Tue(2), Wed(3), Thu(4), Fri(5), Sat(6)
  static const _displayOrder = [7, 1, 2, 3, 4, 5, 6];
  static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _fullNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(_displayOrder.length, (index) {
        final dayValue = _displayOrder[index];
        final isSelected = selectedDays.contains(dayValue);
        final label = _labels[index];
        final fullName = _fullNames[index];

        return Padding(
          padding: EdgeInsets.only(
            right: index < _displayOrder.length - 1 ? AppSpacing.sm : 0,
          ),
          child: Semantics(
            label: '$fullName ${isSelected ? "selected" : "not selected"}',
            button: true,
            child: GestureDetector(
              onTap: () {
                final updated = List<int>.from(selectedDays);
                if (isSelected) {
                  updated.remove(dayValue);
                } else {
                  updated.add(dayValue);
                }
                onChanged(updated);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.accent
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
