import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Search text field with 300ms debounce for place autocomplete.
///
/// Autofocuses on mount. Calls [onQuery] after 300ms of inactivity
/// when text length >= 3. Shows a clear "X" button when text is present.
class PlaceSearchBar extends StatefulWidget {
  const PlaceSearchBar({
    super.key,
    required this.onQuery,
    required this.onClear,
  });

  final ValueChanged<String> onQuery;
  final VoidCallback onClear;

  @override
  State<PlaceSearchBar> createState() => _PlaceSearchBarState();
}

class _PlaceSearchBarState extends State<PlaceSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final hadText = _hasText;
    _hasText = text.isNotEmpty;

    if (hadText != _hasText) {
      setState(() {});
    }

    _debounce?.cancel();
    if (text.length >= 3) {
      _debounce = Timer(const Duration(milliseconds: 300), () {
        widget.onQuery(text);
      });
    }
  }

  void _clearText() {
    _controller.clear();
    _debounce?.cancel();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controller,
        autofocus: true,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search for a place...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurfaceDim,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.onSurfaceDim,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.onSurfaceDim,
                  ),
                  onPressed: _clearText,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
