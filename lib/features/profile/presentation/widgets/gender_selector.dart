import 'package:flutter/material.dart';

/// Material 3 SegmentedButton for selecting gender.
class GenderSelector extends StatelessWidget {
  const GenderSelector({
    required this.onSelected,
    super.key,
    this.selectedGender,
  });

  /// Currently selected gender value ('male', 'female', 'other').
  final String? selectedGender;

  /// Called when a gender segment is tapped.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'male',
            label: Text('Male'),
          ),
          ButtonSegment(
            value: 'female',
            label: Text('Female'),
          ),
          ButtonSegment(
            value: 'other',
            label: Text('Other'),
          ),
        ],
        selected: selectedGender != null ? {selectedGender!} : {},
        emptySelectionAllowed: true,
        onSelectionChanged: (selected) {
          if (selected.isNotEmpty) {
            onSelected(selected.first);
          }
        },
      ),
    );
  }
}
