import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// A simple centered circular progress indicator in the accent color.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.accent,
      ),
    );
  }
}
