import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/universities.dart';

/// Searchable dropdown for selecting a university from the BD list.
class UniversityDropdown extends StatefulWidget {
  const UniversityDropdown({
    required this.onSelected,
    super.key,
    this.selectedUniversity,
  });

  /// Currently selected university, if any.
  final String? selectedUniversity;

  /// Called when a university is selected from the dropdown.
  final ValueChanged<String> onSelected;

  @override
  State<UniversityDropdown> createState() => _UniversityDropdownState();
}

class _UniversityDropdownState extends State<UniversityDropdown> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  List<String> _filtered = [];
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedUniversity != null) {
      _controller.text = widget.selectedUniversity!;
      _isSelected = true;
    }
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(UniversityDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedUniversity != oldWidget.selectedUniversity &&
        widget.selectedUniversity != null) {
      _controller.text = widget.selectedUniversity!;
      _isSelected = true;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _filterUniversities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = bdUniversities.take(5).toList();
      } else {
        _filtered = bdUniversities
            .where(
              (u) => u.toLowerCase().contains(query.toLowerCase()),
            )
            .take(5)
            .toList();
      }
    });
    _updateOverlay();
  }

  void _updateOverlay() {
    _removeOverlay();
    if (_filtered.isEmpty || _isSelected) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 52),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final university = _filtered[index];
                  return ListTile(
                    title: Text(university),
                    onTap: () => _selectUniversity(university),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  double _getWidth() {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 300;
  }

  void _selectUniversity(String university) {
    setState(() {
      _controller.text = university;
      _isSelected = true;
    });
    _removeOverlay();
    _focusNode.unfocus();
    widget.onSelected(university);
  }

  void _clearSelection() {
    setState(() {
      _controller.clear();
      _isSelected = false;
    });
    widget.onSelected('');
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isSelected && _controller.text.isNotEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
        ),
        child: Chip(
          label: Text(_controller.text),
          backgroundColor: AppColors.accent.withValues(alpha: 0.1),
          labelStyle: const TextStyle(color: AppColors.accent),
          deleteIcon: const Icon(
            Icons.close,
            size: 18,
            color: AppColors.accent,
          ),
          onDeleted: _clearSelection,
        ),
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search your university...',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: _filterUniversities,
      ),
    );
  }
}
